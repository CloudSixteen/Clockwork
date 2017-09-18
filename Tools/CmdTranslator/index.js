var fs = require("fs");
var path = require("path");

fs.readdir("./cmds", function(err, files) {
	var langOutput = "";
	
	if (err) {
		console.error("Unable to list directory.", err);
		process.exit(1);
	}
	
	files.forEach(function(file, index) {
		var contents = fs.readFileSync("./cmds/" + file, "utf8");
		var name = contents.match(/\:New\("(.+)"\)/);
		
		if (!name || !name[1]) {
			console.error(file + " has no command name!");
			process.exit(1);
		}
		
		var desc = contents.match(/COMMAND\.tip = "(.+)";/)[1];
		
		if (!desc) {
			console.error(file + " has no COMMAND.tip!");
			process.exit(1);
		}
		
		var descTxt = contents.match(/COMMAND\.text = "(.+)";/);
		var langName = "Cmd" + name[1].replace(/\W+/g, "");
		var langNameDesc = "Cmd" + name[1].replace(/\W+/g, "") + "Desc";
		
		contents = contents.replace(desc, langName);
		
		if (descTxt) {
			contents = contents.replace(descTxt[1], langNameDesc);
		}
		
		fs.writeFileSync("./cmds/" + file, contents, "utf8");
		
		langOutput += 'CW_ENGLISH["' + langName + '"] = "' + desc + '";\n';
		
		if (descTxt) {
			langOutput += 'CW_ENGLISH["' + langNameDesc + '"] = "' + descTxt[1] + '";\n';
		}
		
		console.log("Processed: " + name[1] + " (" + file + ")");
	});
	
	fs.writeFileSync("./sh_language.lua", langOutput, "utf8");
});