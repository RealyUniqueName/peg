package peg.php;

@:allow(peg.Parser)
class PClass {
	public final name:String;

	public var isFinal(default,null):Bool = false;
	public var doc(default,null):String = '';

	public var functions(get,never):ReadOnlyArray<PFunction>;
	public var vars(get,never):ReadOnlyArray<PVar>;

	final _functions:Array<PFunction> = [];
	final _vars:Array<PVar> = [];

	function new(name:String) {
		this.name = name;
	}

	function addFunction(fn:PFunction) {
		_functions.push(fn);
	}

	function addVar(v:PVar) {
		_vars.push(v);
	}

	inline function get_functions() return _functions;
	inline function get_vars() return _vars;
}