package peg.generator.writers;

import peg.php.PVar;
using StringTools;

class VarWriter extends FieldWriter {

	static public function fromPhpVar(phpVar:PVar, module:ModuleWriter):VarWriter {
		var hxVar = new VarWriter(phpVar.name);
		hxVar.doc = phpVar.doc;
		hxVar.isPrivate = phpVar.visibility == VProtected;
		hxVar.isStatic = phpVar.isStatic;
		hxVar.type = HxType.fromPType(phpVar.type, module);
		return hxVar;
	}

	override function toString():String {
		var kwd = accessors.remove('final') ? 'final' : 'var';
		return '$doc$indentation${joinSpace(meta)}${joinSpace(accessors)}$kwd $name:$type;\n';
	}
}