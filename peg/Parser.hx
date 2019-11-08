package peg;

import peg.parser.*;
import peg.php.*;
import peg.php.PUse;
import peg.php.Visibility;
import haxe.ds.ReadOnlyArray;

using peg.parser.Tools;

class Parser {
	final tokens:ReadOnlyArray<Token>;

	public function new(tokens:ReadOnlyArray<Token>) {
		this.tokens = tokens;
	}

	public function parse():ReadOnlyArray<PNamespace> {
		var ctx = new Context(new TokenStream(tokens));

		for(token in ctx.stream) {
			switch token.type {
				//any html before <?php
				case T_INLINE_HTML:
				//<?php
				case T_OPEN_TAG:
				//<?="str"?>
				case T_OPEN_TAG_WITH_ECHO:
					ctx.stream.skipTo(T_CLOSE_TAG);
				//namespace "some\\pack";
				case T_NAMESPACE:
					ctx.pushNamespace(new PNamespace(parseTypePath(ctx)));
					var token = ctx.stream.next();
					switch token.type {
						case T_LEFT_CURLY | T_SEMICOLON:
						case _: throw new UnexpectedTokenException(token);
					}
				//use "some\\Class"
				case T_USE:
					ctx.getNamespace().addUses(parseUse(ctx));
				//doc block, final, abstract
				case T_DOC_COMMENT | T_FINAL | T_ABSTRACT:
					ctx.storeToken(token);
				//class MyClass {}
				case T_CLASS:
					ctx.getNamespace().addClass(parseClass(ctx));
				//interface IMyInterface {}
				case T_INTERFACE:
					ctx.storeToken(token);
					ctx.getNamespace().addClass(parseClass(ctx));
				//trait IMyInterface {}
				case T_TRAIT:
					ctx.storeToken(token);
					ctx.getNamespace().addClass(parseClass(ctx));
				// namespace-level function
				case T_FUNCTION:
					var token = ctx.stream.next();
					switch token.type {
						//ordinary "named" function
						case T_STRING:
							ctx.stream.back();
							ctx.getNamespace().addFunction(parseFunction(ctx));
						//function () use () { - anonymous function
						case T_LEFT_PARENTHESIS:
							ctx.stream.skipBalancedTo(T_RIGHT_PARENTHESIS);
							//Skip `use` if exists. Otherwise skips `{`, but it's ok at namespace level. We were about to skip it anyway.
							ctx.stream.next();
						case _: throw new UnexpectedTokenException(token);
					}
				// <<< SOME
				case T_START_HEREDOC:
					ctx.stream.skipTo(T_END_HEREDOC);
				// maybe `new class {...`?
				case T_NEW:
					switch(ctx.stream.next().type) {
						case T_CLASS: //skip it
						case _: ctx.stream.back();
					}
				case _:
					// TODO: handle `define('CONST_NAME', 'const value')`
					// TODO: handle `class_alias()` ?
					// throw new UnexpectedTokenException(token);
			}
		}
		return ctx.namespaces;
	}

	/**
	 * `use` at namespace level
	 * @param ctx
	 * @return Array<PUse>
	 */
	function parseUse(ctx:Context):Array<PUse> {
		function parseAlias():Null<String> {
			var token = ctx.stream.next();
			return switch token.type {
				case T_AS:
					parseTypePath(ctx);
				case T_SEMICOLON:
					ctx.stream.back();
					null;
				case _: throw new UnexpectedTokenException(token);
			}
		}
		var uses = [];
		for (token in ctx.stream) {
			switch token.type {
				case T_STRING | T_NS_SEPARATOR:
					ctx.stream.back();
					var type = parseTypePath(ctx);
					var alias = parseAlias();
					uses.push(PUse.UClass(type, alias));
				case T_FUNCTION:
					var fnPath = parseTypePath(ctx);
					var alias = parseAlias();
					uses.push(UFunction(fnPath, alias));
				case T_CONST:
					var constPath = parseTypePath(ctx);
					uses.push(UConst(constPath));
				case T_SEMICOLON: break;
				case _: throw new UnexpectedTokenException(token);
			}
		}
		return uses;
	}

	/**
	 * `use` at class level
	 * @param ctx
	 * @return Array<PUse>
	 */
	function parseUseTraits(ctx:Context):PUse {
		function parseMethod():PUse.Method {
			//don't know yet if it's a method name or a class name
			var symbol = parseTypePath(ctx);
			var token = ctx.stream.next();
			switch token.type {
				//it was a class name
				case T_DOUBLE_COLON:
					var name = ctx.stream.expect(T_STRING).value;
					return {type:symbol, name:name}
				//it was a method name
				case T_AS:
					ctx.stream.back();
					return {name:symbol}
				case _:
					throw new UnexpectedTokenException(token);
			}
		}
		function parseAlias(method:String):PUse.Alias {
			var visibility = VPublic;
			var name = method;
			for (token in ctx.stream) {
				switch token.type {
					case T_PUBLIC: visibility = VPublic;
					case T_PRIVATE: visibility = VPrivate;
					case T_PROTECTED: visibility = VProtected;
					case T_STRING: name = token.value;
					case T_SEMICOLON: break;
					case _: throw new UnexpectedTokenException(token);
				}
			}
			return {visibility:visibility, name:name};
		}

		var traitsPaths = [parseTypePath(ctx)];
		for (token in ctx.stream) {
			switch token.type {
				case T_COMMA: traitsPaths.push(parseTypePath(ctx));
				case T_SEMICOLON: return UTrait(traitsPaths);
				//use pack\\MyTrait { method as alias }
				case T_LEFT_CURLY: break;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		var aliases = [];
		for (token in ctx.stream) {
			switch token.type {
				// `MyType::method as alias` or `method as alias`
				case T_STRING:
					ctx.stream.back();
					var method = parseMethod();
					ctx.stream.expect(T_AS);
					aliases.push({method:method, alias:parseAlias(method.name)});
				case T_RIGHT_CURLY:
					break;
				case T_SEMICOLON:
				case _:
					throw new UnexpectedTokenException(token);
			}
		}
		return UTrait(traitsPaths, aliases);
	}

	function parseTypePath(ctx:Context):String {
		var name = '';
		for(token in ctx.stream) {
			switch token.type {
				case T_STRING | T_NS_SEPARATOR:
					name += token.value;
				case _:
					ctx.stream.back();
					break;
			}
		}
		return name;
	}

	function parseType(ctx:Context):PType {
		var token = ctx.stream.next();
		return switch token.type {
			case T_ARRAY: TArray;
			case T_CALLABLE: TCallable;
			case T_STRING | T_NS_SEPARATOR:
				ctx.stream.back();
				switch(parseTypePath(ctx)) {
					case 'string': TString;
					case path: TClass(path);
				}
			case _:
				throw new UnexpectedTokenException(token);
		}
	}

	function parseClass(ctx:Context):PClass {
		var token = ctx.stream.next();
		var name = switch token.type {
			case T_STRING: token.value;
			case _: throw new UnexpectedTokenException(token);
		}

		var cls = new PClass(name);

		for(token in ctx.consumeStoredTokens()) {
			switch token.type {
				case T_INTERFACE: cls.isInterface = true;
				case T_TRAIT: cls.isTrait = true;
				case T_DOC_COMMENT: cls.doc = token.value;
				case T_FINAL: cls.isFinal = true;
				case T_ABSTRACT: cls.isAbstract = true;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		//extends, implements
		for (token in ctx.stream) {
			switch token.type {
				case T_LEFT_CURLY: break;
				case T_EXTENDS if(cls.isInterface): parseInterfaces(ctx, cls);
				case T_EXTENDS: cls.parent = parseTypePath(ctx);
				case T_IMPLEMENTS: parseInterfaces(ctx, cls);
				case _: throw new UnexpectedTokenException(token);
			}
		}

		//class body
		for (token in ctx.stream) {
			switch token.type {
				case T_USE:
					cls.addTraits(parseUseTraits(ctx));
				case T_VAR | T_PUBLIC | T_PROTECTED | T_PRIVATE | T_STATIC | T_DOC_COMMENT | T_ABSTRACT | T_FINAL:
					ctx.storeToken(token);
				case T_FUNCTION:
					cls.addFunction(parseFunction(ctx));
				case T_VARIABLE:
					cls.addVar(parseVar(ctx, token.value));
				case T_RIGHT_CURLY:
					break;
				case T_CONST:
					for (c in parseConst(ctx)) {
						cls.addConst(c);
					}
				case _:
					throw new UnexpectedTokenException(token);
			}
		}

		return cls;
	}

	function parseInterfaces(ctx:Context, cls:PClass) {
		cls.addInterface(parseTypePath(ctx));
		for (token in ctx.stream) {
			switch token.type {
				case T_COMMA:
					cls.addInterface(parseTypePath(ctx));
				case T_LEFT_CURLY:
					ctx.stream.back();
					break;
				case _:
					throw new UnexpectedTokenException(token);
			}
		}
	}

	function parseFunction(ctx:Context):PFunction {
		var token = ctx.stream.next();
		var name = switch token.type {
			case T_STRING: token.value;
			case _: throw new UnexpectedTokenException(token);
		}

		var fn = new PFunction(name);

		for(token in ctx.consumeStoredTokens()) {
			switch token.type {
				case T_DOC_COMMENT: fn.doc = token.value;
				case T_ABSTRACT: fn.isAbstract = true;
				case T_FINAL: fn.isFinal = true;
				case T_PUBLIC: fn.visibility = VPublic;
				case T_PROTECTED: fn.visibility = VProtected;
				case T_PRIVATE: fn.visibility = VPrivate;
				case T_STATIC: fn.isStatic = true;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		parseArguments(ctx, fn);

		//body
		for (token in ctx.stream) {
			switch token.type {
				case T_LEFT_CURLY:
					ctx.stream.skipBalancedTo(T_RIGHT_CURLY);
					break;
				//abstract method - no body
				case T_SEMICOLON:
					break;
				//return type
				case _:
					ctx.stream.back();
					fn.returnType = parseType(ctx);
			}
		}

		return fn;
	}

	function parseArguments(ctx:Context, fn:PFunction) {
		function parseRestArg():PVar {
			var v = parseVar(ctx, ctx.stream.expect(T_VARIABLE).value);
			v.isRestArg = true;
			return v;
		}

		ctx.stream.expect(T_LEFT_PARENTHESIS);
		for (token in ctx.stream) {
			switch token.type {
				//end of args
				case T_RIGHT_PARENTHESIS:
					return;
				//$argName
				case T_VARIABLE:
					fn.addArg(parseVar(ctx, token.value));
				//...$argName
				case T_ELLIPSIS:
					fn.addArg(parseRestArg());
				//SomeType $arg
				case T_DOC_COMMENT:
					ctx.storeToken(token);
				case _:
					ctx.stream.back();
					var type = parseType(ctx);
					var token = ctx.stream.next();
					var v = switch token.type {
						case T_ELLIPSIS: parseRestArg();
						case T_VARIABLE: parseVar(ctx, token.value);
						case _: throw new UnexpectedTokenException(token);
					}
					v.type = type;
					fn.addArg(v);
			}
		}
	}

	function parseConst(ctx:Context):Array<PConst> {
		var storedTokens = ctx.consumeStoredTokens();

		var constants = [];
		for (token in ctx.stream) {
			switch token.type {
				case T_STRING:
					var c = new PConst(token.value);
					for(token in storedTokens.copy()) {
						switch token.type {
							case T_DOC_COMMENT: c.doc = token.value;
							case T_PUBLIC: c.visibility = VPublic;
							case T_PROTECTED: c.visibility = VProtected;
							case T_PRIVATE: c.visibility = VPrivate;
							case _: throw new UnexpectedTokenException(token);
						}
					}
					ctx.stream.expect(T_EQUAL);
					//TODO: parse value to figure out constant type
					ctx.stream.skipValue();
					constants.push(c);
				case T_COMMA:
				case T_SEMICOLON: break;
				case _:
					throw new UnexpectedTokenException(token);
			}
		}


		return constants;
	}

	function parseVar(ctx:Context, name:String):PVar {
		var v = new PVar(name);

		for(token in ctx.consumeStoredTokens()) {
			switch token.type {
				case T_DOC_COMMENT: v.doc = token.value;
				case T_VAR: v.visibility = VPublic;
				case T_PUBLIC: v.visibility = VPublic;
				case T_PROTECTED: v.visibility = VProtected;
				case T_PRIVATE: v.visibility = VPrivate;
				case T_STATIC: v.isStatic = true;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		for (token in ctx.stream) {
			switch token.type {
				//end of var declaration
				case T_SEMICOLON:
					break;
				//end of argument
				case T_COMMA:
					break;
				//end of arguments list
				case T_RIGHT_PARENTHESIS:
					ctx.stream.back();
					break;
				//default value
				case T_EQUAL:
					//TODO: parse value to figure out var type
					ctx.stream.skipValue();
				case _:
					throw new UnexpectedTokenException(token);
			}
		}

		return v;
	}
}