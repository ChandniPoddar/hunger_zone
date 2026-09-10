const fs = require('fs');
const path = require('path');
if (fs.existsSync('.env')) {
  require('dotenv').config();
} else if (fs.existsSync('../.env')) {
  require('dotenv').config({ path: '../.env' });
}

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const bcrypt = require('bcryptjs');
const { v2: cloudinary } = require('cloudinary');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const { sendOTPEmail, getTransporter } = require('./services/emailService');

const app = express();

// ─────────────────────────────────────────────
// Cloudinary Config
// ─────────────────────────────────────────────
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || 'dgbizoren',
  api_key: process.env.CLOUDINARY_API_KEY || '926861566916778',
  api_secret: process.env.CLOUDINARY_API_SECRET || 'LmWNHNJn_iJbAbEE_q7u4EaqGyM',
});

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'canteen_items',
    allowedFormats: ['jpg', 'jpeg', 'png', 'webp'],
  },
});
const upload = multer({ storage });

// ─────────────────────────────────────────────
// Middleware
// ─────────────────────────────────────────────
app.use(express.json());
app.use(cors());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ─────────────────────────────────────────────
// MongoDB Connection
// ─────────────────────────────────────────────
const MONGO_URI =
  process.env.MONGO_URI ||
  'mongodb+srv://poddarchandni5_db_user:v2Mx8g9NM6LWtZ7z@cluster0.05shl0n.mongodb.net/ggiCanteen?retryWrites=true&w=majority';

mongoose
  .connect(MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB Atlas Connected');
    try {
      const userCollection = mongoose.connection.collection('users');
      const indexes = await userCollection.indexes();
      if (indexes.some((i) => i.name === 'phoneNumber_1')) {
        await userCollection.dropIndex('phoneNumber_1');
        console.log('🧹 Cleaned up legacy phoneNumber_1 index');
      }
    } catch (err) {
      // Ignore if index doesn't exist
    }
  })
  .catch((error) => {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  });

// ─────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────
const User = require('./models/User');

const ItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  category: { type: String, required: true },
  imageUrl: { type: String, required: true },
  isAvailable: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
});

const OutletStatusSchema = new mongoose.Schema({
  outlet: { type: String, required: true, unique: true },
  isOpen: { type: Boolean, default: true },
});

const OutletStatus = mongoose.model('OutletStatus', OutletStatusSchema);
const NescafeItem = mongoose.model('NescafeItem', ItemSchema);
const LiptonItem = mongoose.model('LiptonItem', ItemSchema);
const CanteenItem = mongoose.model('CanteenItem', ItemSchema);
const FruitCornerItem = mongoose.model('FruitCornerItem', ItemSchema);
const GenericItem = mongoose.model('Item', ItemSchema);

// ─────────────────────────────────────────────
// Routes
// ─────────────────────────────────────────────
app.use('/api/orders', require('./routes/orderRoutes'));
app.use('/notifications', require('./routes/notificationRoutes'));

// ─────────────────────────────────────────────
// OTP Store (in-memory, with security metadata)
// Structure: otpStore[email] = { otpHash, expires, attempts, requestCount, windowStart }
// ─────────────────────────────────────────────
const otpStore = {};

const OTP_EXPIRY_MS = 5 * 60 * 1000;        // 5 minutes
const OTP_RATE_LIMIT = 5;                    // max 5 requests per window
const OTP_RATE_WINDOW_MS = 15 * 60 * 1000;  // 15 minute window
const OTP_MAX_ATTEMPTS = 5;                  // max 5 wrong attempts

function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ─────────────────────────────────────────────
// POST /request-email-otp
// ─────────────────────────────────────────────
app.post('/request-email-otp', async (req, res) => {
  try {
    const rawEmail = req.body.email;
    if (!rawEmail) return res.status(400).json({ message: 'Email is required' });

    const email = rawEmail.toLowerCase().trim();

    // Basic email format check
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ message: 'Invalid email format' });
    }

    // ── Rate limiting check
    const now = Date.now();
    const existing = otpStore[email];
    if (existing) {
      const windowStart = existing.windowStart || now;
      const windowElapsed = now - windowStart;

      if (windowElapsed < OTP_RATE_WINDOW_MS) {
        const requestCount = existing.requestCount || 0;
        if (requestCount >= OTP_RATE_LIMIT) {
          const waitMinutes = Math.ceil((OTP_RATE_WINDOW_MS - windowElapsed) / 60000);
          return res.status(429).json({
            message: `Too many OTP requests. Please wait ${waitMinutes} minute(s) before trying again.`,
          });
        }
      }
    }

    // ── Generate & hash OTP
    const otp = generateOTP();
    const otpHash = await bcrypt.hash(otp, 8);

    // ── Update store
    const prevEntry = otpStore[email] || {};
    const windowStart = (prevEntry.windowStart && (now - prevEntry.windowStart) < OTP_RATE_WINDOW_MS)
      ? prevEntry.windowStart
      : now;

    otpStore[email] = {
      otpHash,
      expires: now + OTP_EXPIRY_MS,
      attempts: 0,
      requestCount: (prevEntry.requestCount || 0) + 1,
      windowStart,
    };

    // ── Send email
    try {
      console.log(`[OTP] Requesting email OTP for: ${email}`);
      const sendResult = await sendOTPEmail(email, otp);
      console.log(`[EMAIL] OTP delivered via ${sendResult.provider || 'configured provider'} to: ${email}`);
      return res.status(200).json({ success: true, message: 'OTP sent successfully' });
    } catch (emailErr) {
      console.error('[EMAIL] Failed to send OTP:', emailErr);
      delete otpStore[email]; // Don't leave a dangling entry
      return res.status(500).json({
        message: `Failed to send OTP email: ${emailErr.message || 'Please check email configuration.'}`,
      });
    }
  } catch (err) {
    console.error('[OTP] request-email-otp error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ─────────────────────────────────────────────
// GET /test-email-health
// Diagnostic endpoint to test email provider configuration
// ─────────────────────────────────────────────
app.get('/test-email-health', async (req, res) => {
  try {
    if (process.env.BREVO_API_KEY) {
      return res.json({
        status: 'healthy',
        provider: 'brevo_https',
        port: 443,
        sender: process.env.BREVO_SENDER_EMAIL || process.env.EMAIL_USER || 'chandni5developer@gmail.com',
        note: 'Brevo sends to any recipient worldwide without requiring custom domain DNS records.',
      });
    }
    if (process.env.RESEND_API_KEY) {
      return res.json({
        status: 'healthy',
        provider: 'resend_https',
        port: 443,
        sender: process.env.RESEND_FROM || 'Hunger Zone <onboarding@resend.dev>',
        warning: !process.env.RESEND_FROM || process.env.RESEND_FROM.includes('resend.dev')
          ? 'Resend test mode: Can only send to account owner. Add BREVO_API_KEY to send to all users.'
          : undefined,
      });
    }
    const transporter = getTransporter();
    await transporter.verify();
    res.json({
      status: 'healthy',
      provider: 'smtp',
      configured: true,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      provider: 'smtp',
      message: err.message,
      code: err.code,
      hint: err.code === 'ETIMEDOUT'
        ? 'Render Free Tier blocks outbound SMTP ports 25, 465, and 587. To send emails on Render Free Tier, add BREVO_API_KEY to Render Environment variables.'
        : undefined,
    });
  }
});

// ─────────────────────────────────────────────
// POST /verify-email-otp
// Standalone OTP verification (used before signup)
// ─────────────────────────────────────────────
app.post('/verify-email-otp', async (req, res) => {
  try {
    const rawEmail = req.body.email;
    const { otp } = req.body;
    if (!rawEmail || !otp) return res.status(400).json({ message: 'Email and OTP are required' });

    const email = rawEmail.toLowerCase().trim();
    const entry = otpStore[email];

    if (!entry) {
      return res.status(400).json({ message: 'No OTP found for this email. Please request a new one.' });
    }
    if (Date.now() > entry.expires) {
      delete otpStore[email];
      return res.status(400).json({ message: 'OTP expired. Please request a new one.' });
    }
    if (entry.attempts >= OTP_MAX_ATTEMPTS) {
      delete otpStore[email];
      return res.status(400).json({ message: 'Too many incorrect attempts. Please request a new OTP.' });
    }

    const isValid = await bcrypt.compare(otp, entry.otpHash);
    if (!isValid) {
      otpStore[email].attempts += 1;
      const remaining = OTP_MAX_ATTEMPTS - otpStore[email].attempts;
      return res.status(400).json({ message: `Invalid OTP. ${remaining} attempt(s) remaining.` });
    }

    // ── Mark as verified (keep entry so signup can confirm)
    otpStore[email].verified = true;
    console.log(`[EMAIL] OTP verification successful for: ${email}`);
    res.status(200).json({ success: true, verified: true });
  } catch (err) {
    console.error('[OTP] verify-email-otp error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

// ─────────────────────────────────────────────
// POST /signup  (email-based)
// ─────────────────────────────────────────────
app.post('/signup', async (req, res) => {
  try {
    const rawEmail = req.body.email;
    const { name, password, role, otp } = req.body;

    if (!rawEmail || !password || !name || !otp) {
      return res.status(400).json({ message: 'All fields are required (name, email, password, otp)' });
    }

    const email = rawEmail.toLowerCase().trim();
    const entry = otpStore[email];

    // ── Verify OTP
    if (!entry) {
      return res.status(400).json({ message: 'No OTP found. Please request an OTP first.' });
    }
    if (Date.now() > entry.expires) {
      delete otpStore[email];
      return res.status(400).json({ message: 'OTP expired. Please request a new one.' });
    }

    const isValid = await bcrypt.compare(otp, entry.otpHash);
    if (!isValid) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // ── OTP valid — clear it
    delete otpStore[email];

    // ── Check for existing user
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // ── Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    const user = new User({
      name: name.trim(),
      email,
      password: passwordHash,
      role: role || 'user',
      emailVerified: true,
    });

    await user.save();
    console.log(`[AUTH] User created: ${email}`);

    res.status(201).json({
      message: 'Account created successfully',
      role: user.role,
      name: user.name,
      email: user.email,
    });
  } catch (err) {
    console.error('[AUTH] signup error:', err);
    res.status(500).json({ message: 'Server error during signup', error: err.message });
  }
});

// ─────────────────────────────────────────────
// POST /login  (email + password)
// ─────────────────────────────────────────────
app.post('/login', async (req, res) => {
  try {
    const rawEmail = req.body.email;
    const { password } = req.body;

    if (!rawEmail || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const email = rawEmail.toLowerCase().trim();
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Support both bcrypt hashed and legacy plain-text passwords
    let passwordMatch = false;
    if (user.password.startsWith('$2')) {
      passwordMatch = await bcrypt.compare(password, user.password);
    } else {
      // Legacy plain text (existing records)
      passwordMatch = user.password === password;
    }

    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    console.log(`[AUTH] Login successful: ${email} (role: ${user.role})`);

    res.status(200).json({
      email: user.email,
      role: user.role,
      name: user.name,
      outletName: user.outletName,
      lastVerified: user.lastVerified,
    });
  } catch (err) {
    console.error('[AUTH] login error:', err);
    res.status(500).json({ message: 'Server error during login' });
  }
});

// ─────────────────────────────────────────────
// POST /daily-verify  (operator — email OTP)
// ─────────────────────────────────────────────
app.post('/daily-verify', async (req, res) => {
  try {
    const rawEmail = req.body.email;
    const { otp } = req.body;

    if (!rawEmail || !otp) return res.status(400).json({ message: 'Email and OTP are required' });

    const email = rawEmail.toLowerCase().trim();
    const entry = otpStore[email];

    if (!entry) {
      return res.status(400).json({ message: 'No OTP found. Please request an OTP first.' });
    }
    if (Date.now() > entry.expires) {
      delete otpStore[email];
      return res.status(400).json({ message: 'OTP expired. Please request a new one.' });
    }

    const isValid = await bcrypt.compare(otp, entry.otpHash);
    if (!isValid) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    delete otpStore[email];

    const user = await User.findOneAndUpdate(
      { email },
      { lastVerified: new Date() },
      { new: true }
    );

    if (!user) return res.status(404).json({ message: 'User not found' });

    console.log(`[AUTH] Daily verification successful: ${email}`);
    res.status(200).json({ message: 'Daily verification successful', lastVerified: user.lastVerified });
  } catch (err) {
    console.error('[AUTH] daily-verify error:', err);
    res.status(500).json({ message: 'Verification failed' });
  }
});

// ─────────────────────────────────────────────
// Item routes (unchanged)
// ─────────────────────────────────────────────
function getItemModel(category) {
  switch (category.toLowerCase()) {
    case 'nescafe': return NescafeItem;
    case 'lipton': return LiptonItem;
    case 'canteen': return CanteenItem;
    case 'fruit':
    case 'fruit corner': return FruitCornerItem;
    default: return GenericItem;
  }
}

app.post('/add-item', upload.single('image'), async (req, res) => {
  try {
    const { name, price, category } = req.body;
    let imageUrl = req.body.imageUrl;
    if (req.file) imageUrl = req.file.path;
    if (!name || !price || !category || !imageUrl) {
      return res.status(400).json({ message: 'All fields are required' });
    }
    const TargetModel = getItemModel(category);
    const newItem = new TargetModel({ name, price, category, imageUrl });
    await newItem.save();
    res.status(201).json({ message: 'Item added successfully to ' + TargetModel.modelName });
  } catch (err) {
    res.status(500).json({ message: 'Error saving item to database' });
  }
});

app.get('/items/:category', async (req, res) => {
  try {
    const TargetModel = getItemModel(req.params.category);
    const items = await TargetModel.find({});
    res.status(200).json(items);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching items' });
  }
});

app.put('/item-availability/:category/:id', async (req, res) => {
  try {
    const { category, id } = req.params;
    const { isAvailable } = req.body;
    const TargetModel = getItemModel(category);
    const item = await TargetModel.findByIdAndUpdate(id, { isAvailable }, { new: true });
    res.status(200).json(item);
  } catch (err) {
    res.status(500).json({ message: 'Error updating availability' });
  }
});

app.delete('/item/:category/:id', async (req, res) => {
  try {
    const TargetModel = getItemModel(req.params.category);
    await TargetModel.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Item deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting item' });
  }
});

// ─────────────────────────────────────────────
// Shop Status routes (unchanged)
// ─────────────────────────────────────────────
app.get('/shop-status/:outlet', async (req, res) => {
  try {
    const outlet = req.params.outlet.toLowerCase();
    let status = await OutletStatus.findOne({ outlet });
    if (!status) {
      status = new OutletStatus({ outlet, isOpen: true });
      await status.save();
    }
    res.status(200).json(status);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching shop status' });
  }
});

app.put('/shop-status/:outlet', async (req, res) => {
  try {
    const outlet = req.params.outlet.toLowerCase();
    const { isOpen } = req.body;
    const status = await OutletStatus.findOneAndUpdate(
      { outlet },
      { isOpen },
      { new: true, upsert: true }
    );
    res.status(200).json(status);
  } catch (err) {
    res.status(500).json({ message: 'Error updating shop status' });
  }
});

// ─────────────────────────────────────────────
// Health check
// ─────────────────────────────────────────────
app.get('/', (req, res) => {
  res.send('Hunger Zone API is running 🍽️');
});

// ─────────────────────────────────────────────
// Start Server
// ─────────────────────────────────────────────
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});