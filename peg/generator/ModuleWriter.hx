package peg.generator;

using StringTools;

enum abstract TypeKind(String) to String {
	var TKClass = 'class';
	var TKInterface = 'interface';
}

class ModuleWriter {

	public var doc(default,set):String = '';
	public var native(never,set):String;
	public var isTrait(never,set):Bool;
	public var isInterface(never,set):Bool;
	public var isFinal(never,set):Bool;
	public var isAbstract(never,set):Bool;

	final pack:String;
	final typeName:String;

	var typeKind:TypeKind = TKClass;
	var finalStr:String = '';

	final imports:Array<String> = [];
	final implementsInterfaces:Array<String> = [];
	final extendsTypes:Array<String> = [];
	final meta:Array<String> = [];

	public inline function new(pack:String, typeName:String) {
		this.pack = pack;
		this.typeName = typeName;
	}

	public inline function addImport(typePath:PhpTypePath, alias:Null<String>) {
		imports.push(alias == null ? typePath : '$typePath as $alias');
	}

	public inline function addExtends(typePath:PhpTypePath) {
		extendsTypes.push(typePath);
	}

	public inline function addImplements(typePath:PhpTypePath) {
		implementsInterfaces.push(typePath);
	}

	inline function set_isTrait(v) {
		if(v) typeKind = TKInterface;
		return v;
	}

	inline function set_isInterface(v) {
		if(v) typeKind = TKInterface;
		return v;
	}

	inline function set_isFinal(v) {
		if(v) finalStr = 'final ';
		return v;
	}

	inline function set_isAbstract(v) {
		if(v) meta.push('@:abstract\n');
		return v;
	}

	inline function set_native(v:String) {
		v = v.replace('\\', '\\\\');
		meta.push('@:native("$v")\n');
		return v;
	}

	inline function set_doc(s:String):String {
		doc = '$s\n';
		return s;
	}

	public inline function toString():String {
		inline function join(word:String, arr:Array<String>):String {
			return arr.length == 0 ? '' : ' ' + arr.map(s -> '$word $s').join(' ');
		}

		var extendsStr = join('extends', extendsTypes);
		var implementsStr = join('implements', implementsInterfaces);

		var importsStr = imports.map(s -> 'import $s;\n').join('');
		if(imports.length > 0) {
			importsStr = '\n$importsStr';
		}

		return
'package $pack;
$importsStr
$doc${meta.join('')}extern $finalStr$typeKind $typeName$extendsStr$implementsStr {

}';
	}
}