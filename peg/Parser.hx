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
					ctx.pushNamespace(new PNamespace(parseNamespace(ctx)));
				//use "some\\Class"
				case T_USE:
					ctx.getNamespace().addUse(parseNamespace(ctx));
				//doc block
				case T_DOC_COMMENT:
					ctx.storeToken(token);
				//final
				case T_FINAL:
					ctx.storeToken(token);
				//class MyClass {}
				case T_CLASS:
					ctx.getNamespace().addClass(parseClass(ctx));
				case T_SEMICOLON:
				case _:
					throw new UnexpectedTokenException(token);
			}
		}
		return ctx.namespaces;
	}

	function parseNamespace(ctx:Context):String {
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

	function parseClass(ctx:Context):PClass {
		var token = ctx.stream.next();
		var name = switch token.type {
			case T_STRING: token.value;
			case _: throw new UnexpectedTokenException(token);
		}

		var cls = new PClass(name);

		for(token in ctx.consumeStoredTokens()) {
			switch token.type {
				case T_DOC_COMMENT: cls.doc = token.value;
				case T_FINAL: cls.isFinal = true;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		//extends, implements
		for (token in ctx.stream) {
			switch token.type {
				case T_LEFT_CURLY: break;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		//class body
		for (token in ctx.stream) {
			switch token.type {
				case T_PUBLIC | T_PROTECTED | T_PRIVATE | T_STATIC | T_DOC_COMMENT:
					ctx.storeToken(token);
				case T_FUNCTION:
					cls.addFunction(parseFunction(ctx));
				case T_VARIABLE:
					cls.addVar(parseVar(ctx, token.value));
				case T_RIGHT_CURLY:
					break;
				case _:
					throw new UnexpectedTokenException(token);
			}
		}

		return cls;
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
		ctx.stream.expect(T_LEFT_CURLY);
		ctx.stream.skipBalancedTo(T_RIGHT_CURLY);

		return fn;
	}

	function parseArguments(ctx:Context, fn:PFunction) {
		ctx.stream.expect(T_LEFT_PARENTHESIS);
		for (token in ctx.stream) {
			switch token.type {
				case T_RIGHT_PARENTHESIS: return;
				case T_LEFT_CURLY: ctx.stream.back(); return;
				case T_VARIABLE: fn.addArg(parseVar(ctx, token.value));
				case _: throw new UnexpectedTokenException(token);
			}
		}
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
				case T_SEMICOLON: break;
				//next argument
				case T_COMMA: break;
				//end of arguments list
				case T_RIGHT_PARENTHESIS: ctx.stream.back(); break;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		return v;
	}
}