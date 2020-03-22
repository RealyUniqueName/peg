package peg.generator;

using StringTools;

abstract HxTypePath(String) to String {
	@:from
	static inline function fromString(phpTypePath:String) {
		var fullPath = phpTypePath.charAt(0) == '\\';
		var rootNamespace = fullPath && phpTypePath.indexOf('\\', 1) < 0;
		return new HxTypePath(rootNamespace ? 'php.$phpTypePath' : phpTypePath.replace('\\', '.'));
	}

	inline function new(s:String) {
		this = s;
	}
}