// models/Car.js
const mongoose = require("mongoose");

const PunishedCarSchema = new mongoose.Schema(
  {
    carNumber: { type: String, required: true },
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    parkedAt: { type: Date, required: true },
  },
  { timestamps: true }
);

const Car = mongoose.model("PunishedCar", PunishedCarSchema);

module.exports = Car;
