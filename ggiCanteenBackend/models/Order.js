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

  // Multi-vendor reference
  vendorId: { type: String, default: null },

  // Separate payment state tracking
  paymentStatus: {
    type: String,
    default: "PENDING",
    enum: ["PENDING", "SUCCESS", "FAILED", "SUBMITTED", "COD"],
  },
  paymentMethod: {
    type: String,
    default: "UPI", // "UPI" | "Cash at Counter"
  },
  transactionRef: { type: String, default: null },
  approvalRefNo: { type: String, default: null },

  status: {
    type: String,
    default: "Pending",
    enum: ["Pending", "Accepted", "Confirmed", "Preparing", "Ready", "Completed", "Rejected"],
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Order", orderSchema);
