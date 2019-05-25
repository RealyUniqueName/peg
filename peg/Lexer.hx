package peg;

import haxe.io.Eof;
import haxe.Exception;
import haxe.io.Error;
import haxe.io.BytesBuffer;
import haxe.Json;
import sys.io.Process;

class Lexer {
	static inline var LEXER_PHP = 'lexer.php';

	public final tokens:ReadOnlyArray<Token>;

	public function new(phpCode:String) {
		tokens = tokenize(phpCode);
	}

	static function tokenize(phpFile:String):Array<Token> {

		var rawTokens:Array<Any>;
		#if php
			php.Global.require_once(LEXER_PHP);
			var stderr:Null<String> = null;
			var phpTokens:php.NativeIndexedArray<php.NativeIndexedArray<Any>> = try {
				php.Syntax.code('tokenize({0})', phpFile);
			} catch(e:php.Throwable) {
				throw new PegException('Failed to tokenize: ${e.getMessage()}');
			}
			rawTokens = [for (t in phpTokens) php.Lib.toHaxeArray(t)];
		#else
			var result = tokenizeThroughPhp(phpFile, LEXER_PHP);
			if(result.exitCode != 0) {
				throw new PhpException('Failed to run php: ${result.stderr}');
			}
			rawTokens = try {
				Json.parse(result.stdout);
			} catch(e:Dynamic) {
				throw new PegException('Failed to parse json: ${result.stdout}', Exception.wrapWithStack(e));
			}
		#end
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
