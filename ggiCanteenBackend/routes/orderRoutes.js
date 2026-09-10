const express = require("express");
const router = express.Router();

const {
  createOrder,
  getOrders,
  getOrdersByOutlet,
  getOrdersByEmail,
  getOrdersByUser,
  updateOrderStatus,
} = require("../controllers/orderController");

router.post("/", createOrder);
router.get("/", getOrders);

// ── New: email-based user order lookup (must be before /:outlet)
router.get("/user/email/:email", getOrdersByEmail);

// ── Legacy: phone-based user order lookup (backward compat)
router.get("/user/:phone", getOrdersByUser);

// ── Outlet-specific orders (admin dashboards)
router.get("/:outlet", getOrdersByOutlet);

// ── Update order status
router.put("/:id/status", updateOrderStatus);

module.exports = router;
