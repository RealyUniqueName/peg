package peg.generator;

using StringTools;

abstract HxImportTypePath(String) to String {
	@:from
	static inline function fromString(phpTypePath:String) {
		if(phpTypePath.charAt(0) == '\\') {
			phpTypePath = phpTypePath.substr(1);
		}
		var rootNamespace = phpTypePath.indexOf('\\') < 0;
		return new HxImportTypePath(rootNamespace ? 'php.$phpTypePath' : phpTypePath.replace('\\', '.'));
	}

	inline function new(s:String) {
		this = s;
	}
}