package peg.generator;

abstract HxIdent(String) to String {
	@:from
	static inline function fromString(s:String):HxIdent {
		return new HxIdent(s.charAt(0) == "$" ? s.substr(1) : s);
	}

	inline function new(s:String) {
		this = s;
	}
}