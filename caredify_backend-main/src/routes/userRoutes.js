const express = require("express");

const authMiddleware = require("../middleware/auth");
const { ObjectId } = require("../utils/objectId");

function createUserRouter({ usersCollection }) {
	const router = express.Router();

	router.get("/profile", authMiddleware, async (req, res) => {
		try {
			const user = await usersCollection.findOne(
				{ _id: new ObjectId(req.user.userId) },
				{ projection: { name: 1, email: 1, createdAt: 1 } }
			);

			if (!user) {
				return res.status(404).json({ message: "User not found." });
			}

			return res.status(200).json(user);
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	return router;
}

module.exports = createUserRouter;