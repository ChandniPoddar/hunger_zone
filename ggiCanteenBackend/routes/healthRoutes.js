const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const os = require('os');
const { performance } = require('perf_hooks');
const { v2: cloudinary } = require('cloudinary');
const { getTransporter } = require('../services/emailService');

const User = require('../models/User');
const Order = require('../models/Order');
const Vendor = require('../models/Vendor');
const { getItemModel } = require('../models/Item');

/**
 * Helper to format uptime into human-readable string
 */
function formatUptime(seconds) {
  const d = Math.floor(seconds / (3600 * 24));
  const h = Math.floor((seconds % (3600 * 24)) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);
  const parts = [];
  if (d > 0) parts.push(`${d}d`);
  if (h > 0) parts.push(`${h}h`);
  if (m > 0) parts.push(`${m}m`);
  parts.push(`${s}s`);
  return parts.join(' ');
}

/**
 * Measure event loop delay in milliseconds
 */
function measureEventLoopLag() {
  return new Promise((resolve) => {
    const start = performance.now();
    setImmediate(() => {
      const delay = performance.now() - start;
      resolve(Math.round(delay * 100) / 100);
    });
  });
}

/**
 * Run a promise with a hard timeout safeguard
 */
function withTimeout(promise, timeoutMs, fallbackValue) {
  let timer;
  const timeoutPromise = new Promise((resolve) => {
    timer = setTimeout(() => resolve(fallbackValue), timeoutMs);
  });
  return Promise.race([
    promise.then((res) => {
      clearTimeout(timer);
      return res;
    }),
    timeoutPromise,
  ]);
}

/**
 * GET /api/health/ping - Fast liveness probe (for load balancers & uptime monitors)
 */
router.get('/ping', (req, res) => {
  res.status(200).json({
    status: 'UP',
    message: 'HungerZone API is responsive',
    timestamp: new Date().toISOString(),
    uptimeSeconds: Math.round(process.uptime()),
    uptime: formatUptime(process.uptime()),
  });
});

/**
 * GET /api/health/db - Dedicated database health probe
 */
router.get('/db', async (req, res) => {
  const startTime = performance.now();
  const dbState = mongoose.connection.readyState;
  const stateMap = { 0: 'disconnected', 1: 'connected', 2: 'connecting', 3: 'disconnecting' };

  if (dbState !== 1) {
    return res.status(503).json({
      status: 'DOWN',
      state: stateMap[dbState] || 'unknown',
      error: 'MongoDB is not connected',
      durationMs: Math.round(performance.now() - startTime),
    });
  }

  try {
    const pingStart = performance.now();
    await mongoose.connection.db.admin().ping();
    const pingMs = Math.round((performance.now() - pingStart) * 100) / 100;

    const [usersCount, ordersCount, vendorsCount] = await Promise.all([
      User.countDocuments().catch(() => -1),
      Order.countDocuments().catch(() => -1),
      Vendor.countDocuments().catch(() => -1),
    ]);

    return res.status(200).json({
      status: pingMs > 400 ? 'DEGRADED' : 'HEALTHY',
      state: 'connected',
      pingMs,
      performance: pingMs < 100 ? 'EXCELLENT' : pingMs < 300 ? 'GOOD' : 'SLOW_LAGGING',
      cluster: mongoose.connection.host,
      database: mongoose.connection.name,
      counts: {
        users: usersCount,
        orders: ordersCount,
        vendors: vendorsCount,
      },
      durationMs: Math.round(performance.now() - startTime),
    });
  } catch (err) {
    return res.status(500).json({
      status: 'ERROR',
      error: err.message,
      durationMs: Math.round(performance.now() - startTime),
    });
  }
});

/**
 * GET /api/health - Full comprehensive health check with lag diagnosis
 */
router.get('/', async (req, res) => {
  const totalStart = performance.now();
  const bottlenecks = [];
  const recommendations = [];

  // ─────────────────────────────────────────────
  // 1. Event Loop Delay
  // ─────────────────────────────────────────────
  const eventLoopDelayMs = await measureEventLoopLag();
  if (eventLoopDelayMs > 50) {
    bottlenecks.push({
      component: 'eventLoop',
      severity: 'WARNING',
      metric: `${eventLoopDelayMs}ms`,
      message: 'Node.js event loop is experiencing lag (delay > 50ms). Heavy synchronous tasks may be blocking requests.',
    });
    recommendations.push('Inspect synchronous code execution, large JSON parsing, or heavy regexes blocking the Node.js main thread.');
  }

  // ─────────────────────────────────────────────
  // 2. System Memory Metrics
  // ─────────────────────────────────────────────
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const usedMem = totalMem - freeMem;
  const memUsagePercent = Math.round((usedMem / totalMem) * 100);

  const memUsage = process.memoryUsage();
  const rssMb = Math.round((memUsage.rss / 1024 / 1024) * 10) / 10;
  const heapUsedMb = Math.round((memUsage.heapUsed / 1024 / 1024) * 10) / 10;
  const heapTotalMb = Math.round((memUsage.heapTotal / 1024 / 1024) * 10) / 10;

  if (memUsagePercent > 85) {
    bottlenecks.push({
      component: 'systemMemory',
      severity: 'WARNING',
      metric: `${memUsagePercent}%`,
      message: `System RAM usage is high (${memUsagePercent}%).`,
    });
    recommendations.push('Host system is low on RAM. Consider scaling instance memory or investigating memory leaks.');
  }

  // ─────────────────────────────────────────────
  // 3. MongoDB Database Diagnostics
  // ─────────────────────────────────────────────
  const dbState = mongoose.connection.readyState;
  const stateMap = { 0: 'disconnected', 1: 'connected', 2: 'connecting', 3: 'disconnecting' };
  let dbPingMs = null;
  let dbStatus = 'DOWN';
  let dbCounts = null;

  if (dbState === 1) {
    try {
      const pingStart = performance.now();
      await mongoose.connection.db.admin().ping();
      dbPingMs = Math.round((performance.now() - pingStart) * 100) / 100;

      if (dbPingMs > 350) {
        dbStatus = 'DEGRADED';
        bottlenecks.push({
          component: 'database',
          severity: 'WARNING',
          metric: `${dbPingMs}ms`,
          message: `Database ping latency is slow (${dbPingMs}ms > 350ms threshold). MongoDB queries may experience noticeable lag.`,
        });
        recommendations.push('Verify network route and geo-latency between server host and MongoDB Atlas cluster. Ensure proper compound indexes exist on queried collections.');
      } else {
        dbStatus = 'HEALTHY';
      }

      // Quick item counts by category
      const [usersCount, ordersCount, vendorsCount, canteenCount, nescafeCount, liptonCount, fruitCount] =
        await Promise.all([
          User.countDocuments().catch(() => 0),
          Order.countDocuments().catch(() => 0),
          Vendor.countDocuments().catch(() => 0),
          getItemModel('canteen').countDocuments().catch(() => 0),
          getItemModel('nescafe').countDocuments().catch(() => 0),
          getItemModel('lipton').countDocuments().catch(() => 0),
          getItemModel('fruit_corner').countDocuments().catch(() => 0),
        ]);

      dbCounts = {
        users: usersCount,
        orders: ordersCount,
        vendors: vendorsCount,
        items: {
          canteen: canteenCount,
          nescafe: nescafeCount,
          lipton: liptonCount,
          fruitCorner: fruitCount,
          total: canteenCount + nescafeCount + liptonCount + fruitCount,
        },
      };
    } catch (err) {
      dbStatus = 'DEGRADED';
      bottlenecks.push({
        component: 'database',
        severity: 'ERROR',
        metric: 'Ping Failed',
        message: `Database ping failed: ${err.message}`,
      });
    }
  } else {
    dbStatus = 'DOWN';
    bottlenecks.push({
      component: 'database',
      severity: 'CRITICAL',
      metric: stateMap[dbState] || 'disconnected',
      message: 'MongoDB is disconnected or currently attempting reconnection.',
    });
    recommendations.push('Check MongoDB Atlas connection string (MONGO_URI), IP Whitelist in Atlas Network Access, and database credentials.');
  }

  // ─────────────────────────────────────────────
  // 4. Multi-Vendor Subsystem Diagnostics
  // ─────────────────────────────────────────────
  let vendorDetails = [];
  try {
    if (dbState === 1) {
      vendorDetails = await Vendor.find({}, 'vendorId name outletName upiId isActive isPaymentConfigured').lean();
    }
  } catch (_) {
    // handled gracefully
  }

  const vendorsReport = {
    totalRegistered: vendorDetails.length,
    activeVendors: vendorDetails.filter((v) => v.isActive).length,
    configuredVendors: vendorDetails.filter((v) => v.isPaymentConfigured).length,
    outlets: vendorDetails.map((v) => ({
      vendorId: v.vendorId,
      name: v.name,
      isActive: v.isActive,
      paymentConfigured: v.isPaymentConfigured,
      upiId: v.upiId ? `${v.upiId.slice(0, 8)}...${v.upiId.slice(-7)}` : null,
      onlineCheckoutStatus: v.isPaymentConfigured ? 'ONLINE_UPI_AVAILABLE' : 'CASH_AT_COUNTER_ONLY',
    })),
  };

  // ─────────────────────────────────────────────
  // 5. Email & Notification Service (SMTP)
  // ─────────────────────────────────────────────
  let emailStatus = 'UNKNOWN';
  let emailLatencyMs = null;
  let emailError = null;

  try {
    const transporter = getTransporter();
    const smtpStart = performance.now();

    // 2.5s timeout safeguard so health check never hangs if SMTP is unreachable
    const verifyResult = await withTimeout(
      transporter.verify().then(() => true).catch((e) => ({ error: e.message })),
      2500,
      { timeout: true }
    );

    emailLatencyMs = Math.round((performance.now() - smtpStart) * 100) / 100;

    if (verifyResult === true) {
      if (emailLatencyMs > 2000) {
        emailStatus = 'SLOW_LAGGING';
        bottlenecks.push({
          component: 'emailSmtp',
          severity: 'NOTICE',
          metric: `${emailLatencyMs}ms`,
          message: `Email SMTP server responded slowly (${emailLatencyMs}ms). OTP delivery might experience brief delays.`,
        });
      } else {
        emailStatus = 'HEALTHY';
      }
    } else if (verifyResult?.timeout) {
      emailStatus = 'TIMEOUT';
      bottlenecks.push({
        component: 'emailSmtp',
        severity: 'WARNING',
        metric: '>2500ms',
        message: 'Email SMTP server verification timed out (> 2.5s). Outgoing OTP emails may be delayed.',
      });
      recommendations.push('Check firewall rules or outbound port 465/587 connectivity to smtp.gmail.com.');
    } else {
      emailStatus = 'FAILED';
      emailError = verifyResult?.error || 'Unknown SMTP error';
      bottlenecks.push({
        component: 'emailSmtp',
        severity: 'WARNING',
        metric: 'Auth/Connection Failed',
        message: `SMTP verification failed: ${emailError}`,
      });
      recommendations.push('Verify EMAIL_USER and EMAIL_PASSWORD (Gmail App Password) in environment variables.');
    }
  } catch (err) {
    emailStatus = 'ERROR';
    emailError = err.message;
  }

  // ─────────────────────────────────────────────
  // 6. Image Storage (Cloudinary)
  // ─────────────────────────────────────────────
  const cloudName = cloudinary.config().cloud_name;
  const hasCloudinary = Boolean(cloudName && cloudinary.config().api_key);

  // ─────────────────────────────────────────────
  // 7. Overall Health Status Decision
  // ─────────────────────────────────────────────
  let overallStatus = 'HEALTHY';
  let httpStatusCode = 200;

  if (dbStatus === 'DOWN') {
    overallStatus = 'UNHEALTHY';
    httpStatusCode = 503;
  } else if (bottlenecks.some((b) => b.severity === 'CRITICAL' || b.severity === 'ERROR')) {
    overallStatus = 'DEGRADED';
    httpStatusCode = 200;
  } else if (bottlenecks.some((b) => b.severity === 'WARNING')) {
    overallStatus = 'DEGRADED';
    httpStatusCode = 200;
  }

  const totalDurationMs = Math.round((performance.now() - totalStart) * 100) / 100;

  return res.status(httpStatusCode).json({
    status: overallStatus,
    statusCode: httpStatusCode,
    message:
      overallStatus === 'HEALTHY'
        ? 'All subsystems operational. No significant lag detected.'
        : overallStatus === 'DEGRADED'
        ? 'System operational with performance bottlenecks or non-critical service warnings.'
        : 'Critical subsystem failure detected.',
    timestamp: new Date().toISOString(),
    durationMs: totalDurationMs,
    lagAnalysis: {
      isLagging: bottlenecks.length > 0,
      bottleneckCount: bottlenecks.length,
      bottlenecks,
      recommendations: recommendations.length > 0 ? recommendations : ['System running optimally. No optimization action needed.'],
    },
    subsystems: {
      database: {
        status: dbStatus,
        state: stateMap[dbState] || 'unknown',
        pingMs: dbPingMs,
        cluster: mongoose.connection.host || 'N/A',
        name: mongoose.connection.name || 'ggiCanteen',
        counts: dbCounts,
      },
      vendors: vendorsReport,
      emailSmtp: {
        status: emailStatus,
        latencyMs: emailLatencyMs,
        user: process.env.EMAIL_USER ? `${process.env.EMAIL_USER.slice(0, 4)}***@${process.env.EMAIL_USER.split('@')[1] || ''}` : 'not-set',
        error: emailError,
      },
      storage: {
        service: 'Cloudinary',
        status: hasCloudinary ? 'CONFIGURED' : 'UNCONFIGURED',
        cloudName: cloudName || null,
      },
    },
    system: {
      uptimeSeconds: Math.round(process.uptime()),
      uptime: formatUptime(process.uptime()),
      platform: `${process.platform} (${process.arch})`,
      nodeVersion: process.version,
      pid: process.pid,
      eventLoopDelayMs,
      memory: {
        heapUsedMb,
        heapTotalMb,
        processRssMb: rssMb,
        systemUsedMemMb: Math.round((usedMem / 1024 / 1024) * 10) / 10,
        systemTotalMemMb: Math.round((totalMem / 1024 / 1024) * 10) / 10,
        systemMemoryUsagePercent: `${memUsagePercent}%`,
      },
      cpu: {
        cores: os.cpus().length,
        model: os.cpus()[0]?.model || 'Generic CPU',
      },
    },
  });
});

module.exports = router;
