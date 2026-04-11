const express = require("express");

const authMiddleware = require("../middleware/auth");
const { ObjectId, toObjectIdIfValid } = require("../utils/objectId");

function createEcgRouter({ ecgDataCollection, ecgSessionsCollection }) {
	const router = express.Router();

	router.post("/session/start", authMiddleware, async (req, res) => {
		try {
			const { user_id, device_id } = req.body;

			if (!user_id || !device_id) {
				return res.status(400).json({ message: "user_id and device_id are required." });
			}

			const now = new Date();
			const sessionData = {
				user_id: toObjectIdIfValid(user_id),
				device_id,
				start_time: now,
				created_at: now,
			};

			const result = await ecgSessionsCollection.insertOne(sessionData);

			return res.status(201).json({
				message: "ECG session started successfully.",
				session_id: result.insertedId,
			});
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	router.post("/session/end", authMiddleware, async (req, res) => {
		try {
			const { session_id, end_time } = req.body;

			if (!session_id || !end_time) {
				return res.status(400).json({ message: "session_id and end_time are required." });
			}

			if (!ObjectId.isValid(session_id)) {
				return res.status(400).json({ message: "Invalid session_id." });
			}

			const parsedEndTime = new Date(end_time);

			if (Number.isNaN(parsedEndTime.getTime())) {
				return res.status(400).json({ message: "Invalid end_time format." });
			}

			const result = await ecgSessionsCollection.updateOne(
				{ _id: new ObjectId(session_id) },
				{ $set: { end_time: parsedEndTime } }
			);

			if (result.matchedCount === 0) {
				return res.status(404).json({ message: "Session not found." });
			}

			return res.status(200).json({ message: "ECG session ended successfully." });
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	router.get("/sessions/:userId", authMiddleware, async (req, res) => {
		try {
			const { userId } = req.params;
			const userIdFilter = toObjectIdIfValid(userId);
			const sessions = await ecgSessionsCollection
				.find({ user_id: userIdFilter })
				.sort({ created_at: -1 })
				.toArray();

			return res.status(200).json(sessions);
		} catch (error) {
			return res.status(500).json({ message: "Server error.", error: error.message });
		}
	});

	return router;
}

module.exports = createEcgRouter;