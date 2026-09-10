const admin = require('firebase-admin');

// ─────────────────────────────────────────────
// Lazy Firebase Admin initialization
// ─────────────────────────────────────────────
let _initialized = false;

function getFirebaseAdmin() {
  if (!_initialized) {
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY
      ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
      : undefined;

    if (!projectId || !clientEmail || !privateKey) {
      console.warn('[FCM] Firebase Admin credentials not configured. FCM notifications will be skipped.');
      return null;
    }

    admin.initializeApp({
      credential: admin.credential.cert({ projectId, clientEmail, privateKey }),
    });

    _initialized = true;
    console.log('[FCM] Firebase Admin initialized successfully.');
  }
  return admin;
}

// ─────────────────────────────────────────────
// Send to a list of FCM tokens
// ─────────────────────────────────────────────
async function sendNotificationToTokens(tokens, title, body, data = {}) {
  if (!tokens || tokens.length === 0) {
    console.log('[FCM] No tokens to send to — skipping.');
    return { successCount: 0, failureCount: 0, invalidTokens: [] };
  }

  const firebaseAdmin = getFirebaseAdmin();
  if (!firebaseAdmin) return { successCount: 0, failureCount: 0, invalidTokens: [] };

  // Convert all data values to strings (FCM requirement)
  const stringData = {};
  for (const [key, value] of Object.entries(data)) {
    stringData[key] = String(value);
  }

  const message = {
    notification: { title, body },
    data: stringData,
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      payload: {
        aps: { sound: 'default', badge: 1 },
      },
    },
    tokens,
  };

  try {
    const response = await firebaseAdmin.messaging().sendEachForMulticast(message);
    console.log(`[FCM] Sent to ${tokens.length} token(s): ${response.successCount} success, ${response.failureCount} failed.`);

    // Collect invalid tokens for cleanup
    const invalidTokens = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        const code = resp.error?.code;
        if (
          code === 'messaging/invalid-registration-token' ||
          code === 'messaging/registration-token-not-registered'
        ) {
          invalidTokens.push(tokens[idx]);
          console.log(`[FCM] Invalid token removed: ${tokens[idx].substring(0, 20)}...`);
        }
      }
    });

    return { successCount: response.successCount, failureCount: response.failureCount, invalidTokens };
  } catch (err) {
    console.error('[FCM] sendEachForMulticast error:', err.message);
    return { successCount: 0, failureCount: tokens.length, invalidTokens: [] };
  }
}

// ─────────────────────────────────────────────
// Send notification to a user by email
// Looks up FCM tokens from MongoDB User model
// ─────────────────────────────────────────────
async function sendNotificationToUser(email, title, body, data = {}) {
  try {
    // Require User model here to avoid circular deps
    const User = require('../models/User');
    const user = await User.findOne({ email: email.toLowerCase().trim() }).select('fcmTokens');

    if (!user || !user.fcmTokens || user.fcmTokens.length === 0) {
      console.log(`[FCM] No FCM tokens for user: ${email}`);
      return;
    }

    const result = await sendNotificationToTokens(user.fcmTokens, title, body, data);

    // Clean up invalid tokens
    if (result.invalidTokens.length > 0) {
      await User.updateOne(
        { email: email.toLowerCase().trim() },
        { $pull: { fcmTokens: { $in: result.invalidTokens } } }
      );
      console.log(`[FCM] Removed ${result.invalidTokens.length} invalid token(s) for user: ${email}`);
    }
  } catch (err) {
    console.error(`[FCM] sendNotificationToUser error for ${email}:`, err.message);
  }
}

// ─────────────────────────────────────────────
// Send notification to ALL admins of a specific outlet
// ─────────────────────────────────────────────
async function sendNotificationToOutlet(outletName, title, body, data = {}) {
  try {
    const User = require('../models/User');
    const admins = await User.find({
      role: 'admin',
      outletName: new RegExp(`^${outletName}$`, 'i'),
    }).select('fcmTokens email');

    if (!admins || admins.length === 0) {
      console.log(`[FCM] No admin users found for outlet: ${outletName}`);
      return;
    }

    // Collect all tokens from all admins for this outlet
    const allTokens = admins.flatMap(a => a.fcmTokens || []);

    if (allTokens.length === 0) {
      console.log(`[FCM] Admin(s) found for ${outletName} but no FCM tokens registered.`);
      return;
    }

    const result = await sendNotificationToTokens(allTokens, title, body, data);

    // Clean up invalid tokens across all admins
    if (result.invalidTokens.length > 0) {
      for (const admin of admins) {
        const adminInvalidTokens = result.invalidTokens.filter(t => admin.fcmTokens.includes(t));
        if (adminInvalidTokens.length > 0) {
          await User.updateOne(
            { _id: admin._id },
            { $pull: { fcmTokens: { $in: adminInvalidTokens } } }
          );
        }
      }
    }

    console.log(`[FCM] Outlet notification sent to ${outletName} admins.`);
  } catch (err) {
    console.error(`[FCM] sendNotificationToOutlet error for ${outletName}:`, err.message);
  }
}

module.exports = {
  sendNotificationToTokens,
  sendNotificationToUser,
  sendNotificationToOutlet,
};
