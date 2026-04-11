const { MongoClient } = require("mongodb");

const { mongoUri } = require("./env");

const client = new MongoClient(mongoUri);

let database;

async function connectToDatabase() {
	await client.connect();
	await client.db("admin").command({ ping: 1 });
	database = client.db("caredify");
	return database;
}

function getCollections() {
	if (!database) {
		throw new Error("Database connection has not been initialized.");
	}

	return {
		ecgDataCollection: database.collection("ecg_data"),
		ecgSessionsCollection: database.collection("ecg_sessions"),
		usersCollection: database.collection("users"),
		locationCollection: database.collection("locations"),
		doctorsCollection: database.collection("doctors"),
	};
}

module.exports = {
	client,
	connectToDatabase,
	getCollections,
};