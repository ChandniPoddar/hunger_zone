const fs = require('fs');
const path = require('path');
if (fs.existsSync('.env')) {
  require('dotenv').config();
} else if (fs.existsSync('../.env')) {
  require('dotenv').config({ path: '../.env' });
}
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const multer = require("multer");
const app = express();

// Ensure uploads folder exists
if (!fs.existsSync("./uploads")) {
  fs.mkdirSync("./uploads");
}

// Multer settings
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Middleware
app.use(express.json());
app.use(cors());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// -------------------
// MongoDB Atlas Connection
// -------------------
const MONGO_URI = process.env.MONGO_URI || "mongodb+srv://poddarchandni5_db_user:v2Mx8g9NM6LWtZ7z@cluster0.05shl0n.mongodb.net/ggiCanteen?retryWrites=true&w=majority";

mongoose
  .connect(MONGO_URI)
  .then(() => console.log("✅ MongoDB Atlas Connected"))
  .catch((error) => {
    console.error("❌ MongoDB connection error:", error);
    process.exit(1);
  });

// -------------------
// Mongoose User Schema (Updated to match Flutter)
// -------------------
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, default: "user" },
  outletName: { type: String, default: null } // Useful for admins/operators
});

const User = mongoose.model("User", UserSchema);

// -------------------
// Routes
// -------------------
app.use("/api/orders", require("./routes/orderRoutes"));

// 1. Signup Route (Matched to Flutter AuthService)
// Flutter calls: http://10.0.2.2:5000/signup
app.post("/signup", async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: "Email already registered" });
    }

    const user = new User({
      name,
      email: email.toLowerCase(),
      password, // Note: In production, use bcrypt to hash this!
      role: role || "user"
    });

    await user.save();
    console.log(`User created: ${email}`);

    // Return the user data so Flutter can update state
    res.status(201).json({
      message: "User created successfully",
      role: user.role,
      name: user.name
    });
  } catch (err) {
    console.error("Error creating user:", err);
    res.status(500).json({ message: "Server error during signup" });
  }
});

// 2. Login Route (Matched to Flutter AuthService)
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user || user.password !== password) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    res.status(200).json({
      email: user.email,
      role: user.role,
      name: user.name,
      outletName: user.outletName
    });
  } catch (err) {
    res.status(500).json({ message: "Server error during login" });
  }
});

//operator -->
//operator -->
// Add this Schema to your server.js
const ItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  category: { type: String, required: true },
  imageUrl: { type: String, required: true }, // We will store the URL
  createdAt: { type: Date, default: Date.now }
});

// Create separate collections (tables) for different operators
const NescafeItem = mongoose.model("NescafeItem", ItemSchema);
const LiptonItem = mongoose.model("LiptonItem", ItemSchema);
const CanteenItem = mongoose.model("CanteenItem", ItemSchema);
const FruitCornerItem = mongoose.model("FruitCornerItem", ItemSchema);
const GenericItem = mongoose.model("Item", ItemSchema); // Fallback

// Add this Route to handle adding new items
app.post("/add-item", upload.single("image"), async (req, res) => {
  try {
    const { name, price, category } = req.body;
    let imageUrl = req.body.imageUrl;

    if (req.file) {
      imageUrl = `${process.env.BASE_URL}/uploads/${req.file.filename}`;
    }

    if (!name || !price || !category || !imageUrl) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // Route the insertion to specific collections based on category
    let TargetModel;
    switch (category) {
      case "Nescafe":
        TargetModel = NescafeItem;
        break;
      case "Lipton":
        TargetModel = LiptonItem;
        break;
      case "Canteen":
        TargetModel = CanteenItem;
        break;
      case "Fruit Corner":
        TargetModel = FruitCornerItem;
        break;
      default:
        TargetModel = GenericItem;
    }

    const newItem = new TargetModel({ name, price, category, imageUrl });
    await newItem.save();

    res.status(201).json({ message: "Item added successfully to " + TargetModel.modelName });
  } catch (err) {
    res.status(500).json({ message: "Error saving item to database" });
  }
});

// Get items by category
app.get("/items/:category", async (req, res) => {
  try {
    const category = req.params.category;
    let TargetModel;

    switch (category.toLowerCase()) {
      case "nescafe":
        TargetModel = NescafeItem;
        break;
      case "lipton":
        TargetModel = LiptonItem;
        break;
      case "canteen":
        TargetModel = CanteenItem;
        break;
      case "fruit":
      case "fruit corner":
        TargetModel = FruitCornerItem;
        break;
      default:
        TargetModel = GenericItem;
    }

    const items = await TargetModel.find({});
    res.status(200).json(items);
  } catch (err) {
    res.status(500).json({ message: "Error fetching items" });
  }
});

// Delete item by ID
app.delete("/item/:category/:id", async (req, res) => {
  try {
    const { category, id } = req.params;
    let TargetModel;

    switch (category.toLowerCase()) {
      case "nescafe":
        TargetModel = NescafeItem;
        break;
      case "lipton":
        TargetModel = LiptonItem;
        break;
      case "canteen":
        TargetModel = CanteenItem;
        break;
      case "fruit":
      case "fruit corner":
        TargetModel = FruitCornerItem;
        break;
      default:
        TargetModel = GenericItem;
    }

    await TargetModel.findByIdAndDelete(id);
    res.status(200).json({ message: "Item deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: "Error deleting item" });
  }
});

// Test route
app.get("/", (req, res) => {
  res.send("GGI Canteen Server is running!");
});

// -------------------
// Start Server
// -------------------
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});