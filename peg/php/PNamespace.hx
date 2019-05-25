package peg.php;

@:allow(peg.Parser)
class PNamespace {
	public final name:String;

	public var uses(get,never):ReadOnlyArray<PUse>;
	public var classes(get,never):ReadOnlyArray<PClass>;
	public var functions(get,never):ReadOnlyArray<PFunction>;
	public var constants(get,never):ReadOnlyArray<PConst>;

	final _uses:Array<PUse> = [];
	final _classes:Array<PClass> = [];
	final _constants:Array<PConst> = [];
	final _functions:Array<PFunction> = [];

	public function new(name:String) {
		this.name = name;
	}

	public function addUses(uses:Array<PUse>) {
		for (u in uses) {
			_uses.push(u);
		}
	}

	public function addClass(cls:PClass) {
		_classes.push(cls);
	}

	function addConst(c:PConst) {
		_constants.push(c);
	}

	function addFunction(fn:PFunction) {
		_functions.push(fn);
	}

	inline function get_uses() return _uses;
	inline function get_classes() return _classes;
	inline function get_constants() return _constants;
	inline function get_functions() return _functions;
}