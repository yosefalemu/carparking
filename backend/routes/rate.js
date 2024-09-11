const express = require("express");
const router = express.Router();
const { createRate, getRate } = require("../controllers/rate");

router.route("/").post(createRate).get(getRate);
module.exports = router;
