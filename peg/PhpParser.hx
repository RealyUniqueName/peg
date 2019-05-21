package peg;

import peg.PhpLexer;
import haxe.ds.ReadOnlyArray;

class UnexpectedTokenException extends PegException {
	public function new(token:Token, ?msg:String) {
		super('Unexpected token ${token.type} at line ${token.line}' + (msg == null ? '' : ': $msg'));
	}
}

class PhpParser {
	final tokens:ReadOnlyArray<Token>;

	public function new(tokens:ReadOnlyArray<Token>) {
		this.tokens = tokens;
	}

	public inline function parse():ReadOnlyArray<PNamespace> {
		var ctx = new Context(new TokenStream(tokens));

		while(!ctx.stream.depleted) {
			var token = ctx.stream.next();
			switch token.type {
				//any html before <?php
				case T_INLINE_HTML:
				//<?php
				case T_OPEN_TAG:
				//<?="str"?>
				case T_OPEN_TAG_WITH_ECHO:
					skipTo(ctx.stream, T_CLOSE_TAG);
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
				case _:
					// throw new UnexpectedTokenException(token);
			}
		}
		return ctx.namespaces;
	}

	function skipTo(stream:TokenStream, tokenType:TokenType) {
		while(stream.next().type != tokenType) {}
	}

	function parseNamespace(ctx:Context):String {
		var name = '';
		while(!ctx.stream.depleted) {
			var token = ctx.stream.next();
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
		var doc = '';
		var isFinal = false;

		var stored = ctx.consumeStoredTokens();
		while(!stored.depleted) {
			var token = stored.next();
			switch token.type {
				case T_DOC_COMMENT: doc = token.value;
				case T_FINAL: isFinal = true;
				case _: throw new UnexpectedTokenException(token);
			}
		}

		var token = ctx.stream.next();
		var name = switch token.type {
			case T_STRING: token.value;
			case _: throw new UnexpectedTokenException(token);
		}

		// TODO: parse class body

		return {
			name: name,
			isFinal: isFinal,
			doc: doc
		}
	}
}

private class Context {
	public final stream:TokenStream;

	public var namespaces(get,never):ReadOnlyArray<PNamespace>;
	final _namespaces:Array<PNamespace> = [];

	var currentNamespace:Null<PNamespace>;
	var storedTokens:Array<Token> = [];

	public function new(stream:TokenStream) {
		this.stream = stream;
	}

	public function pushNamespace(ns:PNamespace) {
		_namespaces.push(ns);
		currentNamespace = ns;
	}

	public function getNamespace():PNamespace {
		return switch(currentNamespace) {
			case null:
				var ns = new PNamespace('');
				_namespaces.push(ns);
				ns;
			case ns: ns;
		}
	}

	public function storeToken(token:Token) {
		storedTokens.push(token);
	}

	public function consumeStoredTokens():TokenStream {
		var result = new TokenStream(storedTokens);
		storedTokens = [];
		return result;
	}

	inline function get_namespaces() return _namespaces;
}

class TokenStream {
	public var depleted(get,never):Bool;

	final tokens:ReadOnlyArray<Token>;
	var index = 0;

	public function new(tokens:ReadOnlyArray<Token>) {
		this.tokens = tokens;
	}

	public function next():Token {
		if(depleted) {
			throw new PegException('Unexpected end of file');
		}
		return tokens[index++];
	}

	/**
	 * Rewind stream to the previous token
	 */
	public function back() {
		if(index == 0) {
			throw new PegException('Cannot go back');
		}
		index--;
	}

	inline function get_depleted() return index >= tokens.length;
}

class PNamespace {
	public final name:String;

	public var uses(get,never):ReadOnlyArray<String>;
	public var classes(get,never):ReadOnlyArray<PClass>;

	final _uses:Array<String> = [];
	final _classes:Array<PClass> = [];

	public function new(name:String) {
		this.name = name;
	}

	public function addUse(namespace:String) {
		_uses.push(namespace);
	}

	public function addClass(cls:PClass) {
		_classes.push(cls);
	}

	inline function get_uses() return _uses;
	inline function get_classes() return _classes;
}

@:structInit
class PClass {
	final name:String;
	final isFinal:Bool;
	final doc:String;
}