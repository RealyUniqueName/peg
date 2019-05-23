package peg.php;

@:allow(peg.Parser)
class PFunction {
	public final name:String;

	public var isAbstract(default,null):Bool = false;
	public var isFinal(default,null):Bool = false;
	public var isStatic(default,null):Bool = false;
	public var visibility(default,null):Visibility = VPublic;
	public var doc(default,null):String = '';

	public var args(get,never):ReadOnlyArray<PVar>;

	final _args:Array<PVar> = [];

	function new(name:String) {
		this.name = name;
	}

	function addArg(arg:PVar) {
		_args.push(arg);
	}

	inline function get_args() return _args;
}