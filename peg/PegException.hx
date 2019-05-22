package peg;

class PegException extends haxe.Exception {}

/**
 * Failures on running php interpreter.
 */
class PhpException extends PegException {}

class UnexpectedTokenException extends PegException {
	public function new(token:Token, ?msg:String) {
		var tokenStr = token.type == token.value ? token.value : '${token.type}(${token.value})';
		super('Unexpected token $tokenStr at line ${token.line}' + (msg == null ? '' : ': $msg'));
	}
}