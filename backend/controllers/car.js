const { StatusCodes } = require("http-status-codes");
const Car = require("../models/car");

const createCar = async (req, res) => {
  try {
    const car = await Car.create(req.body);
    console.log("CREATED CAR", car);

    res.status(StatusCodes.CREATED).json({ car });
  } catch (error) {
    console.error("Error creating car:", error);
    res
      .status(StatusCodes.INTERNAL_SERVER_ERROR)
      .json({ error: "Failed to create car" });
  }
};

const getCars = async (req, res) => {
  try {
    const cars = await Car.find();
    console.log("FOUND CARS", cars);

    res.status(StatusCodes.OK).json(cars);
  } catch (error) {
    console.error("Error fetching cars:", error);
    res
      .status(StatusCodes.INTERNAL_SERVER_ERROR)
      .json({ error: "Failed to fetch cars" });
  }
};

const deleteCar = async (req, res) => {
  try {
    const id = req.params.id;
    console.log("ID FOUND", id);
    const car = await Car.findByIdAndDelete(id);
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

module.exports = { createCar, getCars, deleteCar };
