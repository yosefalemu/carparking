const { StatusCodes } = require("http-status-codes");
const Rate = require("../models/rate");

const createRate = async (req, res) => {
  console.log("REQUEST SEND", req.body);

  try {
    let rate = await Rate.findOne();
    if (rate) {
      rate = await Rate.findOneAndUpdate({}, req.body, { new: true });
    } else {
      rate = await Rate.create(req.body);
    }

    res.status(StatusCodes.OK).json({ rate });
  } catch (error) {
    res.status(StatusCodes.BAD_REQUEST).json({ error: error.message });
  }
};

// Handle retrieving the rate
const getRate = async (req, res) => {
  try {
    const rate = await Rate.findOne(); // Use findOne to get a single document

    if (rate) {
      // Respond with the rate as a numeric value
      res.status(StatusCodes.OK).json({ rate: rate.rate });
    } else {
      res.status(StatusCodes.NOT_FOUND).json({ message: "Rate not found" });
    }
  } catch (error) {
    res
      .status(StatusCodes.INTERNAL_SERVER_ERROR)
      .json({ error: error.message });
  }
};

module.exports = { createRate, getRate };
