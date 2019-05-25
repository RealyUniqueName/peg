package test;

import peg.PegException;

class TestAll {
	static public function main() {
		var cnt = 0;
		Sys.print('');
		for (file in new peg.SourcesIterator('vendor')) {
			Sys.print('\rParsing files: ${cnt++}');

			var namespaces = try {
				file.parse();
			} catch(e:UnexpectedTokenException) {
				Sys.println('\n${file.path}:${e.token.line} FAIL >>');
				Sys.println(e.toString());
				Sys.exit(1);
				return;
			} catch(e:ParserException) {
				Sys.println('\n${file.path} FAIL >>');
				Sys.println(e.toString());
				Sys.exit(1);
				return;
			} catch(e:PegException) {
				Sys.println('\n${file.path} FAIL >>');
				Sys.println(e.toString());
				Sys.println('<< FAIL, skipped');
				continue;
			}
			for (namespace in namespaces) {
				// Sys.println('namespace: ${namespace.name}');

				// for (u in namespace.uses) {
				// 	Sys.println('  use ${u.toString()}');
				// }

				// for (cls in namespace.classes) {
				// 	var kwd = cls.isInterface ? 'interface' : 'class';
				// 	Sys.println('  $kwd ${cls.name} extends ${cls.parent} implements ${cls.interfaces.join(', ')}');
				// 	for (c in cls.constants) {
				// 		Sys.println('    const ${c.name}');
				// 	}
				// 	for (v in cls.vars) {
				// 		Sys.println('    var ${v.name}');
				// 	}
				// 	for (fn in cls.functions) {
				// 		Sys.println('    function ${fn.name}');
				// 	}
				// }
			}
			// Sys.println('Ok');
		}
		Sys.println('\nAll done!');
	}
}