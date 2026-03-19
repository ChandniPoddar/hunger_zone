const Order = require("../models/Order");

exports.createOrder = async (req, res) => {
  try {
    const order = new Order(req.body);

    await order.save();

    res.json({
      message: "Order placed",
      order
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrders = async (req, res) => {
  try {

    const orders = await Order.find()
      .sort({ createdAt: -1 });

    res.json(orders);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {

    const { status } = req.body;

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    res.json(order);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
