package peg;

import haxe.Resource;
import haxe.Json;
import sys.io.Process;

using StringTools;

class Lexer {
	public final tokens:ReadOnlyArray<Token>;

	public function new(phpCode:String) {
		tokens = tokenize(phpCode);
	}

	static function tokenize(phpFile:String):Array<Token> {
		var result = php(['lexer.php', phpFile]);
		if(result.exitCode != 0) {
			throw new PhpException('Failed to run php: ${result.stderr}');
		}

		var rawTokens:Array<Any> = Json.parse(result.stdout);
		// trace(rawTokens.map(Std.string).join('\n'));
		return rawTokens.map(tokenData -> new Token(tokenData));
	}

	/**
	 * Execute php interpreter with given arguments
	 */
	static function php(args:Array<String>):{stdout:String, stderr:String, exitCode:Int} {
		var p = new Process('/home/alex/.phpenv/shims/php', args);
		var exitCode = p.exitCode(true);
		var result = {
			exitCode: exitCode.sure(),
			stderr: p.stderr.readAll().toString(),
			stdout: p.stdout.readAll().toString()
		}
		p.close();
		return result;
	}
}
