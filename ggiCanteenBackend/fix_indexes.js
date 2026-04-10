const mongoose = require("mongoose");
require("dotenv").config();

const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://poddarchandni5_db_user:v2Mx8g9NM6LWtZ7z@cluster0.05shl0n.mongodb.net/ggiCanteen?retryWrites=true&w=majority";

mongoose
  .connect(MONGO_URI)
  .then(async () => {
    console.log("Connected to MongoDB Atlas");
    try {
      // Get the User collection
      const collection = mongoose.connection.collection("users");
      
      // List indexes
      const indexes = await collection.indexes();
      console.log("Current indexes:", indexes);
      
      // Check if email index exists
      const emailIndex = indexes.find(i => i.name === 'email_1');
      if (emailIndex) {
        console.log("Dropping email_1 index...");
        await collection.dropIndex("email_1");
        console.log("Index dropped successfully.");
      } else {
        console.log("No email_1 index found.");
      }
    } catch (err) {
      console.error("Error:", err);
    } finally {
      mongoose.disconnect();
    }
  })
  .catch((error) => {
    console.error("MongoDB connection error:", error);
    process.exit(1);
  });
