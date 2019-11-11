package peg;

import sys.io.File;
import peg.generator.NamespaceTree.Node;
import haxe.io.Path;
import peg.generator.*;
import peg.php.*;

using sys.FileSystem;

class Generator {
	public final dstDir:String;
	final namespaces:ReadOnlyArray<PNamespace>;
	final fileGenerated:()->Void;
	final allDone:()->Void;

	public function new(namespaces:ReadOnlyArray<PNamespace>, dstDir:String, fileGenerated:()->Void, allDone:()->Void) {
		this.namespaces = namespaces;
		this.dstDir = dstDir;
		this.fileGenerated = fileGenerated;
		this.allDone = allDone;
	}

	public function run() {
		// createDir(dstDir);
		var root = NamespaceTree.build(namespaces);
		generate(root);
		allDone();
	}

	function generate(node:Node) {
		var nsGen = new NamespaceGenerator(node, this);
		nsGen.run();
		for (node in node.children) {
			generate(node);
		}
	}

	inline function packageDir(haxePackage:Array<String>):String {
		return Path.join([dstDir, Path.join(haxePackage)]);
	}

	@:allow(peg.generator)
	function writeModule(pack:Array<String>, name:String, content:String) {
		var dir = packageDir(pack);
		createDir(dir);
		var filePath = Path.join([dir, '$name.hx']);
		File.saveContent(filePath, content);
		fileGenerated();
	}

	/**
	 * Recursively create a directory.
	 * Does nothing if directory already exists.
	 */
	static function createDir(dir:String) {
		var path = new Path(dir);
		switch path.dir {
			case null:
			case parentDir if(!parentDir.exists()): createDir(parentDir);
		}
		if(!dir.exists()) {
			dir.createDirectory();
		}
	}
}