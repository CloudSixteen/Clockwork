var fs = require("fs");
var path = require("path");

fs.readdir("./attributes", function(err, files) {
	var langOutput = "";
	
	if (err) {
		console.error("Unable to list directory.", err);
		process.exit(1);
	}
	
	files.forEach(function(file, index) {
		var contents = fs.readFileSync("./attributes/" + file, "utf8");
		var name = contents.match(/\:New\("(.+)"\)/);
		
		if (!name || !name[1]) {
			console.error(file + " has no attribute name!");
			process.exit(1);
		}
		
		var descTxt = contents.match(/ATTRIBUTE\.description = "(.+)";/);
		var langName = "Attribute" + name[1].replace(/\W+/g, "");
		var langNameDesc = "Attribute" + name[1].replace(/\W+/g, "") + "Desc";
		
		contents = contents.replace("\"" + name[1] + "\"", "\"" + langName + "\"");
		
		if (descTxt) {
			contents = contents.replace(descTxt[1], langNameDesc);
		}
		
		fs.writeFileSync("./attributes/" + file, contents, "utf8");
		
		langOutput += 'CW_ENGLISH["' + langName + '"] = "' + name[1] + '";\n';
		
		if (descTxt) {
			langOutput += 'CW_ENGLISH["' + langNameDesc + '"] = "' + descTxt[1] + '";\n';
		}
		
		console.log("Processed: " + name[1] + " (" + file + ")");
	});
	
	fs.writeFileSync("./sh_language.lua", langOutput, "utf8");
});