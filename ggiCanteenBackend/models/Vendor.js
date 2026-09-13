const mongoose = require('mongoose');

const vendorSchema = new mongoose.Schema(
  {
    vendorId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    }, // 'canteen', 'nescafe', 'lipton', 'fruit_corner'
    name: {
      type: String,
      required: true,
      trim: true,
    }, // 'Main Canteen', 'Nescafé', 'Lipton', 'Fruit Corner'
    outletName: {
      type: String,
      required: true,
      trim: true,
    }, // 'Canteen', 'Nescafe', 'Lipton', 'Fruit Corner'
    merchantId: {
      type: String,
      default: null,
      trim: true,
    }, // e.g. '5812'
    upiId: {
      type: String,
      default: null,
      trim: true,
    }, // e.g. 'merchant@upi'
    receiverName: {
      type: String,
      default: null,
      trim: true,
    }, // e.g. 'Store Business Name'
    qrCode: {
      type: String,
      default: null,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    isPaymentConfigured: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

vendorSchema.pre('save', function (next) {
  if (this.upiId && this.upiId.trim().length > 0 && this.receiverName && this.receiverName.trim().length > 0) {
    this.isPaymentConfigured = true;
  } else {
    this.isPaymentConfigured = false;
  }
  if (typeof next === 'function') {
    return next();
  }
});

module.exports = mongoose.models.Vendor || mongoose.model('Vendor', vendorSchema);
