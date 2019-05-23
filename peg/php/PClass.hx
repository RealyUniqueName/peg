package peg.php;

@:allow(peg.Parser)
class PClass {
	public final name:String;

	public var isInterface(default,null):Bool = false;
	public var isFinal(default,null):Bool = false;
	public var isAbstract(default,null):Bool = true;
	public var doc(default,null):String = '';
	public var parent(default,null):Null<String>;

	public var interfaces(get,never):ReadOnlyArray<String>;
	public var constants(get,never):ReadOnlyArray<PConst>;
	public var vars(get,never):ReadOnlyArray<PVar>;
	public var functions(get,never):ReadOnlyArray<PFunction>;

	final _interfaces:Array<String> = [];
	final _constants:Array<PConst> = [];
	final _vars:Array<PVar> = [];
	final _functions:Array<PFunction> = [];

	function new(name:String) {
		this.name = name;
	}

	function addInterface(i:String) {
		_interfaces.push(i);
	}

	function addConst(c:PConst) {
		_constants.push(c);
	}

	function addVar(v:PVar) {
		_vars.push(v);
	}

	function addFunction(fn:PFunction) {
		_functions.push(fn);
	}


	inline function get_interfaces() return _interfaces;
	inline function get_constants() return _constants;
	inline function get_vars() return _vars;
	inline function get_functions() return _functions;
}