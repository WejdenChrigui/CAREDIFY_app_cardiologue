const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const { jwtSecret } = require("../config/env");

function createAuthRouter({ usersCollection }) {
	const router = express.Router();

	router.post("/register", async (req, res) => {
		try {
			const { name, email, password } = req.body;

			if (!name || !email || !password) {
				return res.status(400).json({ message: "name, email, and password are required." });
			}

			const normalizedEmail = String(email).trim().toLowerCase();
			const existingUser = await usersCollection.findOne({ email: normalizedEmail });

			if (existingUser) {
				return res.status(409).json({ message: "Email already exists." });
			}

			const passwordHash = await bcrypt.hash(password, 10);
			const createdAt = new Date();

			await usersCollection.insertOne({
				name: String(name).trim(),
				email: normalizedEmail,
				passwordHash,
				createdAt,
			});

			return res.status(201).json({ message: "User registered successfully." });
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
			const user = await usersCollection.findOne({ email: normalizedEmail });

			if (!user) {
				return res.status(401).json({ message: "Invalid email or password." });
			}

			const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

			if (!isPasswordValid) {
				return res.status(401).json({ message: "Invalid email or password." });
			}

			const token = jwt.sign(
				{ userId: user._id.toString(), email: user.email },
				jwtSecret,
				{ expiresIn: "7d" }
			);

			return res.status(200).json({
				message: "Login successful.",
				token,
				user: {
					id: user._id,
					name: user.name,
					email: user.email,
					createdAt: user.createdAt,
				},
			});
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	return router;
}

module.exports = createAuthRouter;