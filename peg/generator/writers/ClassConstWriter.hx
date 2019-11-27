package peg.generator.writers;

class ClassConstWriter extends VarWriter {
	public function new(name:String) {
		super(name);
		isFinal = true;
		isStatic = true;
		meta.push('@:phpClassConst');
	}
}