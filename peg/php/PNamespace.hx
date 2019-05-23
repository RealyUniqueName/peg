package peg.php;

class PNamespace {
	public final name:String;

	public var uses(get,never):ReadOnlyArray<PUse>;
	public var classes(get,never):ReadOnlyArray<PClass>;

	final _uses:Array<PUse> = [];
	final _classes:Array<PClass> = [];

	public function new(name:String) {
		this.name = name;
	}

	public function addUse(type:String, alias:String) {
		_uses.push({type:type, alias:alias});
	}

	public function addClass(cls:PClass) {
		_classes.push(cls);
	}

	inline function get_uses() return _uses;
	inline function get_classes() return _classes;
}