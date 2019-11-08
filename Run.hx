import peg.PegException;

class Run {
	static var basePackage = '';

	static function getType(t:peg.php.PType):String {
		return switch t.getName() {
			case 'TInt':
				'Int';
			case 'TFloat':
				'Float';
			case 'TString':
				'String';
			case 'TBool':
				'Bool';
			case 'TArray':
				'Array<Dynamic>';
			case 'TCallable':
				'Dynamic';
			case 'TMixed':
				'Dynamic';
			case 'TClass':
				'${basePackage}.${t.getParameters().shift()}';
			case _:
				t.getName();
		};
	}

	static function getConst(c:peg.php.PConst):String {
		return '${c.visibility} const ${c.name}:${getType(c.type)}';
	}

	static function getVarName(name:String):String {
		return ~/^[$]/.replace(name, '');
	}

	static function getVar(v:peg.php.PVar):String {
		return '${v.visibility} var ${getVarName(v.name)}:${getType(v.type)}';
	}

	static function getFunction(fn:peg.php.PFunction, forceStatic:Bool = false):String {
		var args = fn.args.map(arg -> '${getVarName(arg.name)}:${getType(arg.type)}').join(', ');
		return '${fn.isAbstract ? 'abstract ' : ''}${fn.isFinal ? 'final ' : ''}${fn.visibility}${forceStatic || fn.isStatic ? ' static' : ''} function ${fn.name}(${args}):${getType(fn.returnType)};';
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
			for (pkg => namespace in combinedNamespaces) {
				if (pkg != '') {
					pkg = ~/\\/g.replace(pkg.toLowerCase(), '.');
					Sys.println('package ${basePackage}.${pkg};');
				} else {
					Sys.println('package ${basePackage};');
				}

				if (namespace.constants.length > 0 || namespace.functions.length > 0) {
					Sys.println('extern class ${basePackage} {');
					for (c in namespace.constants) {
						Sys.println('    ${getConst(c)}');
					}
					for (fn in namespace.functions) {
						Sys.println('    ${getFunction(fn, true)}');
					}
					Sys.println('}');
				}

				for (cls in namespace.classes) {
					var kwd = cls.isInterface ? 'interface' : 'class';
					var parent = ~/^_/.replace(~/\\/g.replace(cls.parent, '_'), '');
					var ext = cls.parent != null && cls.parent != '' ? 'extends ${pkg != '' ? basePackage + '.' : ''}${parent}' : '';
					var imp = cls.interfaces.length > 0 ? 'implements ${cls.interfaces.join(', ')}' : '';

					Sys.println('extern $kwd ${cls.name} ${ext} ${imp} {');
					for (c in cls.constants) {
						if (c.visibility != VPrivate) {
							Sys.println('    ${getConst(c)}');
						}
					}
					for (v in cls.vars) {
						if (v.visibility != VPrivate) {
							Sys.println('    ${getVar(v)}');
						}
					}
					for (fn in cls.functions) {
						if (fn.visibility != VPrivate) {
							Sys.println('    ${getFunction(fn)}');
						}
					}
					Sys.println('}');
				}
			}
		}
	}
}
