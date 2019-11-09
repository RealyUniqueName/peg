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

	static function getFunction(fn:peg.php.PFunction, isNamespaceGlobal:Bool = false, ?namespace:String):String {
		var args = fn.args.map(arg -> '${getVarName(arg.name)}:${getType(arg.type)}').join(', ');
		var inlineCallParams = fn.args.map(arg -> getVarName(arg.name)).join(', ');
		var callSite = '';
		if (isNamespaceGlobal) {
			var ns = namespace != '' ? '\\\\${namespace}\\\\': '';
			callSite = ' return untyped __call__(\'${ns}${fn.name}\'${inlineCallParams != '' ? ', ' + inlineCallParams : ''})';
		}
		return '${fn.isAbstract ? 'abstract ' : ''}${fn.isFinal ? 'final ' : ''}${fn.visibility}${isNamespaceGlobal || fn.isStatic ? ' static inline' : ''} function ${fn.name}(${args}):${getType(fn.returnType)}${callSite};';
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
			var slashesRE = ~/\\/g;
			var leadingDotRE = ~/^\./;

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
					if (cls.parent != null && cls.parent != '') {
						clsExtends = 'extends ${basePackage}.';
						if (namespace.name == '') {
							clsExtends += 'GLOBALS.';
					 	}
						clsExtends += parent;
					}
					var imp = cls.interfaces.length > 0 ? 'implements ${cls.interfaces.join(', ')}' : '';

					Sys.println('@:native(\'\\\\' + phpNS + cls.name + '\')');
					Sys.println('extern ${kwd} ${cls.name} ${clsExtends} ${imp} {');
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
