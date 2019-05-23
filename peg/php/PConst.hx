package peg.php;

@:allow(peg.Parser)
class PConst {
	public final name:String;

	public var visibility(default,null):Visibility = VPublic;
	public var doc(default,null):String = '';
	public var type(default,null):PType = TMixed;

	function new(name:String) {
		this.name = name;
	}
}