const express = require("express");
const connectToDatabase = require("./utils/db");

const app = express();
const userRouter = require("./routes/user");
const carRouter = require("./routes/car");
const rateRouter = require("./routes/rate");
const punishedRouter = require("./routes/punishedCar")
const cors = require("cors");
const port = 3000;

app.use(express.json());
app.use(cors());
app.use("/user", userRouter);
app.use("/car", carRouter);
app.use("/rate", rateRouter);
app.use("/punish",punishedRouter)

connectToDatabase()
  .then(() => {
    app.listen(port, () => {
      console.log(`Server running on port ${port}`);
    });
  })
  .catch((error) => {
    console.error(
      "Failed to start server due to database connection error:",
      error
    );
    process.exit(1);
  });
