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
  phoneNumber: { type: String, required: true, unique: true }, // Replaced email with phoneNumber
  password: { type: String, required: true },
  role: { type: String, default: "user" },
  outletName: { type: String, default: null }, // Useful for admins/operators
  lastVerified: { type: Date, default: Date.now } // Track daily verification for operators
});

const User = mongoose.model("User", UserSchema);

// -------------------
// Routes
// -------------------
app.use("/api/orders", require("./routes/orderRoutes"));

// -------------------
// SMS Configuration (Twilio)
// -------------------
const twilio = require('twilio');
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

let client;
if (accountSid && authToken) {
  client = twilio(accountSid, authToken);
}

// Simplified OTP Store
const otpStore = {};

// 1a. Request OTP
app.post("/request-otp", async (req, res) => {
  try {
    const { phoneNumber } = req.body;
    if (!phoneNumber) return res.status(400).json({ message: "Phone number required" });

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore[phoneNumber] = { otp, expires: Date.now() + 300000 }; // 5 mins
    
    console.log(`Generating OTP for ${phoneNumber}: ${otp}`);

    if (client && twilioPhone) {
      try {
        await client.messages.create({
          body: `Your Hunger Zone verification code is ${otp}`,
          from: twilioPhone,
          to: phoneNumber.startsWith('+') ? phoneNumber : `+91${phoneNumber}` // Assuming India if no prefix
        });
        console.log(`Real SMS sent to ${phoneNumber}`);
        return res.status(200).json({ message: "OTP sent successfully via SMS" });
      } catch (err) {
        console.error("Twilio error:", err);
        return res.status(500).json({ message: "Error sending SMS. Please check Twilio setup." });
      }
    } else {
      console.log(`Mock OTP (use this for testing): ${otp}`);
      return res.status(200).json({ message: "OTP sent successfully (Mock)", otp }); 
    }
  } catch (err) {
    console.error("Request OTP error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// 1b. Signup Route (Updated for Phone Number)
app.post("/signup", async (req, res) => {
  try {
    const { name, phoneNumber, password, role, otp } = req.body;

    if (!phoneNumber || !password || !name || !otp) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // Verify OTP
    if (!otpStore[phoneNumber] || otpStore[phoneNumber].otp !== otp) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }
    delete otpStore[phoneNumber];

    const existingUser = await User.findOne({ phoneNumber });
    if (existingUser) {
      return res.status(400).json({ message: "Phone number already registered" });
    }

    const user = new User({
      name,
      phoneNumber,
      password, // Note: In production, use bcrypt!
      role: role || "user"
    });

    await user.save();
    console.log(`User created: ${phoneNumber}`);

    res.status(201).json({
      message: "User created successfully",
      role: user.role,
      name: user.name,
      phoneNumber: user.phoneNumber
    });
  } catch (err) {
    console.error("Error creating user:", err);
    res.status(500).json({ message: "Server error during signup" });
  }
});

// 2. Login Route (Updated for Phone Number)
app.post("/login", async (req, res) => {
  try {
    const { phoneNumber, password } = req.body;

    const user = await User.findOne({ phoneNumber });

    if (!user || user.password !== password) {
      return res.status(401).json({ message: "Invalid phone number or password" });
    }

    res.status(200).json({
      phoneNumber: user.phoneNumber,
      role: user.role,
      name: user.name,
      outletName: user.outletName,
      lastVerified: user.lastVerified
    });
  } catch (err) {
    res.status(500).json({ message: "Server error during login" });
  }
});

// 3. Daily Verification Route
app.post("/daily-verify", async (req, res) => {
  try {
    const { phoneNumber, otp } = req.body;
    if (!phoneNumber || !otp) return res.status(400).json({ message: "Missing fields" });

    // Verify OTP
    if (!otpStore[phoneNumber] || otpStore[phoneNumber].otp !== otp) {
      return res.status(400).json({ message: "Invalid or expired OTP" });
    }
    delete otpStore[phoneNumber];

    const user = await User.findOneAndUpdate(
      { phoneNumber },
      { lastVerified: new Date() },
      { new: true }
    );

    if (!user) return res.status(404).json({ message: "User not found" });

    res.status(200).json({ message: "Daily verification successful", lastVerified: user.lastVerified });
  } catch (err) {
    res.status(500).json({ message: "Verification failed" });
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