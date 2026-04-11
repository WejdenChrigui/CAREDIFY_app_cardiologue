const { ObjectId } = require("mongodb");

function toObjectIdIfValid(value) {
	if (!value) {
		return null;
	}

	return ObjectId.isValid(value) ? new ObjectId(value) : value;
}

module.exports = {
	ObjectId,
	toObjectIdIfValid,
};