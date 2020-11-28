package peg;

import haxe.macro.Expr;
import haxe.macro.Printer;
import sys.io.File;
import peg.generator.NamespaceTree.Node;
import haxe.io.Path;
import peg.generator.*;
import peg.php.*;
import peg.php.PType;
import peg.ExprGenerator.nullPos;

using sys.FileSystem;
using StringTools;
using peg.generator.Keywords;
using peg.ExprGenerator;

class ExprGenerator {
	public static final nullPos = { file:'?', min:-1, max:-1 }

	public final dstDir:String;
	final namespaces:ReadOnlyArray<PNamespace>;
	final fileGenerated:()->Void;
	final allDone:()->Void;
	final printer = new Printer();

	public function new(namespaces:ReadOnlyArray<PNamespace>, dstDir:String, fileGenerated:()->Void, allDone:()->Void) {
		this.namespaces = namespaces;
		this.dstDir = dstDir;
		this.fileGenerated = fileGenerated;
		this.allDone = allDone;
	}

	public function run() {
		var root = NamespaceTree.build(namespaces);
		generate(root);
		allDone();
	}

	function generate(node:Node) {
		var phpNamespace = node.getNamespace();
		var hxPack = phpNamespace.phpNamespace2HxPack();
		for(ns in node.parsedData) {
			for(cls in ns.classes) {
				var definition = cls.toTypeDefinition(phpNamespace, hxPack);
				var content = printer.printTypeDefinition(definition);
				writeModule(hxPack, definition.name, content);
			}
		}
		for(node in node.children) {
			generate(node);
		}
	}

	inline function packageDir(haxePackage:Array<String>):String {
		return Path.join([dstDir, Path.join(haxePackage)]);
	}

	@:allow(peg.generator)
	function writeModule(pack:Array<String>, name:String, content:String) {
		var dir = packageDir(pack);
		dir.createDir();
		var filePath = Path.join([dir, '$name.hx']);
		File.saveContent(filePath, content);
		fileGenerated();
	}
}

class Tools {
	/**
	 * Recursively create a directory.
	 * Does nothing if directory already exists.
	 */
	public static function createDir(dir:String) {
		var path = new Path(dir);
		switch path.dir {
			case null:
			case parentDir if(!parentDir.exists()): parentDir.createDir();
		}
		if(!dir.exists()) {
			dir.createDirectory();
		}
	}

	public static function phpNamespace2HxPack(php:Array<String>):Array<String> {
		return php.length == 0 ? ['php'] : php.map(s -> s.toLowerCase().toHx());
	}

	public static function toNativeMeta(name:String):MetadataEntry {
		return {
			name: ':native',
			params: [{ expr: EConst(CString(name.replace('\\', '\\\\'))), pos: nullPos }],
			pos: nullPos
		}
	}

	public static function phpTypeToTypePath(type:String):TypePath {
		return switch type {
			case 'string': {pack:[], name:'String'}
			case 'bool': {pack:[], name:'Bool'}
			case 'float': {pack:[], name:'Float'}
			case 'int': {pack:[], name:'Int'}
			case 'object': {pack:[], name:'Any'}
			case 'array': {pack:['php'], name:'NativeArray'}
			case _:
				var parts = type.split('\\');
				var name = parts.pop();
				{
					pack: parts.phpNamespace2HxPack(),
					name: name.charAt(0).toUpperCase() + name.substr(1),
					// ?params:Array<TypeParam>,
					// var ?sub:String
				}
		}
	}
}

class PClassTools {
	public static function toTypeDefinition(cls:PClass, phpNamespace:Array<String>, hxPack:Array<String>):TypeDefinition {
		var ns = phpNamespace.join('\\');
		var superClass = cls.parent.let(Tools.phpTypeToTypePath);
		var interfaces = cls.interfaces.map(Tools.phpTypeToTypePath);
		return {
			pack: hxPack,
			name: cls.name.charAt(0).toUpperCase() + cls.name.substr(1),
			doc: cls.doc == '' ? null : cls.doc,
			pos: nullPos,
			meta: [(ns + '\\' + cls.name).toNativeMeta()],
			// ?params:Array<TypeParamDecl>,
			isExtern: true,
			kind: TDClass(superClass, interfaces, cls.isInterface, cls.isFinal, cls.isAbstract),
			fields: cls.constants.map(PConstTools.toField)
		}
	}
}

class PTypeTools {
	public static inline function toTypeParam(type:PType):TypeParam {
		return TPType(type.toComplexType());
	}

	public static inline function toComplexType(type:PType):ComplexType {
		return TPath(type.toTypePath());
	}

	public static function toTypePath(type:PType):TypePath {
		return switch type {
			case TNull:
				{pack:[], name:'Null', params:[TMixed.toTypeParam()]};
			case TInt:
				{pack:[], name:'Int'};
			case TFloat:
				{pack:[], name:'Float'};
			case TString:
				{pack:[], name:'String'};
			case TBool:
				{pack:[], name:'Bool'};
			case TVoid:
				{pack:[], name:'Void'};
			case TArray(TMixed, _):
				{pack:['php'], name:'NativeArray'}
			case TArray(TInt, item):
				{pack:['php'], name:'NativeIndexedArray', params:[item.toTypeParam()]}
			case TArray(_, item):
				{pack:['php'], name:'NativeAssocArray', params:[item.toTypeParam()]}
			case TCallable:
				{pack:['haxe'], name:'Constraints', sub:'Function'}
			case TMixed:
				{pack:[], name:'Any'}
			case TClass(name):
				name.phpTypeToTypePath();
			case TOr(types):
				types.toEitherType();
			// TODO:
			// Make proper Haxe types for these
			case TIterable: {pack:[], name:'Any'};
			case TObject: {pack:[], name:'Any'};
		}
	}

	public static function toEitherType(types:ReadOnlyArray<PType>):TypePath {
		var nullable = types.indexOf(TNull) >= 0;
		if(nullable) {
			var copy = types.copy();
			copy.remove(TNull);
			types = copy;
		}
		var haxeExternPack = ['haxe','extern'];
		function loop(idx:Int):TypePath {
			if(idx >= types.length) {
				return TMixed.toTypePath();
			} else if(idx + 1 == types.length) {
				return types[idx].toTypePath();
			} else {
				var current = types[idx].toTypePath();
				var nextPath = loop(idx + 1);
				return {
					pack:haxeExternPack,
					name:'EitherType',
					params:[TPType(TPath(current)), TPType(TPath(nextPath))]
				}
			}
		}
		var tPath = loop(0);
		return nullable ? {pack:[], name:'Null', params:[TPType(TPath(tPath))]} : tPath;
	}
}

class VisibilityTools {
	public static function toAccess(v:Visibility):Access {
		return switch v {
			case VPublic: APublic;
			case VPrivate: APrivate;
			case VProtected: APrivate;
		}
	}
}

class PConstTools {
	public static function toField(c:PConst):Field {
		return {
			name: c.name.toHx(),
			doc: c.doc == '' ? null : c.doc,
			access: [AFinal, c.visibility.toAccess()],
			kind: FVar(c.type.toComplexType()),
			pos: nullPos,
			meta: [{ name: ':phpClasConst', pos: nullPos }],
		}
	}
}