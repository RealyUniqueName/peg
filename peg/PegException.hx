package peg;

class PegException extends haxe.Exception {}

/**
 * Failures on running php interpreter.
 */
class PhpException extends PegException {}

class ParserException extends PegException {}

class UnexpectedTokenException extends ParserException {
	public final token:Token;

	public function new(token:Token, ?expected:TokenType) {
		this.token = token;
		var expectedStr = expected == null ? '' : '; expected $expected';
		super('Unexpected token ${token.toString()} at line ${token.line}' + expectedStr);
	}
}