const Order = require("../models/Order");
const User = require("../models/User");
const twilio = require('twilio');

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

exports.createOrder = async (req, res) => {
  try {
    const order = new Order(req.body);

    await order.save();

    // Twilio SMS on New Order
    if (accountSid && authToken && twilioPhone) {
      try {
        const client = twilio(accountSid, authToken);
        const itemList = order.items.map(i => `${i.quantity}x ${i.name}`).join(", ");
        
        // 1. Send SMS to the User
        if (order.userPhone) {
          const userMsg = `Payment Successful! Your order at ${order.outlet || 'Hunger Zone'} is placed. Total: ₹${order.total}. Items: ${itemList}.`;
          await client.messages.create({
            body: userMsg,
            from: twilioPhone,
            to: order.userPhone.startsWith('+') ? order.userPhone : `+91${order.userPhone}`
          });
          console.log(`New order SMS sent to user ${order.userPhone}`);
        }

        // 2. Send SMS to Operators (Admins)
        // User requested "each four operator will recieve the sms of the new orders"
        const admins = await User.find({ role: 'admin' });
        const adminMsg = `New Order Alert! Outlet: ${order.outlet || 'Hunger Zone'}, Total: ₹${order.total}, Items: ${itemList}. Customer: ${order.userName} (${order.userPhone})`;
        
        for (const admin of admins) {
          if (admin.phoneNumber) {
             await client.messages.create({
               body: adminMsg,
               from: twilioPhone,
               to: admin.phoneNumber.startsWith('+') ? admin.phoneNumber : `+91${admin.phoneNumber}`
             });
             console.log(`New order SMS sent to admin ${admin.phoneNumber}`);
          }
        }
      } catch (err) {
        console.error("Twilio error on new order:", err.message);
      }
    } else {
      console.log(`Twilio not configured. Would have sent New Order SMS.`);
    }

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
          const msgBody = `Your order from ${order.outlet || 'Hunger Zone'} is Complete! Total: ₹${order.total}. Items: ${itemList}. Please pick it up.`;
          
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
