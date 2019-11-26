package peg.generator;

abstract HxTypeName(String) to String {
	@:from
	static inline function fromString(s:String):HxTypeName {
		(this.charAt(0) == '\\' ? 'php.${this.substr(1)}' : this)
		return new HxTypeName(s);
	}

	inline function new(s:String) {
		this = s;
	}
}