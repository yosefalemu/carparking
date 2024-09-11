const express = require("express");
const router = express.Router();
const { createPunishedCar,getPunishedCars,deletePunishedCar} = require("../controllers/punishedCar");

router.route("/").post(createPunishedCar).get(getPunishedCars);
router.route("/:id").delete(deletePunishedCar);
module.exports = router;
