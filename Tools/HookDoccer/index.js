var fs = require("fs");
var path = require("path");

function processFile(namespace, file) {
	var contents = fs.readFileSync(file, "utf8");
	var matches = contents.match(/-- (.+?)\r\n\s*?function.*?\r\n/g);

	if (!matches) {
		return;
	}

	matches.forEach((match) => {
		var details = match.match(/-- (.+?)\r\n/);
		var detailsInside = details[1];
		var spacingMatch = match.match(/\r\n(\s+)function/);
		
		if (spacingMatch) {
			spacingMatch = spacingMatch[1] ? spacingMatch[1] : spacingMatch[0];
		} else {
			spacingMatch = "";
		}

		var params = match.match(/function.*?\((.+?)\)\r\n/);
		var finalParams = [];

		if (params) {
			var paramsSplit = (params[1] ? params[1] : params[0]).split(",");
			paramsSplit.forEach((p) => {
				finalParams.push(p.trim());
			});
		}

		var paramString = "";
		
		if (finalParams.length > 0) {
			let paramsLeft = finalParams.length;

			finalParams.forEach((p) => {
				paramsLeft--;
				if (paramsLeft > 0) {
					paramString += "@param {Unknown} Missing description for " + p + ".\r\n" + spacingMatch + "\t";
				} else {
					paramString += "@param {Unknown} Missing description for " + p + ".";
				}
			});
		}

		let target = match.match(/(-- .*?\r\n)/);

		if (paramString !== "") {
			contents = contents.replace(target[0], `--[[\r\n` + spacingMatch + `\t@codebase ` + namespace + `\r\n` + spacingMatch + `\t@details ` + detailsInside + `\r\n` + spacingMatch + `\t` + paramString + `\r\n` + spacingMatch + `\t@returns {Unknown}\r\n` + spacingMatch + `--]]\r\n`);
		} else {
			contents = contents.replace(target[0], `--[[\r\n` + spacingMatch + `\t@codebase ` + namespace + `\r\n` + spacingMatch + `\t@details ` + detailsInside + `\r\n` + spacingMatch + `\t@returns {Unknown}\r\n` + spacingMatch + `--]]\r\n`);
		}
	});

	fs.writeFileSync(file, contents, "utf8");
}

function loadFrom(location) {
	fs.readdir("./" + location, function(err, files) {
		if (err) {
			console.error("Unable to list directory", err);
			process.exit(1);
		}
	
		files.forEach(function(file) {
			let namespace;

			if (file.startsWith("sv_")) {
				namespace = "Server";
			} else if (file.startsWith("cl_")) {
				namespace = "Client";
			} else if (file.startsWith("sh_")) {
				namespace = "Shared";
			}

			if (namespace) {
				console.log("Processing " + file);
				processFile(namespace, "./" + location + "/" + file);
			}
		});
	});
}

loadFrom("input");
