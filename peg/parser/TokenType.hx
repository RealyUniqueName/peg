package peg.parser;

enum abstract TokenType(String) from String {
	var T_EQUAL = '=';
	var T_SEMICOLON = ';';
	var T_COMMA = ',';
	var T_LEFT_CURLY = '{';
	var T_RIGHT_CURLY = '}';
	var T_LEFT_PARENTHESIS = '(';
	var T_RIGHT_PARENTHESIS = ')';
	var T_LEFT_SQUARE = '[';
	var T_RIGHT_SQUARE = ']';

	/** abstract - Class Abstraction */
	var T_ABSTRACT;
	/** &= - assignment operators */
	var T_AND_EQUAL;
	/** array() - array(), array syntax */
	var T_ARRAY;
	/** (array) - type-casting */
	var T_ARRAY_CAST;
	/** as - foreach */
	var T_AS;
	/**  anything below ASCII 32 except \t (0x09), \n (0x0a) and \r (0x0d) */
	var T_BAD_CHARACTER;
	/** && - logical operators */
	var T_BOOLEAN_AND;
	/** || - logical operators */
	var T_BOOLEAN_OR;
	/** (bool) or (boolean) - type-casting */
	var T_BOOL_CAST;
	/** break - break */
	var T_BREAK;
	/** callable - callable */
	var T_CALLABLE;
	/** case - switch */
	var T_CASE;
	/** catch - Exceptions */
	var T_CATCH;
	/**  not used anymore */
	var T_CHARACTER;
	/** class - classes and objects */
	var T_CLASS;
	/** __CLASS__ - magic constants */
	var T_CLASS_C;
	/** clone - classes and objects */
	var T_CLONE;
	/** ?> or %> - escaping from HTML */
	var T_CLOSE_TAG;
	/** ?? - comparison operators (available since PHP 7.0.0) */
	var T_COALESCE;
	/** // or #, and / * * / - comments */
	var T_COMMENT;
	/** .= - assignment operators */
	var T_CONCAT_EQUAL;
	/** const - class constants */
	var T_CONST;
	/** "foo" or 'bar' - string syntax */
	var T_CONSTANT_ENCAPSED_STRING;
	/** continue - continue */
	var T_CONTINUE;
	/** {$ - complex variable parsed syntax */
	var T_CURLY_OPEN;
	/** -- - incrementing/decrementing operators */
	var T_DEC;
	/** declare - declare */
	var T_DECLARE;
	/** default - switch */
	var T_DEFAULT;
	/** __DIR__ - magic constants (available since PHP 5.3.0) */
	var T_DIR;
	/** /= - assignment operators */
	var T_DIV_EQUAL;
	/** 0.12, etc. - floating point numbers */
	var T_DNUMBER;
	/** /** * / - PHPDoc style comments */
	var T_DOC_COMMENT;
	/** do - do..while */
	var T_DO;
	/** ${ - complex variable parsed syntax */
	var T_DOLLAR_OPEN_CURLY_BRACES;
	/** => - array syntax */
	var T_DOUBLE_ARROW;
	/** (real), (double) or (float) - type-casting */
	var T_DOUBLE_CAST;
	/** :: - see T_PAAMAYIM_NEKUDOTAYIM below */
	var T_DOUBLE_COLON;
	/** echo - echo */
	var T_ECHO;
	/** ... - function arguments (available since PHP 5.6.0) */
	var T_ELLIPSIS;
	/** else - else */
	var T_ELSE;
	/** elseif - elseif */
	var T_ELSEIF;
	/** empty - empty() */
	var T_EMPTY;
	/** " $a" - constant part of string with variables */
	var T_ENCAPSED_AND_WHITESPACE;
	/** enddeclare - declare, alternative syntax */
	var T_ENDDECLARE;
	/** endfor - for, alternative syntax */
	var T_ENDFOR;
	/** endforeach - foreach, alternative syntax */
	var T_ENDFOREACH;
	/** endif - if, alternative syntax */
	var T_ENDIF;
	/** endswitch - switch, alternative syntax */
	var T_ENDSWITCH;
	/** endwhile - while, alternative syntax */
	var T_ENDWHILE;
	/**  heredoc syntax */
	var T_END_HEREDOC;
	/** eval() - eval() */
	var T_EVAL;
	/** exit or die - exit(), die() */
	var T_EXIT;
	/** extends - extends, classes and objects */
	var T_EXTENDS;
	/** __FILE__ - magic constants */
	var T_FILE;
	/** final - Final Keyword */
	var T_FINAL;
	/** finally - Exceptions (available since PHP 5.5.0) */
	var T_FINALLY;
	/** for - for */
	var T_FOR;
	/** foreach - foreach */
	var T_FOREACH;
	/** function or cfunction - functions */
	var T_FUNCTION;
	/** __FUNCTION__ - magic constants */
	var T_FUNC_C;
	/** global - variable scope */
	var T_GLOBAL;
	/** goto - goto (available since PHP 5.3.0) */
	var T_GOTO;
	/** __halt_compiler() - __halt_compiler (available since PHP 5.1.0) */
	var T_HALT_COMPILER;
	/** if - if */
	var T_IF;
	/** implements - Object Interfaces */
	var T_IMPLEMENTS;
	/** ++ - incrementing/decrementing operators */
	var T_INC;
	/** include() - include */
	var T_INCLUDE;
	/** include_once() - include_once */
	var T_INCLUDE_ONCE;
	/**  text outside PHP */
	var T_INLINE_HTML;
	/** instanceof - type operators */
	var T_INSTANCEOF;
	/** insteadof - Traits (available since PHP 5.4.0) */
	var T_INSTEADOF;
	/** (int) or (integer) - type-casting */
	var T_INT_CAST;
	/** interface - Object Interfaces */
	var T_INTERFACE;
	/** isset() - isset() */
	var T_ISSET;
	/** == - comparison operators */
	var T_IS_EQUAL;
	/** >= - comparison operators */
	var T_IS_GREATER_OR_EQUAL;
	/** === - comparison operators */
	var T_IS_IDENTICAL;
	/** != or <> - comparison operators */
	var T_IS_NOT_EQUAL;
	/** !== - comparison operators */
	var T_IS_NOT_IDENTICAL;
	/** <= - comparison operators */
	var T_IS_SMALLER_OR_EQUAL;
	/** <=> - comparison operators (available since PHP 7.0.0) */
	var T_SPACESHIP;
	/** __LINE__ - magic constants */
	var T_LINE;
	/** list() - list() */
	var T_LIST;
	/** 123, 012, 0x1ac, etc. - integers */
	var T_LNUMBER;
	/** and - logical operators */
	var T_LOGICAL_AND;
	/** or - logical operators */
	var T_LOGICAL_OR;
	/** xor - logical operators */
	var T_LOGICAL_XOR;
	/** __METHOD__ - magic constants */
	var T_METHOD_C;
	/** -= - assignment operators */
	var T_MINUS_EQUAL;
	/** %= - assignment operators */
	var T_MOD_EQUAL;
	/** *= - assignment operators */
	var T_MUL_EQUAL;
	/** namespace - namespaces (available since PHP 5.3.0) */
	var T_NAMESPACE;
	/** __NAMESPACE__ - namespaces (available since PHP 5.3.0) */
	var T_NS_C;
	/** \ - namespaces (available since PHP 5.3.0) */
	var T_NS_SEPARATOR;
	/** new - classes and objects */
	var T_NEW;
	/** "$a[0]" - numeric array index inside string */
	var T_NUM_STRING;
	/** (object) - type-casting */
	var T_OBJECT_CAST;
	/** -> - classes and objects */
	var T_OBJECT_OPERATOR;
	/** <?php, <? or <% - escaping from HTML */
	var T_OPEN_TAG;
	/** <?= or <%= - escaping from HTML */
	var T_OPEN_TAG_WITH_ECHO;
	/** |= - assignment operators */
	var T_OR_EQUAL;
	/** :: - ::. Also defined as T_DOUBLE_COLON. */
	var T_PAAMAYIM_NEKUDOTAYIM;
	/** += - assignment operators */
	var T_PLUS_EQUAL;
	/** ** - arithmetic operators (available since PHP 5.6.0) */
	var T_POW;
	/** **= - assignment operators (available since PHP 5.6.0) */
	var T_POW_EQUAL;
	/** print() - print */
	var T_PRINT;
	/** private - classes and objects */
	var T_PRIVATE;
	/** public - classes and objects */
	var T_PUBLIC;
	/** protected - classes and objects */
	var T_PROTECTED;
	/** require() - require */
	var T_REQUIRE;
	/** require_once() - require_once */
	var T_REQUIRE_ONCE;
	/** return - returning values */
	var T_RETURN;
	/** << - bitwise operators */
	var T_SL;
	/** <<= - assignment operators */
	var T_SL_EQUAL;
	/** >> - bitwise operators */
	var T_SR;
	/** >>= - assignment operators */
	var T_SR_EQUAL;
	/** <<< - heredoc syntax */
	var T_START_HEREDOC;
	/** static - variable scope */
	var T_STATIC;
	/** parent, self, etc. - identifiers, e.g. keywords like parent and self, function names, class names and more are matched. See also T_CONSTANT_ENCAPSED_STRING. */
	var T_STRING;
	/** (string) - type-casting */
	var T_STRING_CAST;
	/** "${a - complex variable parsed syntax */
	var T_STRING_VARNAME;
	/** switch - switch */
	var T_SWITCH;
	/** throw - Exceptions */
	var T_THROW;
	/** trait - Traits (available since PHP 5.4.0) */
	var T_TRAIT;
	/** __TRAIT__ - __TRAIT__ (available since PHP 5.4.0) */
	var T_TRAIT_C;
	/** try - Exceptions */
	var T_TRY;
	/** unset() - unset() */
	var T_UNSET;
	/** (unset) - type-casting */
	var T_UNSET_CAST;
	/** use - namespaces (available since PHP 5.3.0) */
	var T_USE;
	/** var - classes and objects */
	var T_VAR;
	/** $foo - variables */
	var T_VARIABLE;
	/** while - while, do..while */
	var T_WHILE;
	/** \t \r\n */
	var T_WHITESPACE;
	/** ^= - assignment operators */
	var T_XOR_EQUAL;
	/** yield - generators (available since PHP 5.5.0) */
	var T_YIELD;
	/** yield from - generators (available since PHP 7.0.0) */
	var T_YIELD_FROM;
}