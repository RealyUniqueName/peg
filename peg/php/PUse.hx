package peg.php;

@:using(peg.php.PUse.Tools)
enum PUse {
	/** use some\MyClass as MyAlias */
	UClass(type:String, alias:Null<String>);
	/** use function some\myFunc as myFuncAlias */
	UFunction(functionPath:String, alias:Null<String>);
	/** use const some\CONST */
	UConst(constPath:String);
}

class Tools {
	static public function toString(u:PUse):String {
		return switch u {
			case UClass(type, alias): 'use $type' + (alias == null ? '' : ' as $alias');
			case UFunction(functionPath, alias): 'use function $functionPath' + (alias == null ? '' : ' as $alias');
			case UConst(constPath): 'use $constPath';
		}
	}
}