package peg.generator;

import peg.php.*;

using StringTools;

class NamespaceTree {
	final root:Node;

	static public function build(namespaces:ReadOnlyArray<PNamespace>):Node {
		var root = Node.createRoot(namespaces);
		for (ns in namespaces) {
			var node = root.findNode(ns);
		}
		return root;
		// return new NamespaceTree(root);
	}

	function new(root:Node) {
		this.root = root;
	}
}


class Node {
	public final parsedData:Array<PNamespace> = [];
	public final name:String;
	public final parent:Null<Node>;

	public var isRoot(get,never):Bool;
	public var root(default,null):Node;
	public var children(get,never):ReadOnlyArray<Node>;

	final _children:Array<Node> = [];

	static public function createRoot(namespaces:ReadOnlyArray<PNamespace>):Node {
		for(ns in namespaces) {
			if(ns.name == '') {
				return new Node(ns, '', null);
			}
		}
		return new Node(null, '', null);
	}

	function new(ns:Null<PNamespace>, name:String, parent:Null<Node>) {
		if(ns != null) {
			this.parsedData.push(ns);
		}
		this.name = name;
		this.parent = parent;
		this.root = (parent == null ? @:nullSafety(Off) this : parent.root);
		if(parent != null) {
			parent._children.push(this);
		}
	}

	// public function findRelative(relativeNamespace:String):Node {
	// 	var path = relativeNamespace.split('\\');
	// 	switch parent {
	// 		case null: throw new Exception('not implemented');
	// 		case parent:
	// 	}
	// }

	public function getNamespace():Array<String> {
		var result = [];
		var node:Null<Node> = this;
		while(node != null && !node.isRoot) {
			result.unshift(node.name);
			node = node.parent;
		}
		return result;
	}

	public function findNode(ns:PNamespace):Node {
		return switch trimSlash(ns.name).split('\\') {
			case ['']: root;
			case path: root._findNode(ns, path, 0);
		}
	}

	function _findNode(ns:PNamespace, path:SafeArray<String>, index:Int):Node {
		var current = path[index];
		var node:Null<Node> = null;
		for (child in _children) {
			if(child.name == current) {
				node = child;
			}
		}
		if(node == null) {
			node = new Node(ns, path[index], this);
		}
		if(index + 1 == path.length) {
			node.addNs(ns);
			return node;
		} else {
			return node._findNode(ns, path, index + 1);
		}
	}

	function addNs(ns:PNamespace) {
		if(parsedData.indexOf(ns) < 0) {
			parsedData.push(ns);
		}
	}

	inline function get_isRoot() return root == this;
	inline function get_children() return _children;

	static inline function trimSlash(ns:String):String {
		return ns.charAt(0) == '\\' ? ns.substr(1) : ns;
	}
}

