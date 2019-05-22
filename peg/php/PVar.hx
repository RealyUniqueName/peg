package peg.php;

@:allow(peg.Parser)
class PVar {
	public final name:String;

	public var isStatic(default,null):Bool = false;
	public var visibility(default,null):Visibility = VPublic;
	public var doc(default,null):String = '';

	function new(name:String) {
		this.name = name;
	}
}