package peg;

import peg.PhpParser;
import haxe.ds.ReadOnlyArray;

class PhpFile {
	public final path:String;

	public function new(path:String) {
		this.path = path;
	}

	public function parse():ReadOnlyArray<PNamespace> {
		var lexer = new PhpLexer(path);
		var parser = new PhpParser(lexer.tokens);
		return parser.parse();
	}
}