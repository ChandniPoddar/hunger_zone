require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');

const MONGO_URI = process.env.MONGO_URI;
const OLD_IP = "172.20.2.13:5000";
const NEW_IP = "172.25.1.255:5000"; // Should match your new BASE_URL domain

if (!MONGO_URI) {
  console.error("MONGO_URI not found in .env");
  process.exit(1);
}

const ItemSchema = new mongoose.Schema({
  imageUrl: String
});

const collections = ["nescafeitems", "liptonitems", "canteenitems", "fruitcorneritems", "items"];

async function migrate() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("Connected to MongoDB for migration...");

    for (const colName of collections) {
      const Model = mongoose.model(colName, ItemSchema, colName);
      const items = await Model.find({ imageUrl: { $regex: OLD_IP } });
      
      console.log(`Found ${items.length} items in ${colName} with old IP.`);

      for (const item of items) {
        item.imageUrl = item.imageUrl.replace(OLD_IP, NEW_IP);
        await item.save();
      }
      
      if (items.length > 0) {
        console.log(`Migrated ${items.length} items in ${colName}.`);
      }
    }

    console.log("Migration completed successfully!");
    process.exit(0);
  } catch (err) {
    console.error("Migration failed:", err);
    process.exit(1);
  }
}

migrate();
