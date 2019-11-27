package peg.generator.writers;

using StringTools;

class VarWriter extends FieldWriter {

	public function new(name:String) {
		super(name.startsWith("$") ? name.substr(1) : name);
	}

	override function toString():String {
		var kwd = accessors.remove('final') ? 'final' : 'var';
		return '$doc$indentation${joinSpace(meta)}${joinSpace(accessors)}$kwd $name:$type;\n';
	}
}