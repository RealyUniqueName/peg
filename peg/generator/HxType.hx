package peg.generator;

import peg.generator.writers.ModuleWriter;
import peg.php.PType;

abstract HxType(String) to String {
	static public inline var ANY:HxType = new HxType('Any');

	static public function fromPType(t:PType, module:ModuleWriter):HxType {
		var s = switch t {
			case TNull: 'Null<$ANY>';
			case TInt: 'Int';
			case TFloat: 'Float';
			case TString: 'String';
			case TBool: 'Bool';
			case TArray: 'Array<$ANY>';
			case TCallable: 'haxe.Constraints.Function';
			case TMixed: ANY;
			case TClass(name):
				module.confirmImport(name);
				name;
			case TOr(types): fromTOr(types, module);
		}
		return new HxType(s);
	}

	static function fromTOr(types:ReadOnlyArray<PType>, module:ModuleWriter):HxType {
		var nullable = types.indexOf(TNull) >= 0;
		if(nullable) {
			var copy = types.copy();
			copy.remove(TNull);
			types = copy;
		}
		function loop(idx:Int):HxType {
			if(idx >= types.length) {
				return fromPType(TMixed, module);
			} else if(idx + 1 == types.length) {
				return fromPType(types[idx], module);
			} else {
				var current = fromPType(types[idx], module);
				var next = loop(idx + 1);
				module.addImport('haxe.extern.EitherType', null);
				return new HxType('EitherType<$current,$next>');
			}
		}
		var type = loop(0);
		return nullable ? new HxType('Null<$type>') : type;
	}

	inline function new(s:String) {
		this = s;
	}
}