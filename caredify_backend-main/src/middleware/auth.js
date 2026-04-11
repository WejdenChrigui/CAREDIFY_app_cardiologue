const jwt = require("jsonwebtoken");

const { jwtSecret } = require("../config/env");

function authMiddleware(req, res, next) {
	const authHeader = req.headers.authorization || "";
	const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;

	if (!token) {
		return res.status(401).json({ message: "Unauthorized: Missing token." });
	}

	try {
		const decoded = jwt.verify(token, jwtSecret);
		req.user = decoded;
		return next();
	} catch (error) {
		return res.status(401).json({ message: "Unauthorized: Invalid token." });
	}
}

module.exports = authMiddleware;