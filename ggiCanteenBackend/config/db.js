// db.js
const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    await mongoose.connect(
      "mongodb+srv://poddarchandni5_db_user:v2Mx8g9NM6LWtZ7z@cluster0.05shl0n.mongodb.net/ggiCanteen?retryWrites=true&w=majority",
      {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      }
    );

    console.log("✅ MongoDB Atlas Connected");
  } catch (error) {
    console.error("❌ MongoDB connection error:", error);
    process.exit(1);
  }
};

module.exports = connectDB;
