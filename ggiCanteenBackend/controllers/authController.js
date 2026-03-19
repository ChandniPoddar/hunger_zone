const express = require("express");
const router = express.Router();
const User = require("../models/User");

router.post("/signup", async (req, res) => {

  try {

    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password required" });
    }

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const newUser = new User({
      email,
      password
    });

    await newUser.save();

    res.json({
      success: true,
      message: "User registered successfully",
      user: newUser
    });

  } catch (error) {

    console.error(error);
    res.status(500).json({ message: "Server error" });

  }

});

module.exports = router;
