package peg;

import peg.php.PNamespace;
import haxe.ds.ReadOnlyArray;

class SourceFile {
	public final path:String;

	public function new(path:String) {
		this.path = path;
	}

	public function parse():ReadOnlyArray<PNamespace> {
		var lexer = new Lexer(path);
		var parser = new Parser(lexer.tokens);
		return parser.parse();
	}
}