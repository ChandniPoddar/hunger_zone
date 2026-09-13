const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Vendor = require('../models/Vendor');
const { sendNotificationToOutlet } = require('../services/firebaseNotificationService');

// ─────────────────────────────────────────────
// POST /api/payment/create-intent
// Dynamically retrieve vendor payment details and generate secure payment request
// ─────────────────────────────────────────────
router.post('/create-intent', async (req, res) => {
  try {
    const { orderId, vendorId } = req.body;

    if (!orderId) {
      return res.status(400).json({ message: 'Order ID is required' });
    }

    const order = await Order.findOne({ orderId });
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    const effectiveVendorKey = (vendorId || order.vendorId || order.outlet || '').toLowerCase().trim();

    const vendor = await Vendor.findOne({
      $or: [
        { vendorId: effectiveVendorKey },
        { outletName: new RegExp(`^${effectiveVendorKey}$`, 'i') },
        { name: new RegExp(`^${effectiveVendorKey}$`, 'i') },
      ],
    });

    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found.' });
    }

    if (!vendor.isActive) {
      return res.status(400).json({ message: 'This vendor is currently unavailable.' });
    }

    if (!vendor.isPaymentConfigured || !vendor.upiId || !vendor.receiverName) {
      return res.status(400).json({ message: 'Payment is currently unavailable for this vendor.' });
    }

    // Generate unique transaction reference
    const transactionRef = `HZ_${order.orderId}_${Date.now()}`;

    // Update order with transaction reference and set payment status to PENDING
    order.transactionRef = transactionRef;
    order.paymentStatus = 'PENDING';
    order.vendorId = vendor.vendorId;
    await order.save();

    console.log(`[PAYMENT] Created intent for order ${order.orderId} (Vendor: ${vendor.name}, UPI: ${vendor.upiId})`);

    res.status(200).json({
      success: true,
      transactionRef,
      receiverUpiId: vendor.upiId.trim(),
      receiverName: vendor.receiverName.trim(),
      merchantId: vendor.merchantId ? vendor.merchantId.trim() : null,
      amount: order.total,
      vendorName: vendor.name,
      orderId: order.orderId,
    });
  } catch (err) {
    console.error('[PAYMENT] create-intent error:', err.message);
    res.status(500).json({ message: 'Failed to initiate payment', error: err.message });
  }
});

// ─────────────────────────────────────────────
// POST /api/payment/verify
// Record and verify payment status from UPI intent
// ─────────────────────────────────────────────
router.post('/verify', async (req, res) => {
  try {
    const { orderId, transactionRef, status, approvalRefNo } = req.body;

    if (!orderId) {
      return res.status(400).json({ message: 'Order ID is required' });
    }

    const order = await Order.findOne({ orderId });
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Map status
    const normStatus = (status || '').toUpperCase();
    if (normStatus === 'SUCCESS') {
      order.paymentStatus = 'SUCCESS';
      // If order is still pending, move to Accepted or Confirmed
      if (order.status === 'Pending') {
        order.status = 'Accepted';
      }
    } else if (normStatus === 'SUBMITTED') {
      order.paymentStatus = 'SUBMITTED';
    } else {
      order.paymentStatus = 'FAILED';
    }

    if (transactionRef) order.transactionRef = transactionRef;
    if (approvalRefNo) order.approvalRefNo = approvalRefNo;

    await order.save();
    console.log(`[PAYMENT] Verified order ${order.orderId} → Payment: ${order.paymentStatus}`);

    // If payment was successful, trigger push notification to outlet admin
    if (order.paymentStatus === 'SUCCESS') {
      const itemList = (order.items || []).map((i) => `${i.quantity}x ${i.name}`).join(', ');
      sendNotificationToOutlet(
        order.outlet,
        `🍔 Paid Order #${order.orderId}!`,
        `New paid order for ${order.outlet} - ₹${order.total}. Items: ${itemList}`,
        {
          type: 'new_order',
          orderId: order.orderId || '',
          outlet: order.outlet || '',
          total: String(order.total || 0),
          items: itemList,
          paymentStatus: 'SUCCESS',
        }
      ).catch((err) => console.error('[FCM] Admin payment notification failed (non-fatal):', err.message));
    }

    res.status(200).json({
      success: true,
      message: `Payment status updated to ${order.paymentStatus}`,
      order: {
        orderId: order.orderId,
        paymentStatus: order.paymentStatus,
        status: order.status,
        total: order.total,
        outlet: order.outlet,
        transactionRef: order.transactionRef,
        approvalRefNo: order.approvalRefNo,
      },
    });
  } catch (err) {
    console.error('[PAYMENT] verify error:', err.message);
    res.status(500).json({ message: 'Failed to verify payment', error: err.message });
  }
});

module.exports = router;
