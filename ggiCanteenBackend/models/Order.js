const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({
  orderId: String,
  outlet: String,
  userName: String,

  // Primary identity — email-based (new)
  userEmail: { type: String, default: null },

  // Kept for backward compatibility with existing orders
  userPhone: { type: String, default: null },

  items: [
    {
      name: String,
      quantity: Number,
      price: Number,
    },
  ],

  total: Number,

  status: {
    type: String,
    default: "Pending",
    enum: ["Pending", "Accepted", "Preparing", "Ready", "Completed", "Rejected"],
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Order", orderSchema);
