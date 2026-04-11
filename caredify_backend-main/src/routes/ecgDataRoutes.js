const express = require("express");

function createEcgDataRouter({ ecgDataCollection }) {
	const router = express.Router();

	// POST /data - Receive and store ECG data with metadata
	router.post("/data", async (req, res) => {
		try {
			const { 
				ecgData, 
				deviceId, 
				recordedAt, 
				duration, 
				dataPoints,
				user,     // { id, name }
				location, // { latitude, longitude, address }
				csvData,  // raw readings as string
				aiStatus  // analysis result
			} = req.body;

			console.log(`[BACKEND] Received ECG sync from user ${user?.name || 'Unknown'} (Device: ${deviceId})`);

			// Validate essential data (either ecgData array or csvData string)
			if ((!ecgData || !Array.isArray(ecgData)) && !csvData) {
				return res.status(400).json({ message: "ECG data is required." });
			}

			const ecgDocument = {
				device_id: deviceId,
				user_id: user?.id || null,
				user_name: user?.name || 'Anonymous',
				location: {
					latitude: location?.latitude || 0,
					longitude: location?.longitude || 0,
					address: location?.address || 'Not provided'
				},
				csv_data: csvData || '',
				recorded_at: recordedAt ? new Date(recordedAt) : new Date(),
				duration: duration || "batch",
				data_points: dataPoints || (ecgData ? ecgData.length : 0),
				ecg_data: ecgData || [],
				created_at: new Date(),
			};

			// If aiStatus is provided from frontend, use it. Otherwise, calculate mock.
			let finalStatus = aiStatus || "NORMAL";
			if (!aiStatus && ecgData && ecgData.length > 0) {
				const avgValue = ecgData.reduce((sum, p) => sum + (p.value || 0), 0) / ecgData.length;
				if (avgValue > 150) finalStatus = "DANGER";
				else if (avgValue > 100) finalStatus = "A_SURVEILLER";
			}
			ecgDocument.aiStatus = finalStatus;

			const result = await ecgDataCollection.insertOne(ecgDocument);

			return res.status(201).json({
				success: true,
				message: "ECG sync successful.",
				data_id: result.insertedId,
				aiStatus: finalStatus,
			});
		} catch (error) {
			console.error("Error processing ECG data:", error);
			return res.status(500).json({
				message: "Server error while processing ECG data.",
				error: error.message,
			});
		}
	});

	// GET /history/:userId - Fetch history for a specific user
	router.get("/history/:userId", async (req, res) => {
		try {
			const { userId } = req.params;
			console.log(`[BACKEND] Fetching history for user: ${userId}`);

			const history = await ecgDataCollection
				.find({ user_id: userId })
				.sort({ created_at: -1 }) // Most recent first
				.limit(50)
				.toArray();

			return res.status(200).json(history);
		} catch (error) {
			console.error("Error fetching ECG history:", error);
			return res.status(500).json({
				message: "Server error while fetching history.",
				error: error.message
			});
		}
	});

	return router;
}

module.exports = createEcgDataRouter;