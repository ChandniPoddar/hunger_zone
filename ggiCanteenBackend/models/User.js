const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },

    // ─── Email-based auth (replaces phoneNumber) ───
    email: {
      type: String,
      required: true,
      unique: true,
      sparse: true,
      lowercase: true,
      trim: true,
    },

    password: { type: String, required: true },

    role: { type: String, default: 'user' }, // 'user' | 'admin' | 'operator'

    outletName: { type: String, default: null }, // 'Nescafe' | 'Lipton' | 'Canteen' | 'Fruit Corner'

    emailVerified: { type: Boolean, default: false },

    // OTP fields (temporary — cleared after verification)
    otpHash: { type: String, default: null },
    otpExpiresAt: { type: Date, default: null },
    otpAttempts: { type: Number, default: 0 },

    // Rate-limiting: track OTP requests
    otpRequestCount: { type: Number, default: 0 },
    otpRequestWindowStart: { type: Date, default: null },

    // FCM tokens — multiple devices per user
    fcmTokens: [{ type: String }],

    // Session tracking
    lastVerified: { type: Date, default: Date.now },
  },
  { timestamps: true } // adds createdAt + updatedAt automatically
);

module.exports = mongoose.models.User || mongoose.model('User', userSchema);