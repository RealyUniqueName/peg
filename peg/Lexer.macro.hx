package peg;

import haxe.PosInfos;
import haxe.macro.Context;
import haxe.macro.Expr;

using sys.io.File;
using haxe.io.Path;
using StringTools;

class Lexer {
	static inline var LEXER_PHP = 'lexer.php';

	static function getLexerPhpPath():String {
		var currentFile = (function(?p:PosInfos) return p.fileName)();
		var pegDir = currentFile.directory().directory();
		return Path.join([pegDir, LEXER_PHP]);
	}

	static function lex(phpFile:Expr):ExprOf<Array<Any>> {
		if(Context.defined('display')) {
			return macro null;
		}
		var lexerPhp = getLexerPhpPath();
		//If targeting PHP: inline contents of lexer.php into Lexer.hx code
		if(Context.defined('php')) {
			var php = try {
				lexerPhp.getContent().replace('<?php', '');//.replace('"', '\\"');
			} catch(e:Dynamic) {
				Context.error('Failed to read $lexerPhp: $e', phpFile.pos);
			}
			return macro @:pos(phpFile.pos) {
				if(!php.Global.function_exists('peg\\tokenize')) {
					php.Syntax.code($v{php});
				}
				var stderr:Null<String> = null;
				var phpTokens:php.NativeIndexedArray<php.NativeIndexedArray<Any>> = try {
					php.Syntax.code('tokenize({0})', phpFile);
				} catch(e:php.Throwable) {
					throw new PegException('Failed to tokenize: ' + e.getMessage());
				}
				[for (t in phpTokens) php.Lib.toHaxeArray(t)];
			}
		//For eval: execute `$ php path/to/lexer.php`
		} else {
			return macro @:pos(phpFile.pos) {
				var result = tokenizeThroughPhp($phpFile, $v{lexerPhp});
				if(result.exitCode != 0) {
					throw new PhpException('Failed to run php: ' + result.stderr);
				}
				try {
					Json.parse(result.stdout);
				} catch(e:Dynamic) {
					throw new PegException('Failed to parse json: ' + result.stdout, Exception.wrapWithStack(e));
				}
			}
		}
	}
}
