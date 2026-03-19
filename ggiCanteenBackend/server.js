// server.js
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// -------------------
// MongoDB Atlas Connection
// -------------------
const MONGO_URI = "mongodb+srv://poddarchandni5_db_user:v2Mx8g9NM6LWtZ7z@cluster0.05shl0n.mongodb.net/ggiCanteen?retryWrites=true&w=majority";

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
  // Add this Schema to your server.js
  const ItemSchema = new mongoose.Schema({
    name: { type: String, required: true },
    price: { type: Number, required: true },
    category: { type: String, required: true },
    imageUrl: { type: String, required: true }, // We will store the URL
    createdAt: { type: Date, default: Date.now }
  });

  const Item = mongoose.model("Item", ItemSchema);

  // Add this Route to handle adding new items
  app.post("/add-item", async (req, res) => {
    try {
      const { name, price, category, imageUrl } = req.body;

      if (!name || !price || !category || !imageUrl) {
        return res.status(400).json({ message: "All fields are required" });
      }

      const newItem = new Item({ name, price, category, imageUrl });
      await newItem.save();

      res.status(201).json({ message: "Item added successfully!" });
    } catch (err) {
      res.status(500).json({ message: "Error saving item to database" });
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