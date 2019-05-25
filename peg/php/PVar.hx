package peg.php;

@:allow(peg.Parser)
class PVar {
	public final name:String;

	public var isStatic(default,null):Bool = false;
	public var visibility(default,null):Visibility = VPublic;
	public var doc(default,null):String = '';
	public var type(default,null):PType = TMixed;
	/** If was parsed from `...$some` syntax */
	public var isRestArg(default,null):Bool = false;


	function new(name:String) {
		this.name = name;
	}
}