package peg.parser;

import peg.php.*;

class Context {
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
				currentNamespace = ns;
			case ns: ns.sure();
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