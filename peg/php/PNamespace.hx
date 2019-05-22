package peg.php;

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