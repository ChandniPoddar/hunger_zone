const Order = require("../models/Order");
const {
  sendNotificationToOutlet,
  sendNotificationToUser,
} = require("../services/firebaseNotificationService");

// ─────────────────────────────────────────────
// Status notification messages
// ─────────────────────────────────────────────
function getStatusNotification(status, outlet) {
  const messages = {
    Accepted: {
      title: "✅ Order Accepted",
      body: `Your order from ${outlet} has been accepted.`,
    },
    Preparing: {
      title: "👨‍🍳 Order Preparing",
      body: `Your order from ${outlet} is being prepared.`,
    },
    Ready: {
      title: "🎉 Order Ready!",
      body: `Your order from ${outlet} is ready for pickup!`,
    },
    Completed: {
      title: "✅ Order Completed",
      body: `Your order from ${outlet} has been completed successfully.`,
    },
    Rejected: {
      title: "❌ Order Rejected",
      body: `Unfortunately, your order from ${outlet} was rejected.`,
    },
  };
  return messages[status] || null;
}

// ─────────────────────────────────────────────
// POST /api/orders — Create a new order
// ─────────────────────────────────────────────
exports.createOrder = async (req, res) => {
  try {
    const order = new Order(req.body);
    await order.save();
    console.log(`[ORDER] New order created: ${order.orderId} for outlet: ${order.outlet}`);

    // ── FCM: Notify the correct outlet admin (non-blocking)
    const itemList = order.items.map((i) => `${i.quantity}x ${i.name}`).join(", ");
    sendNotificationToOutlet(
      order.outlet,
      "🍔 New Order!",
      `Order #${order.orderId} received. Total: ₹${order.total}`,
      {
        type: "new_order",
        orderId: order.orderId || "",
        outlet: order.outlet || "",
        total: String(order.total || 0),
        items: itemList,
      }
    ).catch((err) => console.error("[FCM] Admin notification failed (non-fatal):", err.message));

    res.json({ message: "Order placed", order });
  } catch (error) {
    console.error("[ORDER] createOrder error:", error.message);
    res.status(500).json({ message: error.message });
  }
};

// ─────────────────────────────────────────────
// GET /api/orders — All orders (admin debug)
// ─────────────────────────────────────────────
exports.getOrders = async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ─────────────────────────────────────────────
// GET /api/orders/:outlet — Orders by outlet (admin dashboard)
// ─────────────────────────────────────────────
exports.getOrdersByOutlet = async (req, res) => {
  try {
    const { outlet } = req.params;
    const orders = await Order.find({
      outlet: new RegExp(`^${outlet}$`, "i"),
    }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ─────────────────────────────────────────────
// GET /api/orders/user/email/:email — Orders by user email (new)
// ─────────────────────────────────────────────
exports.getOrdersByEmail = async (req, res) => {
  try {
    const email = decodeURIComponent(req.params.email).toLowerCase().trim();
    const orders = await Order.find({ userEmail: email }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ─────────────────────────────────────────────
// GET /api/orders/user/:phone — Orders by phone (backward compat)
// ─────────────────────────────────────────────
exports.getOrdersByUser = async (req, res) => {
  try {
    const { phone } = req.params;
    const orders = await Order.find({
      userPhone: new RegExp(`^${phone}$`, "i"),
    }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ─────────────────────────────────────────────
// PUT /api/orders/:id/status — Update order status
// Sends FCM notification to customer on every status change
// ─────────────────────────────────────────────
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;

    // Get old status to prevent duplicate notifications
    const existingOrder = await Order.findById(req.params.id);
    if (!existingOrder) {
      return res.status(404).json({ message: "Order not found" });
    }

    // Only update and notify if status actually changed
    if (existingOrder.status === status) {
      return res.json(existingOrder);
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    console.log(`[ORDER] Status updated: ${order.orderId} → ${status}`);

    // ── FCM: Notify customer (non-blocking)
    const notification = getStatusNotification(status, order.outlet);
    if (notification && order.userEmail) {
      sendNotificationToUser(order.userEmail, notification.title, notification.body, {
        type: "order_status",
        status,
        orderId: order.orderId || "",
        outlet: order.outlet || "",
      }).catch((err) =>
        console.error("[FCM] Customer status notification failed (non-fatal):", err.message)
      );
      console.log(`[ORDER] Customer status notification triggered for: ${order.userEmail}`);
    }

    res.json(order);
  } catch (error) {
    console.error("[ORDER] updateOrderStatus error:", error.message);
    res.status(500).json({ message: error.message });
  }
};
