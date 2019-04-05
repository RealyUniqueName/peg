package peg;

class PhpFile {
	public final path:String;

	public function new(path:String) {
		this.path = path;
	}

	public function parse() {
		throw 'Not implemented';
	}
}