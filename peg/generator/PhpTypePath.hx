package peg.generator;

abstract PhpTypePath(String) from String {
	@:to public inline function toString() {
		return (this.charAt(0) == '\\' ? 'php.${this.substr(1)}' : this);
	}
}