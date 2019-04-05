package peg;

import haxe.io.BytesInput;
import haxe.io.Bytes

enum Token {
	TWord(word:String);
	TBackslash;
	TDoc(content:Bytes);
	TSemicolon;
	TComma;
	/** `$name` */
	TDollarIdent(name:String);
	/** `=` sign */
	TEqual;
	TOpenParenthesis;
	TCloseParenthesis;
	TOpenCurly;
	TCloseCurly;
	TExpression;
}

enum Context {

}

class PhpLexer {
	final data:BytesInput;
	final tokens:Array<Token> = [];

	public function new(content:Bytes) {
		data = new BytesInput(content);
	}

	public function run() {
		while(data.position < data.length) {
			switch(data.readByte()) {
				case '\\'.code: tokens.push(TBackslash);
				case ';'.code: tokens.push(TSemicolon);
				case ','.code: tokens.push(TComma);
				case '='.code: tokens.push(TEqual);
				case '('.code: tokens.push(TOpenParenthesis);
				case ')'.code: tokens.push(TCloseParenthesis);
				case '{'.code: tokens.push(TOpenCurly);
				case '}'.code: tokens.push(TCloseCurly);
			}
		}
	}
}