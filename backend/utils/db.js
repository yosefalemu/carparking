const mongoose = require("mongoose");

const connectToDatabase = () => {
  return new Promise((resolve, reject) => {
    mongoose
      .connect(
        "mongodb+srv://yosefalemu007:ETWge4xkcFw3LgUR@cluster0.zosay.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
      )
      .then(() => {
        console.log("Connected to MongoDB");
        resolve();
      })
      .catch((error) => {
        console.error("MongoDB connection error:", error);
        reject(error);
      });
  });
};

module.exports = connectToDatabase;
