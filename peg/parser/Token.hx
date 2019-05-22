package peg.parser;

abstract Token(Array<Any>) {
	public var type(get,never):TokenType;
	public var value(get,never):String;
	/** At which line of the source php code this token was found */
	public var line(get,never):Int;

	@:allow(peg.Lexer)
	inline function new(rawToken:Array<Any>) {
		if(rawToken.length != 3) {
			throw new PegException('Invalid token data');
		}
		this = rawToken;
	}

	inline function get_type():TokenType {
		return this[0];
	}

	inline function get_value():String {
		return this[1];
	}

	inline function get_line():Int {
		return this[2];
	}
}
