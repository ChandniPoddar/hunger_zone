const express = require("express");
const router = express.Router();
const User = require("../models/User");

// ─────────────────────────────────────────────
// POST /notifications/register-token
// Registers (or refreshes) an FCM device token for a user
// ─────────────────────────────────────────────
router.post("/register-token", async (req, res) => {
  try {
    const { email, fcmToken, role, outletName } = req.body;

    if (!email || !fcmToken) {
      return res.status(400).json({ message: "email and fcmToken are required" });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const updateDoc = {
      $addToSet: { fcmTokens: fcmToken },
    };

    const setFields = {};
    if (role) setFields.role = role;
    if (outletName) setFields.outletName = outletName;
    if (Object.keys(setFields).length > 0) {
      updateDoc.$set = setFields;
    }

    // Upsert ensures admin or user is registered even with shortcut logins
    const user = await User.findOneAndUpdate(
      { email: normalizedEmail },
      updateDoc,
      { new: true, upsert: true }
    );

    console.log(`[FCM] Token registered for user: ${normalizedEmail} (role: ${user.role || role || 'user'}, outlet: ${user.outletName || outletName || 'none'})`);
    res.json({ success: true, message: "FCM token registered" });
  } catch (err) {
    console.error("[FCM] register-token error:", err.message);
    res.status(500).json({ message: "Failed to register token" });
  }
});

// ─────────────────────────────────────────────
// POST /notifications/remove-token
// Removes a specific FCM token (called on logout)
// ─────────────────────────────────────────────
router.post("/remove-token", async (req, res) => {
  try {
    const { email, fcmToken } = req.body;

    if (!email || !fcmToken) {
      return res.status(400).json({ message: "email and fcmToken are required" });
    }

    const normalizedEmail = email.toLowerCase().trim();

    await User.updateOne(
      { email: normalizedEmail },
      { $pull: { fcmTokens: fcmToken } }
    );

    console.log(`[FCM] Token removed for user: ${normalizedEmail}`);
    res.json({ success: true, message: "FCM token removed" });
  } catch (err) {
    console.error("[FCM] remove-token error:", err.message);
    res.status(500).json({ message: "Failed to remove token" });
  }
});

module.exports = router;
