package peg;

using haxe.io.Path;
using sys.FileSystem;
using StringTools;

class PhpSourcesIterator {
	final sources:Array<String> = [];
	var index:Int = 0;

	public function new(path:String) {
		readPath(path);
	}

	public inline function hasNext() {
		return index < sources.length;
	}

	public inline function next():PhpFile {
		if(hasNext()) {
			return new PhpFile(sources[index++]);
		} else {
			throw "No more php files";
		}
	}

	function readPath(path:String) {
		path = path.fullPath();
		if(path.isDirectory()) {
			for(entry in path.readDirectory()) {
				readPath(path.addTrailingSlash() + entry);
			}
		} else if(path.toLowerCase().endsWith('.php')) {
			sources.push(path);
		}
	}
}