const express = require("express");
const cors = require("cors");

const createAuthRouter = require("./routes/authRoutes");
const createEcgDataRouter = require("./routes/ecgDataRoutes");
const createEcgRouter = require("./routes/ecgRoutes");
const createUserRouter = require("./routes/userRoutes");
const createDoctorRoutes = require("./routes/doctorRoutes");
const createLocationRouter = require('./routes/locationRoutes'); // Importation du routeur de localisation

function createApp(collections) {
	const app = express();
	app.use(cors());
	app.use(express.json());
	
	// Request logging middleware
	app.use((req, res, next) => {
		console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
		next();
	});
	
	app.use("/auth", createAuthRouter(collections));
	app.use("/doctor", createDoctorRoutes(collections));
	app.use("/users", createUserRouter(collections));
	app.use("/ecg", createEcgRouter(collections));
	app.use("/api/ecg", createEcgDataRouter(collections));
	
	// Location routes
	app.use("/api/location", createLocationRouter(collections));
	console.log('✅ Location routes registered at: /api/location/send');
	
	app.get("/", (req, res) => {
		res.status(200).json({ message: "Caredify backend is running." });
	});
	return app;
}
module.exports = createApp;