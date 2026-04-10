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

exports.getOrdersByOutlet = async (req, res) => {
  try {
    const { outlet } = req.params;
    // use case-insensitive matching
    const orders = await Order.find({ outlet: new RegExp(`^${outlet}$`, 'i') })
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrdersByUser = async (req, res) => {
  try {
    const { phone } = req.params;
    const orders = await Order.find({ userPhone: new RegExp(`^${phone}$`, 'i') })
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const twilio = require('twilio');
const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );

    // Twilio SMS on Completion
    if (status === "Completed" && order && order.userPhone) {
      if (accountSid && authToken && twilioPhone) {
        try {
          const client = twilio(accountSid, authToken);
          const itemList = order.items.map(i => `${i.quantity}x ${i.name}`).join(", ");
          const msgBody = `Your order from ${order.outlet || 'Global Eats'} is Complete! Total: ₹${order.total}. Items: ${itemList}. Please pick it up.`;
          
          await client.messages.create({
            body: msgBody,
            from: twilioPhone,
            to: order.userPhone.startsWith('+') ? order.userPhone : `+91${order.userPhone}`
          });
          console.log(`Order completed SMS sent to ${order.userPhone}`);
        } catch (err) {
          console.error("Twilio error on completion:", err.message);
        }
      } else {
        console.log(`Twilio not configured. Would have sent "Complete" SMS to ${order.userPhone}`);
      }
    }

    res.json(order);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
