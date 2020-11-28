package peg;

using sys.FileSystem;
using haxe.io.Path;

class Peg {
	static function main() {
		var args = Sys.args();
		handleHelpArg(args);
		var phpDir = getPhpDir(args);
		var outDir = getOutDir(args);

		var allNamespaces = [];
		var parseCount = 0;
		for (file in new peg.SourcesIterator(phpDir)) {
			Sys.print('\rParsing php files: ${++parseCount}');

			var namespaces = try {
				file.parse();
			} catch(e:UnexpectedTokenException) {
				fail('\n${file.path}:${e.token.line} FAIL >>\n$e');
			} catch(e:ParserException) {
				fail('\n${file.path} FAIL >>\n$e');
			} catch(e:PegException) {
				Sys.stderr().writeString('\n${file.path} FAIL >>\n');
				Sys.stderr().writeString('$e\n');
				Sys.stderr().writeString('<< FAIL, skipped\n');
				continue;
			}

			for (namespace in namespaces) {
				allNamespaces.push(namespace);
			}
		}

		var genCount = 0;
		var gen = new Generator(
			allNamespaces,
			outDir,
			()-> Sys.print('\rWriting Haxe externs: ${++genCount}'),
			() -> Sys.println('\rDone: $parseCount file(s) parsed, $genCount file(s) generated.')
		);
		gen.run();
	}

	static function handleHelpArg(args:Array<String>) {
		for(arg in args) {
			switch arg {
				case '--help' | '-h' | '-help':
					Sys.println('Usage:\n\tpeg --php path/to/php/files/ --out dir/to/generate/externs/to/');
					Sys.exit(0);
				case _:
			}
		}
	}

	static function getPhpDir(args:Array<String>):String {
		for(i in 0...args.length) {
			switch args[i] {
				case '--php':
					if(i + 1 >= args.length) {
						return fail('--php argument requires a value: path to a directory with php files.');
					}
					var phpDir = args[i + 1];
					if(!phpDir.exists()) {
						return fail('Directory does not exist: $phpDir');
					}
					if(!phpDir.isDirectory()) {
						return fail('Path is not a directory: $phpDir');
					}
					return phpDir.removeTrailingSlashes();
				case _:
			}
		}
		return fail('Missing --php argument. Run with --help to get usage info.');
	}

	static function getOutDir(args:Array<String>):String {
		for(i in 0...args.length) {
			switch args[i] {
				case '--out':
					if(i + 1 >= args.length) {
						return fail('--out argument requires a value: path to a directory to generate externs to.');
					}
					var outDir = args[i + 1];
					if(outDir.exists() && !outDir.isDirectory()) {
						return fail('Path is not a directory: $outDir');
					}
					return outDir.removeTrailingSlashes();
				case _:
			}
		}
		return fail('Missing --out argument. Run with --help to get usage info.');
	}

	static function fail<T>(msg:String):T {
		Sys.stderr().writeString('Error: $msg\n');
		Sys.exit(1);
		throw 'Unexpected';
	}
}
