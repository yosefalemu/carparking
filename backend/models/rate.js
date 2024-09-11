const mongoose = require("mongoose");
const RateSchema = new mongoose.Schema({
  rate: { type: Number, required: true, unique: true },
});
const Rate = mongoose.model("Rate", RateSchema);
module.exports = Rate;
