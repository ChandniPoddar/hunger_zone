const Order = require("../models/Order");
const Vendor = require("../models/Vendor");
const { getItemModel } = require("../models/Item");
const {
  sendNotificationToOutlet,
  sendNotificationToUser,
} = require("../services/firebaseNotificationService");

// ─────────────────────────────────────────────
// Status notification messages
// ─────────────────────────────────────────────
function getStatusNotification(status, outlet, orderId) {
  const idStr = orderId ? ` (#${orderId})` : '';
  const messages = {
    Accepted: {
      title: `✅ Order Confirmed${idStr}`,
      body: `Your order from ${outlet} has been confirmed.`,
    },
    Confirmed: {
      title: `✅ Order Confirmed${idStr}`,
      body: `Your order from ${outlet} has been confirmed.`,
    },
    Preparing: {
      title: `👨‍🍳 Order Preparing${idStr}`,
      body: `Your order from ${outlet} is being prepared in the kitchen.`,
    },
    Ready: {
      title: `🎉 Order Ready for Pickup!${idStr}`,
      body: `Your order from ${outlet} is ready! Please collect it at the counter.`,
    },
    Completed: {
      title: `✅ Order Completed${idStr}`,
      body: `Your order from ${outlet} has been completed. Enjoy your meal!`,
    },
    Rejected: {
      title: `❌ Order Rejected${idStr}`,
      body: `Unfortunately, your order from ${outlet} was rejected.`,
    },
  };
  return messages[status] || null;
}

// ─────────────────────────────────────────────
// POST /api/orders — Create a new order with multi-vendor validation & server-side total
// ─────────────────────────────────────────────
exports.createOrder = async (req, res) => {
  try {
    const {
      orderId,
      vendorId,
      outlet,
      userName,
      userEmail,
      userPhone,
      items,
      paymentMethod,
    } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: "Order must contain at least one item." });
    }

    // 1. Resolve Vendor
    const effectiveVendorKey = (vendorId || outlet || "").toLowerCase().trim();
    const vendor = await Vendor.findOne({
      $or: [
        { vendorId: effectiveVendorKey },
        { outletName: new RegExp(`^${effectiveVendorKey}$`, "i") },
        { name: new RegExp(`^${effectiveVendorKey}$`, "i") },
      ],
    });

    if (!vendor) {
      return res.status(400).json({ message: "Vendor not found." });
    }

    if (!vendor.isActive) {
      return res.status(400).json({ message: "This vendor is currently unavailable." });
    }

    // 2. Server-side price calculation (never trust client total)
    const ItemModel = getItemModel(vendor.outletName);
    let calculatedTotal = 0;
    const validatedItems = [];

    for (const item of items) {
      const qty = Math.max(1, parseInt(item.quantity || 1, 10));
      let price = Number(item.price || 0);

      // Attempt to look up current price from DB
      if (item.id || item._id) {
        const dbItem = await ItemModel.findById(item.id || item._id);
        if (dbItem && typeof dbItem.price === "number") {
          price = dbItem.price;
        }
      } else if (item.name) {
        const dbItem = await ItemModel.findOne({ name: new RegExp(`^${item.name.trim()}$`, "i") });
        if (dbItem && typeof dbItem.price === "number") {
          price = dbItem.price;
        }
      }

      calculatedTotal += price * qty;
      validatedItems.push({
        name: item.name,
        quantity: qty,
        price,
      });
    }

    const effectiveOrderId = orderId || `ORD${Date.now()}`;
    const effectivePaymentMethod = paymentMethod === "Cash at Counter" ? "Cash at Counter" : "UPI";
    const initialPaymentStatus = effectivePaymentMethod === "Cash at Counter" ? "COD" : "PENDING";

    const order = new Order({
      orderId: effectiveOrderId,
      vendorId: vendor.vendorId,
      outlet: vendor.outletName,
      userName: userName || "Customer",
      userEmail: userEmail ? userEmail.toLowerCase().trim() : null,
      userPhone: userPhone || null,
      items: validatedItems,
      total: calculatedTotal,
      paymentMethod: effectivePaymentMethod,
      paymentStatus: initialPaymentStatus,
      status: "Pending",
    });

    await order.save();
    console.log(`[ORDER] Created order: ${order.orderId} for vendor: ${vendor.name} (₹${order.total}, Payment: ${order.paymentStatus})`);

    // If COD, notify outlet admin immediately
    if (effectivePaymentMethod === "Cash at Counter") {
      const itemList = validatedItems.map((i) => `${i.quantity}x ${i.name}`).join(", ");
      sendNotificationToOutlet(
        order.outlet,
        `🍔 New COD Order #${order.orderId}!`,
        `New order for ${order.outlet} - ₹${order.total}. Items: ${itemList}`,
        {
          type: "new_order",
          orderId: order.orderId || "",
          outlet: order.outlet || "",
          total: String(order.total || 0),
          items: itemList,
          paymentMethod: "Cash at Counter",
        }
      ).catch((err) => console.error("[FCM] Admin notification failed (non-fatal):", err.message));
    }

    res.status(201).json({
      message: "Order placed successfully",
      order,
      vendor: {
        vendorId: vendor.vendorId,
        name: vendor.name,
        outletName: vendor.outletName,
        isPaymentConfigured: vendor.isPaymentConfigured,
      },
    });
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
    const notification = getStatusNotification(status, order.outlet, order.orderId);
    if (notification && order.userEmail) {
      sendNotificationToUser(order.userEmail, notification.title, notification.body, {
        type: "order_status",
        status,
        orderId: order.orderId || "",
        outlet: order.outlet || "",
      }).catch((err) =>
        console.error("[FCM] Customer status notification failed (non-fatal):", err.message)
      );
      console.log(`[ORDER] Customer status notification triggered for: ${order.userEmail} (status: ${status}, orderId: ${order.orderId})`);
    }

    res.json(order);
  } catch (error) {
    console.error("[ORDER] updateOrderStatus error:", error.message);
    res.status(500).json({ message: error.message });
  }
};
