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

	static function tokenize(phpFile:String):Array<Token> {
		var result = tokenizeThroughPhp(phpFile);
		if(result.exitCode != 0) {
			throw new PhpException('Failed to run php: ${result.stderr}');
		}

		var rawTokens:Array<Any> = try {
			Json.parse(result.stdout);
		} catch(e:Dynamic) {
			throw new PegException('Failed to parse json: ${result.stdout}', Exception.wrapWithStack(e));
		}
		// trace(rawTokens.map(Std.string).join('\n'));
		return rawTokens.map(tokenData -> new Token(tokenData));
	}

	/**
	 * Execute php interpreter with given arguments
	 */
	static function tokenizeThroughPhp(phpSourceFile:String, lexerPhpScript:String = 'lexer.php'):{stdout:String, stderr:Null<String>, exitCode:Int} {
		var result;
		#if nodejs
			var p = js.node.ChildProcess.spawnSync('php', [lexerPhpScript, phpSourceFile]);
			result = {
				stdout: p.stdout,
				stderr: p.stderr,
				exitCode: p.status
			}
		#elseif php
			php.Global.require_once(lexerPhpScript);
			var stderr:Null<String> = null;
			var stdout = try {
				php.Syntax.code('tokenize({0})', phpSourceFile);
			} catch(e:php.Throwable) {
				stderr = e.getMessage();
				'';
			}
			return {
				exitCode: stderr == null ? 0 : 1,
				stderr: stderr,
				stdout: stdout
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
