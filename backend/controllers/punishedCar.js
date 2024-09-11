const { StatusCodes } = require("http-status-codes");
const PunishedCar = require("../models/punishedCar");

const createPunishedCar = async (req, res) => {
  console.log("RESTED TO CREATE PUNISH", req.body);

  try {
    const car = await PunishedCar.create(req.body);
    console.log("CREATED CAR", car);

    res.status(StatusCodes.OK).json({ car });
  } catch (error) {
    console.error("Error creating car:", error);
    res
      .status(StatusCodes.INTERNAL_SERVER_ERROR)
      .json({ error: "Failed to create car" });
  }
};

const getPunishedCars = async (req, res) => {
  try {
    const cars = await PunishedCar.find();
    console.log("FOUND CARS", cars);

    res.status(StatusCodes.OK).json(cars);
  } catch (error) {
    console.error("Error fetching cars:", error);
    res
      .status(StatusCodes.INTERNAL_SERVER_ERROR)
      .json({ error: "Failed to fetch cars" });
  }
};

const deletePunishedCar = async (req, res) => {
  try {
    const id = req.params.id;
    console.log("ID FOUND", id);
    const car = await PunishedCar.findByIdAndDelete(id);
    if (!car) {
      throw new Error("No car found");
    }
    res.status(StatusCodes.OK).json(car);
  } catch (error) {
    console.error("Error fetching cars:", error);
    res
      .status(StatusCodes.INTERNAL_SERVER_ERROR)
      .json({ error: "Failed to fetch cars" });
  }
};

module.exports = { createPunishedCar, getPunishedCars, deletePunishedCar };
