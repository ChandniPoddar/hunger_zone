const express = require("express");
const router = express.Router();

const {
  createOrder,
  getOrders,
  getOrdersByOutlet,
  getOrdersByUser,
  updateOrderStatus
} = require("../controllers/orderController");

router.post("/", createOrder);
router.get("/", getOrders);
router.get("/user/:phone", getOrdersByUser);
router.get("/:outlet", getOrdersByOutlet);
router.put("/:id/status", updateOrderStatus);

module.exports = router;
