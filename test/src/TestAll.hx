import peg.Generator;
import peg.PegException;

class TestAll {
	// static public function main() {
	// 	trace(Sys.args());
	// }

	static function main() {
		var cnt = 0;
		Sys.print('');
		var allNamespaces = [];
		for (file in new peg.SourcesIterator('vendor/zendframework/zend-json')) {
			Sys.print('\rParsing php files: ${++cnt}');

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
				allNamespaces.push(namespace);
			}
		}
		Sys.println('');
		cnt = 0;
		var gen = new Generator(
			allNamespaces,
			'bin/externs',
			()-> Sys.print('\rWriting Haxe externs: ${++cnt}'),
			() -> Sys.println('\nAll done!')
		);
		gen.run();
	}
}