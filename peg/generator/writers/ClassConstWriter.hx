package peg.generator.writers;

import peg.php.PConst;

class ClassConstWriter extends VarWriter {

	static public function fromPhpConst(phpConst:PConst, module:ModuleWriter):ClassConstWriter {
		var hxVar = new ClassConstWriter(phpConst.name);
		hxVar.doc = phpConst.doc;
		hxVar.isPrivate = phpConst.visibility == VProtected;
		hxVar.type = HxType.fromPType(phpConst.type, module);
		return hxVar;
	}

	public function new(name:String) {
		super(name);
		isFinal = true;
		isStatic = true;
		meta.push('@:phpClassConst');
	}
}