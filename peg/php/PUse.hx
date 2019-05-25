package peg.php;

import peg.php.Visibility;

@:using(peg.php.PUse.Tools)
enum PUse {
	/** use some\MyClass as MyAlias */
	UClass(type:String, alias:Null<String>);
	/** use function some\myFunc as myFuncAlias */
	UFunction(functionPath:String, alias:Null<String>);
	/** use const some\CONST */
	UConst(constPath:String);
	/** use SomeTrait,AnotherTrait { SomeTrait::someMethod as anotherMethod } */
	UTrait(traitsPaths:Array<String>, ?aliases:Array<MethodAlias>);
}

typedef MethodAlias = {
	final method:Method;
	final alias:Alias;
}

typedef Method = {
	final ?type:String;
	final name:String;
}

typedef Alias = {
	final visibility:Visibility;
	final name:String;
}

class Tools {
	static public function toString(u:PUse):String {
		return switch u {
			case UClass(type, alias): 'use $type' + (alias == null ? '' : ' as $alias');
			case UFunction(functionPath, alias): 'use function $functionPath' + (alias == null ? '' : ' as $alias');
			case UConst(constPath): 'use $constPath';
			case UTrait(traitPath, aliases): 'use $traitPath' + (aliases == null ? '' : ' {...}');
		}
	}
}