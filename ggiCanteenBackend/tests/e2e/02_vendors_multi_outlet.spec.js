const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 2: Multi-Vendor Engine & Configuration', () => {

  test('GET /api/vendors - Lists all 4 campus outlets with correct payment states', async ({ request }) => {
    const res = await request.get('/api/vendors');
    expect(res.status()).toBe(200);

    const vendors = await res.json();
    expect(Array.isArray(vendors)).toBe(true);
    expect(vendors.length).toBeGreaterThanOrEqual(4);

    const vendorIds = vendors.map(v => v.vendorId);
    expect(vendorIds).toContain('canteen');
    expect(vendorIds).toContain('nescafe');
    expect(vendorIds).toContain('lipton');
    expect(vendorIds).toContain('fruit_corner');

    // Verify Main Canteen is pre-configured with real BharatPe VPA
    const canteen = vendors.find(v => v.vendorId === 'canteen');
    expect(canteen).toBeDefined();
    expect(canteen.isPaymentConfigured).toBe(true);
    expect(canteen.upiId).toBe('BHARATPE.9J0E0Z0U0M847077@unitype');
    expect(canteen.receiverName).toBe('SIMON RAJKUMAR GROVER');
    expect(canteen.merchantId).toBe('5812');
    expect(canteen.isActive).toBe(true);

    // Verify Nescafé starts unconfigured
    const nescafe = vendors.find(v => v.vendorId === 'nescafe');
    expect(nescafe).toBeDefined();
    expect(nescafe.isPaymentConfigured).toBe(false);

    // Verify Lipton starts unconfigured
    const lipton = vendors.find(v => v.vendorId === 'lipton');
    expect(lipton).toBeDefined();
    expect(lipton.isPaymentConfigured).toBe(false);

    // Verify Fruit Corner starts unconfigured
    const fruit = vendors.find(v => v.vendorId === 'fruit_corner');
    expect(fruit).toBeDefined();
    expect(fruit.isPaymentConfigured).toBe(false);

    console.log('[PASS] All 4 campus vendors verified with strict payment isolation.');
  });

  test('GET /api/vendors/:vendorId - Fetches individual vendor configuration', async ({ request }) => {
    const res = await request.get('/api/vendors/canteen');
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.vendorId).toBe('canteen');
    expect(body.name).toBe('Main Canteen');
    expect(body.isPaymentConfigured).toBe(true);

    // Non-existent vendor returns 404
    const notFoundRes = await request.get('/api/vendors/non_existent_vendor');
    expect(notFoundRes.status()).toBe(404);
  });

  test('PUT /api/vendors/:vendorId - Admin update of payment credentials with rollback', async ({ request }) => {
    // 1. Temporarily configure test UPI on nescafe
    const updateRes = await request.put('/api/vendors/nescafe', {
      data: {
        upiId: 'nescafe.ggi@okaxis',
        receiverName: 'NESCAFE GGI CAMPUS',
        merchantId: '5812',
        isActive: true,
      },
    });
    expect(updateRes.status()).toBe(200);
    const updateBody = await updateRes.json();
    expect(updateBody.success).toBe(true);
    expect(updateBody.vendor.isPaymentConfigured).toBe(true);
    expect(updateBody.vendor.upiId).toBe('nescafe.ggi@okaxis');

    // 2. Rollback Nescafé to unconfigured state (maintaining production rule)
    const rollbackRes = await request.put('/api/vendors/nescafe', {
      data: {
        upiId: '',
        receiverName: '',
        merchantId: '5812',
        isActive: true,
      },
    });
    expect(rollbackRes.status()).toBe(200);
    const rollbackBody = await rollbackRes.json();
    expect(rollbackBody.success).toBe(true);
    expect(rollbackBody.vendor.isPaymentConfigured).toBe(false);

    console.log('[PASS] Vendor payment credential update and auto-calculation verified with clean rollback.');
  });
});
