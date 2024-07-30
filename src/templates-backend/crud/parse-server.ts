import express from "express";
import ParseServer from "parse-server";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const api = new ParseServer({
  databaseURI: process.env.PARSE_SERVER_DATABASE_URI,
  cloud: process.env.CLOUD_CODE_MAIN || __dirname + "/cloud/main.js",
  appId: process.env.PARSE_SERVER_APPLICATION_ID,
  masterKey: process.env.PARSE_SERVER_MASTER_KEY,
  serverURL: process.env.PARSE_SERVER_URL || "http://localhost:1337/parse",
});

app.use("/parse", api);

app.listen(1337, () => {
  console.log("Parse Server running on port 1337.");
});
