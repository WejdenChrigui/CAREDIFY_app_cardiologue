require("dotenv").config();

const port = Number(process.env.PORT) || 5000;
const uriTemplate = process.env.MONGODB_URI_TEMPLATE;
const dbPassword = process.env.DB_PASSWORD;
const jwtSecret = process.env.JWT_SECRET;

if (!uriTemplate) {
	console.error("Missing MONGODB_URI_TEMPLATE in .env file.");
	process.exit(1);
}

if (!dbPassword) {
	console.error("Missing DB_PASSWORD in .env file.");
	process.exit(1);
}

if (!uriTemplate.includes("<db_password>")) {
	console.error("MONGODB_URI_TEMPLATE must include <db_password> placeholder.");
	process.exit(1);
}

if (!jwtSecret) {
	console.error("Missing JWT_SECRET in .env file.");
	process.exit(1);
}

const mongoUri = uriTemplate.replace("<db_password>", encodeURIComponent(dbPassword));

module.exports = {
	jwtSecret,
	mongoUri,
	port,
};