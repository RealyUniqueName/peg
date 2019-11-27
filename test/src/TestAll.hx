using haxe.io.Path;
using sys.FileSystem;
using sys.io.File;
using StringTools;

class TestAll {
	static public function main() {
		var pegPhp = 'bin/php/index.php';
		var phpDir = 'test/data/php';
		var outDir = 'bin/generated';
		var expectedDir = 'test/data/expected';
		var diffOnFail = Sys.args().indexOf('--diff') >= 0;
		if(!diffOnFail) {
			Sys.println('Use --diff to automatically show diff of expected/actual on failure');
		}
		Sys.println('Generating externs of the test data from $phpDir');
		var exitCode = Sys.command('php', [pegPhp, '--php', phpDir, '--out', outDir]);
		if(exitCode != 0) {
			Sys.stderr().writeString('Failed to generate externs.\n');
			Sys.exit(exitCode);
		}

		Sys.println('Validating generated externs against expected result from $expectedDir');
		var success = true;
		for(relative => expectedPath in findHxFiles(expectedDir)) {
			var expectedContent = expectedPath.getContent();
			var actualPath = Path.join([outDir, relative]);
			var actualContent = actualPath.getContent();
			if(expectedContent != actualContent) {
				success = false;
				Sys.stderr().writeString('Generated content does not match expected content for file $relative\n');
				Sys.stderr().flush();
				if(diffOnFail) {
					Sys.command('git', ['diff', '--no-index', expectedPath, actualPath]);
				}
			}
		}

		if(!success) {
			Sys.stderr().writeString('FAIL\n');
			Sys.exit(1);
		} else {
			Sys.println('SUCCESS');
		}
	}

	/**
	 * Returns a list of hx files with paths relative to `root`.
	 * If `root` is not provided then all the found file paths will be relative to `path`.
	 * Returns a map of [relative_to_root => absolute_path ]
	 */
	static function findHxFiles(path:String, ?root:String, ?result:Map<String,String>):Map<String,String> {
		var result = switch result {
			case null: new Map();
			case r: r;
		}
		var root = switch root {
			case null: path.fullPath().addTrailingSlash();
			case r: r;
		}

		path = path.fullPath();
		if(path.isDirectory()) {
			for(entry in path.readDirectory()) {
				findHxFiles(Path.join([path, entry]), root, result);
			}
		} else if(path.toLowerCase().endsWith('.hx')) {
			result.set(path.replace(root, ''), path);
		}
		return result;
	}
}