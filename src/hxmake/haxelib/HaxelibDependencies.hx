package hxmake.haxelib;

import hxmake.utils.Haxelib;

using StringTools;

class HaxelibDependencies extends Task {

	public function new() {}

	override public function run() {
		var dependencies = collectDependencies(module.allModules);
		installDependencies(dependencies);
	}

	function collectDependencies(modules:Array<Module>) {
		var dependencies:Map<String, Array<String>> = new Map();
		for(mod in modules) {
			var moduleDeps = mod.config.getAllDependencies();
			for(lib in moduleDeps.keys()) {
				var sections:Array<String> = moduleDeps.get(lib).split(";");
				var params:String = sections[0];
				if(params == "haxelib" || params.indexOf("haxelib:") == 0) {
					var settedArgs = dependencies.get(lib);
					if(settedArgs == null) {
						dependencies.set(lib, sections);
					}
					else if(settedArgs[0] != params) {
						Sys.println("WARNING: " + mod.name + " has conflict dependency");
					}
				}
			}
		}
		return dependencies;
	}

	function installDependencies(dependencies:Map<String, Array<String>>) {
		for(lib in dependencies.keys()) {
			var sections:Array<String> = dependencies.get(lib);
			var ver = sections.shift();
			var isHaxelib:Bool = false;
			var isGit:Bool = false;
			var isGlobal:Bool = false;
			var params:String = null;
			if(ver == "haxelib") {
				isHaxelib = true;
			}
			else if(ver.indexOf("haxelib:") == 0) {
				isHaxelib = true;
				params = ver.substring("haxelib:".length);
				if(params.endsWith(".git")) {
					isGit = true;
				}
				if(sections.indexOf("global") >= 0) {
					isGlobal = true;
				}
			}
			if(isHaxelib) {
				var args:Array<String> = null;
				if(!Haxelib.checkInstalled(lib)) {
					if(isGit) {
						args = ["git", lib, params];
					}
					else {
						args = ["install", lib];
					}
				}
				else {
					args = ["update", lib];
				}

				if(isGlobal) {
					args.unshift("--global");
				}

				Sys.command("haxelib", args);
			}
		}
	}
}
