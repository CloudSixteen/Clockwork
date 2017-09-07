/*
	© 2017 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
*/

import * as express from "express";
import * as session from "express-session";
import * as bodyParser from "body-parser";
import * as logger from "morgan";
import * as path from "path";

const app = express();

app.set("port", process.env.PORT || 3000);
app.set("views", path.join(__dirname, "../views"));
app.set("view engine", "pug");
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.use(express.static(path.join(__dirname, "../public"), {maxAge: 31557600000}));

app.get("/", (req: express.Request, res: express.Response) => {
    res.render("home");
});

app.listen(app.get("port"), () => {
    console.log("Documentation is running at http://localhost:" + app.get("port"));
});

module.exports = app;