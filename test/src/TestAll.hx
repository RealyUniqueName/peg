using Safety;
using haxe.io.Path;
using sys.FileSystem;
using sys.io.File;
using StringTools;

class TestAll {
	static function command(cmd:String, args:Array<String>) {
		Sys.println('Running command: $cmd ' + args.join(' '));
		return Sys.command(cmd, args);
	}

	static public function main() {
		Sys.println('Cwd: ' + Sys.getCwd());
		var pegPhp = 'bin/php/index.php';
		var phpDir = 'test/data/php';
		var outDir = 'bin/generated';
		var expectedDir = 'test/data/expected';
		var diffOnFail = Sys.args().indexOf('--diff') >= 0;
		if(!diffOnFail) {
			Sys.println('Use --diff to automatically show diff of expected/actual on failure');
		}
		Sys.println('Generating externs of the test data from $phpDir');
		var exitCode = command('php', [pegPhp, '--php', phpDir, '--out', outDir]);
		if(exitCode != 0) {
			Sys.stderr().writeString('Failed to generate externs.\n');
			Sys.exit(exitCode);
		}

		Sys.println('Validating generated externs against expected result from $expectedDir');
		var success = true;
		function fail(expectedPath:String, actualPath:String, relative:String) {
			success = false;
			Sys.stderr().writeString('Generated content does not match expected content for file $relative\n');
			Sys.stderr().flush();
			if(diffOnFail) {
				Sys.command('git', ['diff', '--no-index', expectedPath, actualPath]);
			}
		}

		var outFiles = findHxFiles(outDir);
		for(relative => expectedPath in findHxFiles(expectedDir)) {
			outFiles.remove(relative);
			var expectedContent = expectedPath.getContent();
			var actualPath = Path.join([outDir, relative]);
			var actualContent = actualPath.getContent();
			if(expectedContent != actualContent) {
				var expectedLines = expectedContent.split('\n');
				var actualLines = actualContent.split('\n');
				if(expectedLines.length != actualLines.length) {
					fail(expectedPath, actualPath, relative);
				} else {
					for(i => actual in actualLines) {
						var expected = expectedLines[i];
						if(actual != expected && (actual + expected).trim() != '') {
							fail(expectedPath, actualPath, relative);
							break;
						}
					}
				}
			}
		}
		for(relative => outPath in outFiles) {
			success = false;
			Sys.stderr().writeString('Unexpected file generated: $outPath\n');
			Sys.stderr().flush();
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
			case r: r.sure();
		}
		var root = switch root {
			case null: path.fullPath().addTrailingSlash();
			case r: r.sure();
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