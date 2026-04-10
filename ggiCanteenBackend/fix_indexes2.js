const mongoose = require("mongoose");
require("dotenv").config();

const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://poddarchandni5_db_user:v2Mx8g9NM6LWtZ7z@cluster0.05shl0n.mongodb.net/ggiCanteen?retryWrites=true&w=majority";

mongoose
  .connect(MONGO_URI)
  .then(async () => {
    console.log("Connected to MongoDB Atlas");
    try {
      const collection = mongoose.connection.collection("users");
      
      // Find users without phoneNumber
      const oldUsers = await collection.find({ phoneNumber: { $exists: false } }).toArray();
      console.log(`Found ${oldUsers.length} users with no phoneNumber. Deleting them...`);
      
      if (oldUsers.length > 0) {
        await collection.deleteMany({ phoneNumber: { $exists: false } });
        console.log("Deleted old users.");
      }
      
      // Find users with null phoneNumber
      const nullUsers = await collection.find({ phoneNumber: null }).toArray();
      console.log(`Found ${nullUsers.length} users with null phoneNumber. Deleting them...`);
      
      if (nullUsers.length > 0) {
        await collection.deleteMany({ phoneNumber: null });
        console.log("Deleted null users.");
      }

      console.log("Creating phoneNumber unique index...");
      await collection.createIndex({ phoneNumber: 1 }, { unique: true });
      console.log("Index created successfully.");
      
      const indexes = await collection.indexes();
      console.log("Final indexes:", indexes);
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
