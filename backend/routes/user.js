const express = require("express");
const router = express.Router();
const { authUser, registerUser } = require("../controllers/user");

router.route("/register").post(registerUser);
router.route("/login").post(authUser);

module.exports = router;
