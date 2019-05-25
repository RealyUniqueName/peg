package peg.parser;

class TokenStream {
	public var depleted(get,never):Bool;

	final tokens:ReadOnlyArray<Token>;
	var index = 0;

	public function new(tokens:ReadOnlyArray<Token>) {
		this.tokens = tokens;
	}

	public inline function hasNext():Bool {
		return !depleted;
	}

	public inline function next():Token {
		if(depleted) {
			throw new ParserException('Unexpected end of file');
		}
		return tokens[index++];
	}

	/**
	 * Rewind stream to the previous token
	 */
	public function back() {
		if(index == 0) {
			throw new ParserException('Cannot go back');
		}
		index--;
	}

	public function copy():TokenStream {
		var stream = new TokenStream(tokens);
		stream.index = index;
		return stream;
	}

	inline function get_depleted() return index >= tokens.length;
}