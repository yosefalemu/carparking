// controllers/authController.js
const User = require("../models/user");
const jwt = require("jsonwebtoken");

exports.registerUser = async (req, res) => {
  const { companyName, email, password } = req.body;
  const userExists = await User.findOne({ email });
  if (userExists) {
    return res.status(400).json({ message: "User already exists" });
  }
  const newUser = new User({ email, password, companyName });
  await newUser.save();
  console.log("CREATED USER", newUser);

  if (newUser) {
    res.status(201).json({
      _id: newUser._id,
      companyName: newUser.companyName,
      email: newUser.email,
    });
  } else {
    res.status(400).json({ message: "Invalid user data" });
  }
};

exports.authUser = async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });
  if (user && (await user.matchPassword(password))) {
    res.json({
      _id: user._id,
      email: user.email,
    });
  } else {
    res.status(401).json({ message: "Invalid email or password" });
  }
};
