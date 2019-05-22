package test;

class TestAll {
	static public function main() {

		for (file in new peg.SourcesIterator('vendor/zendframework/zend-json')) {
			Sys.println('Parsing ${file.path}');

			for (namespace in file.parse()) {
				Sys.println('namespace: ${namespace.name}');

				for (s in namespace.uses) {
					Sys.println('  use $s');
				}

				for (cls in namespace.classes) {
					Sys.println('  class ${cls.name}');
					for (v in cls.vars) {
						Sys.println('    var ${v.name}');
					}
					for (fn in cls.functions) {
						Sys.println('    function ${fn.name}');
					}
				}
			}
		}
	}
}