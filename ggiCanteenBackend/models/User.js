const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phoneNumber: { type: String, required: true, unique: true }, // Replaced email with phoneNumber
  password: { type: String, required: true },
  role: { type: String, default: "user" },
  outletName: { type: String, default: null }, // Useful for admins/operators
  lastVerified: { type: Date, default: Date.now }, // Track daily verification for operators
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.models.User || mongoose.model('User', userSchema);