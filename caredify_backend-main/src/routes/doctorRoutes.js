const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const authMiddleware = require("../middleware/auth");
const { ObjectId } = require("../utils/objectId");

const { jwtSecret } = require("../config/env");

function createDoctorRoutes({ doctorsCollection, usersCollection }) {
	const router = express.Router();


	router.post("/register", async (req, res) => {
		try {
			const { name, email, password, phone } = req.body;

			if (!name || !email || !password || !phone) {
				return res.status(400).json({ message: "name, email, password, and phone are required." });
			}

			const normalizedEmail = String(email).trim().toLowerCase();
			const existingDoctor = await doctorsCollection.findOne({ email: normalizedEmail });

			if (existingDoctor) {
				return res.status(409).json({ message: "Email already exists." });
			}

			const passwordHash = await bcrypt.hash(password, 10);
			const createdAt = new Date();

			await doctorsCollection.insertOne({
				name: String(name).trim(),
				email: normalizedEmail,
				phone: String(phone).trim(),
				passwordHash,
				role: "doctor",
				createdAt,
			});

			return res.status(201).json({ message: "Doctor registered successfully." });
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	router.post("/login", async (req, res) => {
		try {
			const { email, password } = req.body;

			if (!email || !password) {
				return res.status(400).json({ message: "email and password are required." });
			}

			const normalizedEmail = String(email).trim().toLowerCase();
			const doctor = await doctorsCollection.findOne({ email: normalizedEmail });

			if (!doctor) {
				return res.status(401).json({ message: "Invalid email or password." });
			}

			const isPasswordValid = await bcrypt.compare(password, doctor.passwordHash);

			if (!isPasswordValid) {
				return res.status(401).json({ message: "Invalid email or password." });
			}

			const token = jwt.sign(
				{ doctorId: doctor._id.toString(), email: doctor.email, role: "doctor" },
				jwtSecret,
				{ expiresIn: "7d" }
			);

			return res.status(200).json({
				message: "Login successful.",
				token,
				doctor: {
					id: doctor._id,
					name: doctor.name,
					email: doctor.email,
					role: doctor.role,
					createdAt: doctor.createdAt,
				},
			});
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	router.get("/patients", async (req, res) => {
		try {
			const users = await usersCollection.find({}).toArray();
			const patients = users.map(user => ({
				id: user._id.toString(),
				name: user.name,
				email: user.email,
				dateCreated: user.createdAt ? user.createdAt.toISOString() : new Date().toISOString(),
				status: "Normal", // Default status
				recordsCount: 0, // Default count
				imageUrl: "https://i.pravatar.cc/150?u=" + user._id.toString()
			}));
			return res.status(200).json(patients);
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	router.get("/profile", authMiddleware, async (req, res) => {
		try {
			const doctorId = req.user.doctorId;
			if (!doctorId) return res.status(401).json({ message: "Unauthorized." });

			const doctor = await doctorsCollection.findOne(
				{ _id: new ObjectId(doctorId) },
				{ projection: { name: 1, email: 1, phone: 1, createdAt: 1 } }
			);
			if (!doctor) return res.status(404).json({ message: "Doctor not found." });

			return res.status(200).json(doctor);
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	router.put("/profile", authMiddleware, async (req, res) => {
		try {
			const { name, phone } = req.body;
			const doctorId = req.user.doctorId;
			if (!doctorId) return res.status(401).json({ message: "Unauthorized." });

			const updateData = {};
			if (name) updateData.name = String(name).trim();
			if (phone) updateData.phone = String(phone).trim();

			if (Object.keys(updateData).length === 0) {
				return res.status(400).json({ message: "Nothing to update." });
			}

			const result = await doctorsCollection.updateOne(
				{ _id: new ObjectId(doctorId) },
				{ $set: updateData }
			);

			if (result.matchedCount === 0) {
				return res.status(404).json({ message: "Doctor not found." });
			}

			return res.status(200).json({ message: "Profile updated successfully.", updateData });
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	return router;
}

module.exports = createDoctorRoutes;
