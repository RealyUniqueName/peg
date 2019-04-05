package peg;

import haxe.ds.ReadOnlyArray;

enum PhpType {
	PTVoid;
	PTClass(cls:PhpClass);
	PTEither(types:ReadOnlyArray<PhpType>);
}

@:structInit
class PhpClass {
	public final doc:String;
	public final namespace:String;
	public final name:String;
	public final fields:ReadOnlyArray<PhpField>;
	public final isFinal:Bool;
	public final isAbstract:Bool;
}

@:structInit
class PhpField {
	public final doc:String;
	public final isStatic:Bool;
	public final visibility:FieldVisibility;
	public final kind:FieldKind;
}

@:structInit
class PhpArgument {
	public final name:String;
	public final type:PhpType;
	public final isOptional:Bool;
}

enum FieldVisibility {
	FVPublic;
	FVProtected;
	FVPrivate;
}

enum FieldKind {
	FKVar(type:PhpType);
	FKConst(type:PhpType);
	FKMethod(arguments:ReadOnlyArray<PhpArgument>, returnType:PhpType, isAbstract:Bool);
}