package test;

import peg.PhpLexer;
import peg.PhpParser;

class TestAll {
	static public function main() {

		for (file in new peg.PhpSourcesIterator('vendor/zendframework/zend-json')) {
			Sys.println('Parsing ${file.path}');

			for (namespace in file.parse()) {
				Sys.println('namespace: ${namespace.name}');

				for (s in namespace.uses) {
					Sys.println('use $s');
				}

				for (s in namespace.classes) {
					Sys.println('class $s');
				}
			}
		}
	}
}