package peg;

import haxe.io.Eof;
import haxe.io.Input;
import haxe.Exception;
import haxe.io.Error;
import haxe.io.BytesBuffer;
import haxe.Json;
import sys.io.Process;

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
		inline function read(io:Input, buf:BytesBuffer) {

		}

		var p = new Process('/home/alex/.phpenv/shims/php', args);
		var stdout = new BytesBuffer();
		while(true) {
			try {
				stdout.addByte(p.stdout.readByte());
			} catch(e:Error) {
				switch e {
					case Blocked:
					case e: throw Exception.wrapWithStack(e);
				}
			} catch(e:Eof) {
				break;
			}
		}
		var exitCode = p.exitCode(true);
		var result = {
			exitCode: exitCode.sure(),
			stderr: p.stderr.readAll().toString(),
			stdout: stdout.getBytes().toString()
		}
		p.close();
		return result;
	}
}
