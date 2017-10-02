var fs = require("fs");
var path = require("path");

fs.readdir("./victories", function(err, files) {
	var langOutput = "";
	
	if (err) {
		console.error("Unable to list directory.", err);
		process.exit(1);
	}
	
	files.forEach(function(file, index) {
		console.log("Processing: " + file);
		var contents = fs.readFileSync("./victories/" + file, "utf8");
		var name = contents.match(/VICTORY\.name = "(.+)";/);
		
		if (!name || !name[1]) {
			console.error(file + " has no VICTORY.name!");
			process.exit(1);
		}
		
		var desc = contents.match(/VICTORY\.description = "(.+)";/);
		
		if (desc) {
			desc = desc[1];
		}
		
		var title = contents.match(/VICTORY\.unlockTitle = "(.+)";/);
		
		if (title) {
			title = title[1];
		}
		
		var langName = "Victory" + name[1].replace(/\W+/g, "");
		var langNameDesc = langName + "Desc";
		var langNameTitle = langName + "Title";
		
		contents = contents.replace(name[1], langName);
		
		if (desc) {
			contents = contents.replace(desc, langNameDesc);
		}
		
		if (title) {
			contents = contents.replace(title, langNameTitle);
		}
		
		fs.writeFileSync("./victories/" + file, contents, "utf8");
		
		langOutput += 'CW_ENGLISH["' + langName + '"] = "' + name[1] + '";\n';
		
		if (desc) {
			langOutput += 'CW_ENGLISH["' + langNameDesc + '"] = "' + desc + '";\n';
		}
		
		if (title) {
			langOutput += 'CW_ENGLISH["' + langNameTitle + '"] = "' + title + '";\n';
		}
		
		console.log("Processed: " + name[1] + " (" + file + ")");
	});
	
	fs.writeFileSync("./sh_language.lua", langOutput, "utf8");
});