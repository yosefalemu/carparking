// models/Car.js
const mongoose = require("mongoose");

const CarSchema = new mongoose.Schema(
  {
    carNumber: { type: String, required: true },
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    punished: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const Car = mongoose.model("Car", CarSchema);

module.exports = Car;
