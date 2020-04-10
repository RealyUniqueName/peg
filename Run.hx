import sys.FileSystem;
import haxe.io.Path;
import peg.PegException;

class Run {
	static var basePackage = '';
	static var currentClass = '';
	static var currentNamespace = '';

	static var haxeKeywords = [
		'abstract',
		'break',
		'case',
		'cast',
		'catch',
		'class',
		'continue',
		'default',
		'do',
		'dynamic',
		'else',
		'enum',
		'extends',
		'extern',
		'false',
		'final',
		'for',
		'function',
		'if',
		'implements',
		'import',
		'in',
		'inline',
		'interface',
		'macro',
		'new',
		'null',
		'operator',
		'overload',
		'override',
		'package',
		'private',
		'public',
		'return',
		'static',
		'switch',
		'this',
		'throw',
		'true',
		'try',
		'typedef',
		'untyped',
		'using',
		'var',
		'while',
	];

	static function resolveClass(className:String):String {
		var cn = className.substr(0, 1).toUpperCase() + className.substr(1);
		if (basePackage != null && basePackage != '' && currentNamespace != '') {
			return '${basePackage}.${currentNamespace}.${cn}';
		}
		if (basePackage != null && basePackage != '') {
			return '${basePackage}.${cn}';
		}
		if (currentNamespace != '') {
			return '${currentNamespace}.${cn}';
		}

		return cn;

	}

	static function getType(t:peg.php.PType):String {
		return switch t {
			case TInt:
				'Int';
			case TFloat:
				'Float';
			case TString:
				'String';
			case TBool:
				'Bool';
			case TArray(type):
				'Array<${getType(type)}>';
			case TObject(indexType, valueType):
				'Map<${getType(indexType)},${getType(valueType)}>';
			case TCallable:
				'Dynamic';
			case TMixed:
				'Dynamic';
			case TResource:
				'php.Resource';
			case TVoid:
				'Void';
			case TClass(name):
				switch (~/^\\/.replace(name, '')) {
					case 'stdClass':
						'php.StdClass';
					// These are in the haxe standard library
					case 'ArrayAccess' | 'Closure' | 'Error' | 'ErrorException' | 'Exception' |
					'Generator' | 'IteratorAggregate' | 'RuntimeException' |
					'SessionHandlerInterface' | 'StdClass' | 'Throwable' | 'Traversable':
						'php.${name}';
					// These are in the haxe standard library
					case 'Mysqli' | 'Mysqli_driver' | 'Mysqli_result' | 'Mysqli_stmt' |
					'Mysqli_warning' | 'PDO' | 'PDOException' | 'PDOStatement' | 'SQLite3' |
					'SQLite3Result' | 'SQLite3Stmt':
						'php.db.${name}';
					// These are in the haxe standard library
					case 'ReflectionClass' | 'ReflectionFunctionAbstract' | 'ReflectionMethod' |
					'ReflectionProperty' | 'Reflector':
						'php.reflection.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'DateInterval' | 'DatePeriod' | 'DateTime' | 'DateTimeImmutable' |
					'DateTimeInterface' | 'DateTimeZone':
						'php.calendar.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'ArithmeticError' | 'AssertionError' | 'BadFunctionCallException' |
					'BadMethodCallException' | 'DivisionByZeroError' | 'DomainException' |
					'InvalidArgumentException' | 'LengthException' | 'LogicException' |
					'OutOfBoundsException' | 'OutOfRangeException' | 'OverflowException' |
					'ParseError' | 'RangeException' | 'TypeError' | 'UnderflowException' |
					'UnexpectedValueException':
						'php.exceptions.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'SplFileInfo' | 'SplFileObject' | 'SplTempFileObject':
						'php.files.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'ImapCloseFlags' | 'ImapHeaders' | 'ImapOverview' | 'ImapSearchFlags' |
					'ImapSortFlags' | 'ImapStatusFlags' | 'ImapStream' | 'MailAddress' |
					'MailboxInfo' | 'MailStructure':
						'php.imap.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'Countable' | 'Iterator' | 'OuterIterator' | 'RecursiveIterator' |
					'SeekableIterator' | 'Serializable' | 'SplObserver' | 'SplSubject':
						'php.interfaces.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'AppendIterator' | 'ArrayIterator' | 'CachingIterator' |
					'CallbackFilterIterator' | 'DirectoryIterator' | 'EmptyIterator' |
					'FilesystemIterator' | 'FilterIterator' | 'GlobIterator' | 'InfiniteIterator' |
					'IteratorIterator' | 'LimitIterator' | 'MultipleIterator' |
					'NoRewindIterator' | 'ParentIterator' | 'RecursiveArrayIterator' |
					'RecursiveCachingIterator' | 'RecursiveCallbackFilterIterator' |
					'RecursiveDirectoryIterator' | 'RecursiveFilterIterator' |
					'RecursiveIteratorIterator' | 'RecursiveRegexIterator' |
					'RecursiveTreeIterator' | 'RegexIterator':
						'php.iterators.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'ArrayObject':
						'php.misc.${name}';
					// These require phpnatives (https://lib.haxe.org/p/phpnatives/)
					case 'DOMAttr' | 'DOMCdataSection' | 'DOMCharacterData' | 'DOMComment' |
					'DOMDocument' | 'DOMDocumentFragment' | 'DOMDocumentType' | 'DOMElement' |
					'DOMEntity' | 'DOMEntityReference' | 'DOMException' | 'DOMImplementation' |
					'DOMNamedNodeMap' | 'DOMNode' | 'DOMNodeList' | 'DOMNotation' |
					'DOMProcessingInstruction' | 'DOMText' | 'DOMXPath' | 'LibXMLError' |
					'SimpleXMLElement' | 'SimpleXMLIterator' | 'XMLReader' | 'XSLTProcessor':
						'php.xml.${name}';
					// All other/unknown classes
					case 'self':
						resolveClass(currentClass);
					case className:
						resolveClass(className);
				}
			case _:
				Sys.println('// WARNING: could not determine the type of ${t.getName()}');
				t.getName();
		};
	}

	static function getConst(c:peg.php.PConst):String {
		return '@:phpClassConst static ${c.visibility} final ${c.name}:${getType(c.type)};';
	}

	static function getVarName(name:String):String {
		name = ~/^[$]/.replace(name, '');
		if (haxeKeywords.indexOf(name) != -1) {
			name += '_';
		}
		return name;
	}

	static function getVar(v:peg.php.PVar):String {
		var nativeName = ~/^[$]/.replace(v.name, '');
		var haxeName = getVarName(v.name);

		var nativeDefine = '';
		if (nativeName != haxeName) {
			nativeDefine = '@:native(\'${nativeName}\') ';
		}

		return '${nativeDefine}${v.visibility} var ${haxeName}:${getType(v.type)};';
	}

	static function getFunction(fn:peg.php.PFunction, isNamespaceGlobal:Bool = false, ?namespace:String):String {
		var fndefinition = '';

		var fnHaxeName = getVarName(fn.name);
		if (fnHaxeName != fn.name) {
			fndefinition += '@:native(\'${fn.name}\') ';
		}

		// set function visibility
		if (fn.visibility != null) {
			fndefinition += '${fn.visibility} ';
		}

		// set final functions as final
		if (fn.isFinal) {
			fndefinition += 'final ';
		}

		// set abstract functions as abstract
		if (fn.isAbstract) {
			fndefinition += 'abstract ';
		}

		// set namespace or global functions and static functions as static
		if (isNamespaceGlobal || fn.isStatic) {
			fndefinition += 'static ';
		}

		// set namespace or global functions as inline
		if (isNamespaceGlobal) {
			fndefinition += 'inline ';
		}

		// function name, params, and return type
		var args = fn.args.map(arg -> '${arg.isOptional ? '?' : ''}${getVarName(arg.name)}:${getType(arg.type)}').join(', ');
		fndefinition += 'function ${fnHaxeName}(${args}):${getType(fn.returnType)}';

		// callsite of inline functions for PHP namespace or global functions
		if (isNamespaceGlobal) {
			var ns = namespace != '' ? '\\\\${namespace}\\\\' : '';
			var callsiteParams = fn.args.map(arg -> getVarName(arg.name)).join(', ');
			if (callsiteParams != '') {
				callsiteParams = ', ${callsiteParams}';
			}

			fndefinition += ' return php.Syntax.call(\'${ns}${fn.name}\'${callsiteParams})';
		}

		// end of statement
		fndefinition += ';';

		return fndefinition;
	}

	static function usage() {
		Sys.println('USAGE:');
		Sys.println('   php index.php <base-package-name> <file-or-dir-to-externalize> [--outputDir <path>] [--ignore <path(s)>]');
	}

	static function main() {
		var args = Sys.args();
		var basePackage = args[0];
		var path = args[1];

		var outputDir = '.';
		var ignorePaths:Array<String> = [];

		if (basePackage == null || basePackage == '') {
			usage();
			return;
		}

		Run.basePackage = basePackage;

		if (path == null || path == '') {
			usage();
			return;
		}

		var i = 2;
		while(i < args.length) {
			switch (args[i++]) {
				case '--outputDir' | '--outputdir':
					outputDir = args[i++];
				case '--ignore':
					ignorePaths = args.slice(i);
					break;
				case _:
					usage();
					return;
			}
		}

		FileSystem.createDirectory(outputDir);

		ignorePaths = ignorePaths.map(ip -> Path.isAbsolute(ip) ? ip :
			Path.normalize(Path.join([Sys.getCwd(), path, ip])));

		var combinedNamespaces:Map<String, peg.php.PNamespace> = [];
		for(file in new peg.SourcesIterator(path)) {
			if (ignorePaths.indexOf(file.path) != -1) {
				continue;
			}
			var namespaces = try {
				file.parse();
			} catch(e:UnexpectedTokenException) {
				Sys.println('\n// WARNING: ${file.path}:${e.token.line} FAIL >>');
				Sys.println('// ${e.toString()}');
				Sys.exit(1);
				return;
			} catch(e:ParserException) {
				Sys.println('\n// WARNING: ${file.path} FAIL >>');
				Sys.println('// ${e.toString()}');
				Sys.exit(1);
				return;
			} catch(e:PegException) {
				Sys.println('\n// WARNING: ${file.path} FAIL >>');
				Sys.println('// ${e.toString()}');
				Sys.println('// FAIL, skipped');
				continue;
			}
			for (namespace in namespaces) {
				var n = combinedNamespaces.get(namespace.name);
				if (n != null) {
					for (c in namespace.constants) {
						n.addConst(c);
					}
					for (fn in namespace.functions) {
						n.addFunction(fn);
					}
					for (cls in namespace.classes) {
						n.addClass(cls);
					}
				} else {
					combinedNamespaces.set(namespace.name, namespace);
				}
			}
		}

		if (combinedNamespaces != null) {
			var slashesRE = ~/\\/g;
			var replaceDotsRE = ~/\./g;
			var packageRE = ~/^(([^\.]+\.)*)([^\.]+)$/;

			for (nsName => namespace in combinedNamespaces) {
				var packageDir = outputDir;
				var packageName = '';
				if (nsName != '') {
					currentNamespace = slashesRE.replace(nsName.toLowerCase(), '.');
					packageDir = Path.join(
						[outputDir]
						.concat(replaceDotsRE.split(basePackage))
						.concat(slashesRE.split(nsName.toLowerCase())));
					packageName = '${basePackage}.${currentNamespace}';
				} else {
					currentNamespace = '';
					packageDir = Path.join([outputDir, basePackage]);
					packageName = basePackage;
				}

				if (!FileSystem.exists(packageDir)) {
					FileSystem.createDirectory(packageDir);
				}

				if (namespace.constants.length > 0 || namespace.functions.length > 0) {
					// write out the globals class file
					var globalsDefinition = 'package ${packageName};\nextern class GLOBALS {';
					for (c in namespace.constants) {
						globalsDefinition += '\n    ' + getConst(c);
					}
					for (fn in namespace.functions) {
						globalsDefinition += '\n    ' + getFunction(fn, true, namespace.name);
					}
					globalsDefinition += '\n}';
					globalsDefinition += '\n'; // end file on empty new line
					sys.io.File.saveContent(Path.join([packageDir, 'GLOBALS.hx']), globalsDefinition);
				}

				for (cls in namespace.classes) {
					currentClass = cls.name;
					var kwd = cls.isInterface ? 'interface' : 'class';
					var phpNS = slashesRE.replace(nsName, '\\\\\\\\');
					if (phpNS != '') {
						phpNS += '\\\\';
					}
					var parent = slashesRE.replace(cls.parent, '.');

					var clsExtends = '';
					if (parent != null && parent != '') {
						var isAnchoredToRootNS = false;
						if (parent.substr(0, 1) == '.') {
							isAnchoredToRootNS = true;
							parent = parent.substr(1);
						}
						var parentpkg = packageRE.replace(parent.toLowerCase(), '$1');
						parent = packageRE.replace(parent, '$3');
						parent = parent.substr(0, 1).toUpperCase() + parent.substr(1);

						if (!isAnchoredToRootNS && parentpkg != null && parentpkg != '') {
							parentpkg = '${currentNamespace}.${parentpkg}';
						} else if (!isAnchoredToRootNS) {
							parentpkg = '${currentNamespace}';
						}

						clsExtends = ' extends ${basePackage}.${parentpkg}${parent}';
					}

					var interfaces = cls.interfaces.map(iface -> iface.substr(0, 1).toUpperCase() + iface.substr(1));
					var imp = interfaces.length > 0 ? ' implements ${interfaces.join(' implements ')}' : '';

					// write out the class file
					var classDefinition = 'package ${packageName};';
					var n = cls.name.substr(0, 1).toUpperCase() + cls.name.substr(1);
					classDefinition += '\n@:native(\'\\\\' + phpNS + cls.name + '\')';
					classDefinition += '\nextern ${kwd} ${n}${clsExtends}${imp} {';
					for (c in cls.constants) {
						if (c.visibility != VPrivate) {
							classDefinition += '\n    ' + getConst(c);
						}
					}
					for (v in cls.vars) {
						if (v.visibility != VPrivate) {
							classDefinition += '\n    ' + getVar(v);
						}
					}
					for (fn in cls.functions) {
						if (fn.visibility != VPrivate) {
							classDefinition += '\n    ' + getFunction(fn);
						}
					}
					classDefinition += '\n}\n';
					classDefinition += '\n'; // end file on empty new line
					sys.io.File.saveContent(Path.join([packageDir, '${n}.hx']), classDefinition);
				}
			}
		}
	}
}
