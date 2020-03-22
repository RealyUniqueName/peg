package peg.generator.writers;

using StringTools;

class SymbolWriter {
	static var DOC_INDENT = ~/\n(\s*)\*/g;

	public var doc(default,set):String = '';
	public var native(never,set):String;
	public var isFinal(never,set):Bool;

	var indentation:String = '';

	final name:String;
	final accessors:Array<String> = [];
	final meta:Array<String> = [];

	public function new(name:String) {
		this.name = (name.charAt(0) == "$" ? name.substr(1) : name);
	}

	/**
	 * Performs `subj.join(glue)` and adds a trailing space if `subj` is not empty
	 */
	inline function joinSpace(subj:Array<String>, glue:String = ' '):String {
		return subj.length == 0 ? '' : (subj.join(glue) + ' ');
	}

	function set_isFinal(v) {
		setAccessor('final', v);
		return v;
	}

	function setAccessor(kwd:String, exists:Bool) {
		accessors.remove(kwd);
		if(exists) accessors.push(kwd);
	}

	function set_native(v:String) {
		for(i in 0...meta.length) {
			if(meta[i].startsWith('@:native(')) {
				meta.splice(i, 1);
				break;
			}
		}

		v = v.replace('\\', '\\\\');
		meta.push('@:native("$v")\n');
		return v;
	}

	function set_doc(s:String):String {
		if(s != null && s != '') {
			doc = s.endsWith('\n') ? s : '$s\n';
			doc = indentation + DOC_INDENT.replace(doc, '\n$indentation *');
		} else {
			doc = '';
		}
		return s;
	}

	public function toString():String {
		throw new PegException('Not implemented');
	}
}