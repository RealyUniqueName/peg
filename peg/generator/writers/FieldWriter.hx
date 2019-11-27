package peg.generator.writers;

class FieldWriter extends SymbolWriter {
	public var type:String = 'Any';
	public var isStatic(never,set):Bool;
	public var isPrivate(never,set):Bool;

	public function new(name:String) {
		super(name);
		indentation = '\t';
	}

	function set_isPrivate(v:Bool):Bool {
		setAccessor('private', v);
		return v;
	}

	function set_isStatic(v:Bool):Bool {
		setAccessor('static', v);
		return v;
	}

	// override function set_doc(s:String):String {
	// 	super.set_doc(s);
	// 	if(doc != '') {
	// 		doc = '$indentation$doc';
	// 	}
	// 	return s;
	// }
}