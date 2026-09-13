const express = require('express');
const router = express.Router();
const Vendor = require('../models/Vendor');

// ─────────────────────────────────────────────
// GET /api/vendors — List all vendors
// ─────────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const vendors = await Vendor.find().sort({ createdAt: 1 });
    res.json(vendors);
  } catch (err) {
    console.error('[VENDOR] get vendors error:', err.message);
    res.status(500).json({ message: 'Failed to fetch vendors', error: err.message });
  }
});

// ─────────────────────────────────────────────
// GET /api/vendors/:vendorId — Get vendor details
// ─────────────────────────────────────────────
router.get('/:vendorId', async (req, res) => {
  try {
    const { vendorId } = req.params;
    const cleanId = vendorId.toLowerCase().trim();

    const vendor = await Vendor.findOne({
      $or: [
        { vendorId: cleanId },
        { outletName: new RegExp(`^${cleanId}$`, 'i') },
      ],
    });

    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found' });
    }

    res.json(vendor);
  } catch (err) {
    console.error('[VENDOR] get vendor error:', err.message);
    res.status(500).json({ message: 'Failed to fetch vendor', error: err.message });
  }
});

// ─────────────────────────────────────────────
// PUT /api/vendors/:vendorId — Update vendor details / payment configuration
// ─────────────────────────────────────────────
router.put('/:vendorId', async (req, res) => {
  try {
    const { vendorId } = req.params;
    const cleanId = vendorId.toLowerCase().trim();
    const { upiId, receiverName, merchantId, isActive, name, adminOutlet } = req.body;
    const reqAdminOutlet = adminOutlet || req.headers['x-admin-outlet'];

    const vendor = await Vendor.findOne({
      $or: [
        { vendorId: cleanId },
        { outletName: new RegExp(`^${cleanId}$`, 'i') },
      ],
    });

    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found' });
    }

    // Security Authorization Check: Verify caller belongs to this outlet
    if (reqAdminOutlet) {
      const cleanAdminOutlet = reqAdminOutlet.toString().toLowerCase().trim().replace(/[\s_-]+/g, '');
      const cleanVendorOutlet = (vendor.outletName || vendor.vendorId).toLowerCase().trim().replace(/[\s_-]+/g, '');
      const cleanVendorId = vendor.vendorId.toLowerCase().trim().replace(/[\s_-]+/g, '');

      const isAuthorized = cleanAdminOutlet === cleanVendorOutlet || 
                           cleanAdminOutlet === cleanVendorId ||
                           cleanAdminOutlet.includes(cleanVendorId) ||
                           cleanVendorId.includes(cleanAdminOutlet);

      if (!isAuthorized) {
        console.warn(`[SECURITY] Forbidden: Admin of '${reqAdminOutlet}' attempted to modify credentials of '${vendor.name}' (${vendor.vendorId})`);
        return res.status(403).json({
          success: false,
          message: 'Forbidden: You are strictly authorized to configure payment settings for your own outlet only.',
        });
      }
    }

    if (name !== undefined) vendor.name = name.trim();
    if (upiId !== undefined) vendor.upiId = upiId ? upiId.trim() : null;
    if (receiverName !== undefined) vendor.receiverName = receiverName ? receiverName.trim() : null;
    if (merchantId !== undefined) vendor.merchantId = merchantId ? merchantId.trim() : null;
    if (isActive !== undefined) vendor.isActive = Boolean(isActive);

    await vendor.save();
    console.log(`[VENDOR] Vendor updated: ${vendor.vendorId} (${vendor.name}) - Payment Configured: ${vendor.isPaymentConfigured}`);

    res.json({
      success: true,
      message: 'Vendor updated successfully',
      vendor,
    });
  } catch (err) {
    console.error('[VENDOR] update vendor error:', err.message);
    res.status(500).json({ message: 'Failed to update vendor', error: err.message });
  }
});

module.exports = router;
