import peg.*;

class Run {
	static function main() {
		var path = Sys.args()[0];
		var cnt = 0;
		for(file in new PhpSourcesIterator(path)) {
			// trace(file.path);
			cnt++;
		}
		trace({total:cnt});
	}
}
