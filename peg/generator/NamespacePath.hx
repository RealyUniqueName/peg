package peg.generator;

abstract NamespacePath(Array<String>) {
	public var name(get,never):String;

	public inline function new(ns:String) {
		this = trimSlash(ns).split('\\');
	}

	static inline function trimSlash(ns:String):String {
		return ns.charAt(0) == '\\' ? ns.substr(1) : ns;
	}

	inline function get_name() return this[this.length - 1];
	
}