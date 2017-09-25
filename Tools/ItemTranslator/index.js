var fs = require("fs");
var path = require("path");

fs.readdir("./items", function(err, files) {
	var langOutput = "";
	
	if (err) {
		console.error("Unable to list directory.", err);
		process.exit(1);
	}
	
	files.forEach(function(file, index) {
		console.log("Processing: " + file);
		var contents = fs.readFileSync("./items/" + file, "utf8");
		var name = contents.match(/ITEM\.name = "(.+)";/);
		
		if (!name || !name[1]) {
			console.error(file + " has no ITEM.name!");
			process.exit(1);
		}
		
		var desc = contents.match(/ITEM\.description = "(.+)";/);
		
		if (desc) {
			desc = desc[1];
		}
		
		var uniqueID = contents.match(/ITEM\.uniqueID = "(.+)";/);
		
		if (!uniqueID || !uniqueID[1]) {
			uniqueID = name[1].replace(/\W+/g, "_").toLowerCase();
			contents = contents.replace(/ITEM\.name = "(.+)";/, name[0] + '\nITEM.uniqueID = "' + uniqueID + '";');
		} else {
			uniqueID = uniqueID[1];
		}
		
		var langName = "Item" + name[1].replace(/\W+/g, "");
		var langNameDesc = langName + "Desc";
		
		contents = contents.replace(name[1], langName);
		
		if (desc) {
			contents = contents.replace(desc, langNameDesc);
		}
		
		fs.writeFileSync("./items/" + file, contents, "utf8");
		
		langOutput += 'CW_ENGLISH["' + langName + '"] = "' + name[1] + '";\n';
		
		if (desc) {
			langOutput += 'CW_ENGLISH["' + langNameDesc + '"] = "' + desc + '";\n';
		}
		
		console.log("Processed: " + name[1] + " (" + file + ")");
	});
	
	fs.writeFileSync("./sh_language.lua", langOutput, "utf8");
});