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

	final imports:Array<{type:String, alias:Null<String>, confirmedForExtern:Bool}> = [];
	final implementsInterfaces:Array<String> = [];
	final extendsTypes:Array<String> = [];

	public function new(pack:String, name:String) {
		super(name);
		this.pack = pack;
	}

	public function addImport(typePath:HxImportTypePath, alias:Null<String>) {
		for(i in 0...imports.length) {
			if(imports[i].type == typePath && imports[i].alias == alias) {
				return;
			}
		}
		imports.push({type:typePath, alias:alias, confirmedForExtern:false});
	}

	public function confirmImport(name:String) {
		for (item in imports) {
			if(item.alias == name || (item.alias == null && item.type == name)) {
				item.confirmedForExtern = true;
			}
		}
	}

	public function addExtends(typePath:HxTypePath) {
		extendsTypes.push(typePath);
	}

	public function addImplements(typePath:HxTypePath) {
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

		var importsStr = imports.filter(i -> i.confirmedForExtern)
			.map(i -> {
				var s = i.alias == null ? i.type : '${i.type} as ${i.alias}';
				'import $s;\n';
			})
			.join('');
		if(importsStr.length > 0) {
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