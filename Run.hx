import peg.PegException;

class Run {
	static var basePackage = '';

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
			case TObject:
				'Map<String,Dynamic>';
			case TCallable:
				'Dynamic';
			case TMixed:
				'Dynamic';
			case TResource:
				'php.Resource';
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
					case _:
						if (basePackage != null && basePackage != '') {
							'${basePackage}.${name}';
						} else {
							name;
						}
				}
			case _:
				Sys.println('// WARNING: could not determine the type of ${t.getName()}');
				t.getName();
		};
	}

	static function getConst(c:peg.php.PConst):String {
		return '@:phpClassConst static ${c.visibility} final ${c.name}:${getType(c.type)}';
	}

	static function getVarName(name:String):String {
		return ~/^[$]/.replace(name, '');
	}

	static function getVar(v:peg.php.PVar):String {
		return '${v.visibility} var ${getVarName(v.name)}:${getType(v.type)}';
	}

	static function getFunction(fn:peg.php.PFunction, isNamespaceGlobal:Bool = false, ?namespace:String):String {
		var args = fn.args.map(arg -> '${arg.isOptional ? '?' : ''}${getVarName(arg.name)}:${getType(arg.type)}').join(', ');
		var inlineCallParams = fn.args.map(arg -> getVarName(arg.name)).join(', ');
		var callSite = '';
		if (isNamespaceGlobal) {
			var ns = namespace != '' ? '\\\\${namespace}\\\\' : '';
			callSite = ' return php.Syntax.call(\'${ns}${fn.name}\'${inlineCallParams != '' ? ', ' + inlineCallParams : ''})';
		}
		return '${fn.isAbstract ? 'abstract ' : ''}${fn.isFinal ? 'final ' : ''}${fn.visibility}${isNamespaceGlobal || fn.isStatic ? ' static' : ''}${callSite != '' ? ' inline' : ''} function ${fn.name}(${args}):${getType(fn.returnType)}${callSite};';
	}

	static function usage() {
		Sys.println('USAGE:');
		Sys.println('   php index.php <base-package-name> <file-or-dir-to-externalize>');
	}

	static function main() {
		var basePackage = Sys.args()[0];
		var path = Sys.args()[1];

		if (basePackage == null || basePackage == '') {
			usage();
			return;
		}

		Run.basePackage = basePackage;

		var combinedNamespaces:Map<String, peg.php.PNamespace> = [];
		for(file in new peg.SourcesIterator(path)) {
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
			var leadingDotRE = ~/^\./;
			var packageRE = ~/^(.*\.)?([^\.]+)$/;

			for (nsName => namespace in combinedNamespaces) {
				if (nsName != '') {
					var p = slashesRE.replace(nsName.toLowerCase(), '.');
					Sys.println('package ${basePackage}.${p};');
				} else {
					Sys.println('package ${basePackage};');
				}

				if (namespace.constants.length > 0 || namespace.functions.length > 0) {
					Sys.println('extern class GLOBALS {');
					for (c in namespace.constants) {
						Sys.println('    ' + getConst(c));
					}
					for (fn in namespace.functions) {
						Sys.println('    ' + getFunction(fn, true, namespace.name));
					}
					Sys.println('}');
				}

				for (cls in namespace.classes) {
					var kwd = cls.isInterface ? 'interface' : 'class';
					var phpNS = slashesRE.replace(nsName, '\\\\\\\\');
					if (phpNS != '') {
						phpNS += '\\\\';
					}
					var parent = leadingDotRE.replace(slashesRE.replace(cls.parent, '.'), '');

					var clsExtends = '';
					if (parent != null && parent != '') {
						var parentpkg = packageRE.replace(parent, '$1');
						if (parentpkg != '') {
							parentpkg = parentpkg.toLowerCase + '.';
						}
						parent = packageRE.replace(parent, '$2');
						clsExtends = ' extends ${basePackage}.${parentpkg}${parent}';
					}
					var imp = cls.interfaces.length > 0 ? ' implements ${cls.interfaces.join(', ')}' : '';

					Sys.println('@:native(\'\\\\' + phpNS + cls.name + '\')');
					Sys.println('extern ${kwd} ${cls.name}${clsExtends}${imp} {');
					for (c in cls.constants) {
						if (c.visibility != VPrivate) {
							Sys.println('    ' + getConst(c));
						}
					}
					for (v in cls.vars) {
						if (v.visibility != VPrivate) {
							Sys.println('    ' + getVar(v));
						}
					}
					for (fn in cls.functions) {
						if (fn.visibility != VPrivate) {
							Sys.println('    ' + getFunction(fn));
						}
					}
					Sys.println('}');
				}
			}
		}
	}
}
