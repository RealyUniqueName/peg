package peg.generator.writers;

import peg.php.PFunction;
import peg.php.PVar;

class MethodWriter extends FieldWriter {
	var args:Array<String> = [];

	static public function fromPhpFunction(fn:PFunction, m:ModuleWriter) {
		var hxMethod = new MethodWriter(fn.name);
		hxMethod.doc = fn.doc;
		if(!fn.isStatic) {
			hxMethod.isFinal = fn.isFinal;
		}
		hxMethod.isPrivate = fn.visibility != VPublic;
		hxMethod.isStatic = fn.isStatic;
		if(fn.isAbstract) {
			hxMethod.meta.push('@:php.abstract');
		}
		hxMethod.type = HxType.fromPType(fn.returnType, m);
		hxMethod.setArgs(fn.args, m);
		return hxMethod;
	}

	inline function setArgs(args:ReadOnlyArray<PVar>, m:ModuleWriter) {
		for (a in args) {
			var name = (a.name:HxIdent);
			var type = HxType.fromPType(a.type, m);
			var optional = a.hasValue ? '?' : '';
			this.args.push('$optional$name:$type');
		}
	}

	override function toString():String {
		return '$doc$indentation${joinSpace(meta)}${joinSpace(accessors)}function $name(${args.join(', ')}):$type;\n';
	}
}