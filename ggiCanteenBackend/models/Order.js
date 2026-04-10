const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({
  orderId: String,
  outlet: String,
  userName: String,
  userPhone: String,

  items: [
    {
      name: String,
      quantity: Number,
      price: Number
    }
  ],

  total: Number,

  status: {
    type: String,
    default: "Pending"
  },

  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Order", orderSchema);
