package peg.parser;

using peg.parser.Tools;

class Tools {
	static public inline function expect(stream:TokenStream, type:TokenType) {
		var token = stream.next();
		if(token.type != type) {
			throw new UnexpectedTokenException(token);
		}
	}

	static public inline function skipTo(stream:TokenStream, tokenType:TokenType) {
		while(stream.next().type != tokenType) {}
	}

	static public function skipBalancedTo(stream:TokenStream, type:TokenType) {
		switch type {
			case T_RIGHT_CURLY | T_RIGHT_SQUARE | T_RIGHT_PARENTHESIS:
			case _: throw new PegException('Invalid token type for skipBalancedTo: $type');
		}

		inline function validateEnd(token:Token) {

		}

		for (token in stream) {
			switch token.type {
				case T_RIGHT_CURLY | T_RIGHT_SQUARE | T_RIGHT_PARENTHESIS:
					if(token.type == type) break;
					throw new UnexpectedTokenException(token);
				case T_LEFT_CURLY:
					stream.skipBalancedTo(T_RIGHT_CURLY);
				case T_LEFT_SQUARE:
					stream.skipBalancedTo(T_RIGHT_SQUARE);
				case T_LEFT_PARENTHESIS:
					stream.skipBalancedTo(T_RIGHT_PARENTHESIS);
				case _:
			}
		}
	}
}