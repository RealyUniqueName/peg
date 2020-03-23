package peg.parser;

import peg.php.PType;

class DocBlock {
	public var returnType(default,null):Null<PType>;
	public var varType(default,null):Null<PType>;
	public var params(get,never):ReadOnlyArray<{name:String, type:PType}>;

	var _params:Array<{name:String, type:PType}> = [];

	static public function parse(str:String, parseType:(type:String)->PType):DocBlock {
		var regexp = ~/@([a-zA-Z]+)(\s+)(\S+)((\s+)(\S+))?/;
		var doc = new DocBlock();
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
		return doc;
	}

	function new() {}

	inline function get_params():ReadOnlyArray<{name:String, type:PType}> {
		return _params;
	}
}

