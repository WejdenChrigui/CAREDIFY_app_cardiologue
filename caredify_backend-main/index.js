const { connectToDatabase, getCollections } = require("./src/config/db");
const { port } = require("./src/config/env");
const createApp = require("./src/app");

async function startServer() {
	try {
		await connectToDatabase();
		const app = createApp(getCollections());

		app.listen(port, () => {
			console.log("Connected to MongoDB Atlas successfully.");
			console.log(`Server is running on port ${port}.`);
		});
	} catch (error) {
		console.error("MongoDB connection failed:", error.message);
		process.exit(1);
	}
}

startServer();
