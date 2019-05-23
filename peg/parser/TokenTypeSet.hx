package peg.parser;

abstract TokenTypeSet(Array<TokenType>) from Array<TokenType> {
	@:from
	static inline function fromSingleToken(type:TokenType):TokenTypeSet {
		return [type];
	}

	public inline function contains(type:TokenType):Bool {
		return this.indexOf(type) >= 0;
	}
}