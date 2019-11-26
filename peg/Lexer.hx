package peg;

import haxe.io.Eof;
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

	macro static function lex(phpFile:haxe.macro.Expr):haxe.macro.Expr.ExprOf<Array<Any>>;

	static function tokenize(phpFile:String):Array<Token> {

		var rawTokens:Array<Any> = lex(phpFile);
		// trace(rawTokens.map(Std.string).join('\n'));
		return rawTokens.map(tokenData -> new Token(tokenData));
	}

	/**
	 * Execute php interpreter with given arguments
	 */
	static function tokenizeThroughPhp(phpSourceFile:String, lexerPhpScript:String):{stdout:String, stderr:Null<String>, exitCode:Int} {
		var result;
		#if nodejs
			var p = js.node.ChildProcess.spawnSync('php', [lexerPhpScript, phpSourceFile]);
			result = {
				stdout: p.stdout,
				stderr: p.stderr,
				exitCode: p.status
			}
		#else
			var p = new Process('php', [lexerPhpScript, phpSourceFile]);
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
			var exitCode = p.exitCode(true).sure();
			result = {
				exitCode: exitCode,
				stderr: (exitCode == 0 ? null : p.stderr.readAll().toString()),
				stdout: stdout.getBytes().toString()
			}
			p.close();
		#end
		return result;
	}
}
