package peg;

import peg.parser.*;
import peg.php.*;
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
					ctx.stream.expect(T_SEMICOLON);
				//use "some\\Class"
				case T_USE:
					ctx.getNamespace().addUse(parseUse(ctx));
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
				// case T_SEMICOLON:
				case _:
					// TODO: handle namespace-level functions
					// TODO: handle `class_alias()` ?
			}
		}
		return ctx.namespaces;
	}

	function parseUse(ctx:Context):PUse {
		var type = parseTypePath(ctx);
		var token = ctx.stream.next();
		var alias = switch token.type {
			case T_AS:
				var alias = parseTypePath(ctx);
				ctx.stream.expect(T_SEMICOLON);
				alias;
			case T_SEMICOLON:
				'';
			case _:
				throw new UnexpectedTokenException(token);
		}
		return {type:type, alias:alias};
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
			case T_STRING | T_NS_SEPARATOR: TClass(parseTypePath(ctx));
			case T_ARRAY: TArray;
			case T_CALLABLE: TCallable;
			case _: throw new UnexpectedTokenException(token);
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
					cls.addUse(parseUse(ctx));
				case T_PUBLIC | T_PROTECTED | T_PRIVATE | T_STATIC | T_DOC_COMMENT | T_ABSTRACT:
					ctx.storeToken(token);
				case T_FUNCTION:
					cls.addFunction(parseFunction(ctx));
				case T_VARIABLE:
					cls.addVar(parseVar(ctx, token.value));
				case T_RIGHT_CURLY:
					break;
				case T_CONST:
					cls.addConst(parseConst(ctx));
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
				//abstract method - no body
				case T_SEMICOLON:
					break;
				case T_LEFT_CURLY:
					ctx.stream.skipBalancedTo(T_RIGHT_CURLY);
					break;
				case _:
					throw new UnexpectedTokenException(token);
			}
		}

		return fn;
	}

	function parseArguments(ctx:Context, fn:PFunction) {
		ctx.stream.expect(T_LEFT_PARENTHESIS);
		for (token in ctx.stream) {
			switch token.type {
				//end of args
				case T_RIGHT_PARENTHESIS:
					return;
				//$argName
				case T_VARIABLE:
					fn.addArg(parseVar(ctx, token.value));
				//SomeType $arg
				case _:
					ctx.stream.back();
					var type = parseType(ctx);
					var name = ctx.stream.expect(T_VARIABLE);
					var v = parseVar(ctx, name.value);
					v.type = type;
			}
		}
	}

	function parseConst(ctx:Context):PConst {
		var c = new PConst(ctx.stream.expect(T_STRING).value);

		for(token in ctx.consumeStoredTokens()) {
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
		ctx.stream.expect(T_SEMICOLON);

		return c;
	}

	function parseVar(ctx:Context, name:String):PVar {
		var v = new PVar(name);

		for(token in ctx.consumeStoredTokens()) {
			switch token.type {
				case T_DOC_COMMENT: v.doc = token.value;
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