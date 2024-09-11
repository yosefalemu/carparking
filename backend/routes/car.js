const express = require("express");
const router = express.Router();
const { createCar, getCars, deleteCar } = require("../controllers/car");

router.route("/").post(createCar).get(getCars);
router.route("/:id").delete(deleteCar);
module.exports = router;
