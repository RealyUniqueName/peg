package peg.parser;

import peg.php.PType;
using StringTools;

class DocBlock {
	/** Full content of the doc block, but with asterisks stripped out */
	public var text(default,null):String = '';
	public var returnType(default,null):Null<PType>;
	public var varType(default,null):Null<PType>;
	public var params(get,never):ReadOnlyArray<{name:String, type:PType}>;

	var _params:Array<{name:String, type:PType}> = [];

	static public function parse(str:String, ?parseType:(type:String)->PType):DocBlock {
		var doc = new DocBlock();
		if(parseType != null) parseTypes(doc, str, parseType);
		doc.text = parseText(str);
		return doc;
	}

	static function parseTypes(doc:DocBlock, str:String, parseType:(type:String)->PType) {
		var regexp = ~/@([a-zA-Z]+)(\s+)(\S+)((\s+)(\S+))?/;
		while(regexp.match(str)) {
			var tag = regexp.matched(1);
			var arg1 = regexp.matched(3);
			var arg2 = regexp.matched(6);
			switch tag {
				case 'return':
					doc.returnType = parseType(arg1);
				case 'var':
					doc.varType = parseType(arg1);
				case 'param':
					doc._params.push({name:arg2, type:parseType(arg1)});
			}
			str = regexp.matchedRight();
		}
	}

	static function parseText(str:String):String {
		var lines = [];
		for(line in str.split('\n')) {
			line = line.trim();
			switch line {
				case '' | '/**' | '*/' | '**/':
				case '*': lines.push('');
				case _: lines.push(line.startsWith('* ') ? line.substr(2) : line);
			}
		}
		return lines.join('\n');
	}

	function new() {}

	inline function get_params():ReadOnlyArray<{name:String, type:PType}> {
		return _params;
	}
}

