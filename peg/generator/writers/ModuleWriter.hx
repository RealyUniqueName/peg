package peg.generator.writers;

using StringTools;

enum abstract TypeKind(String) to String {
	var TKClass = 'class';
	var TKInterface = 'interface';
}

class ModuleWriter extends SymbolWriter {

	public var isTrait(never,set):Bool;
	public var isInterface(never,set):Bool;
	public var isAbstract(never,set):Bool;

	public final fields:Array<FieldWriter> = [];

	final pack:String;

	var typeKind:TypeKind = TKClass;

	final imports:Array<String> = [];
	final implementsInterfaces:Array<String> = [];
	final extendsTypes:Array<String> = [];

	public function new(pack:String, name:String) {
		super(name);
		this.pack = pack;
	}

	public function addImport(typePath:PhpTypePath, alias:Null<String>) {
		imports.push(alias == null ? typePath : '$typePath as $alias');
	}

	public function addExtends(typePath:PhpTypePath) {
		extendsTypes.push(typePath);
	}

	public function addImplements(typePath:PhpTypePath) {
		implementsInterfaces.push(typePath);
	}

	function set_isTrait(v) {
		if(v) typeKind = TKInterface;
		return v;
	}

	function set_isInterface(v) {
		if(v) typeKind = TKInterface;
		return v;
	}

	inline function set_isAbstract(v) {
		if(v) meta.push('@:abstract\n');
		return v;
	}

	override public function toString():String {
		inline function keywordJoin(word:String, arr:Array<String>):String {
			return joinSpace(arr.map(s -> '$word $s'));
		}

		var extendsStr = keywordJoin('extends', extendsTypes);
		var implementsStr = keywordJoin('implements', implementsInterfaces);

		var importsStr = imports.map(s -> 'import $s;\n').join('');
		if(imports.length > 0) {
			importsStr = '\n$importsStr';
		}

		return
'package $pack;
$importsStr
$doc${meta.join('')}extern ${joinSpace(accessors)}$typeKind $name$extendsStr$implementsStr {
${fields.join('\n')}
}';
	}
}