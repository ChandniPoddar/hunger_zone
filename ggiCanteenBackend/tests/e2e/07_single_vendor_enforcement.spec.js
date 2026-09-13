const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 7: Server-Side Validation & Security Rules', () => {

  test('POST /api/orders - Rejects order with empty items array', async ({ request }) => {
    const res = await request.post('/api/orders', {
      data: {
        orderId: `EMPTY_${Date.now()}`,
        vendorId: 'canteen',
        items: [],
      },
    });

    expect(res.status()).toBe(400);
    const body = await res.json();
    expect(body.message).toContain('at least one item');
  });

  test('POST /api/orders - Rejects order with invalid or non-existent vendor', async ({ request }) => {
    const res = await request.post('/api/orders', {
      data: {
        orderId: `BAD_VENDOR_${Date.now()}`,
        vendorId: 'non_existent_outlet_xyz',
        items: [{ name: 'Burger', price: 50, quantity: 1 }],
      },
    });

    expect(res.status()).toBe(400);
    const body = await res.json();
    expect(body.message).toContain('Vendor not found');
  });

  test('POST /api/orders - Server calculates order total independently of client-submitted total', async ({ request }) => {
    // Client attempts to claim a total of 1 rupee for items worth 100
    const res = await request.post('/api/orders', {
      data: {
        orderId: `PRICE_CHECK_${Date.now()}`,
        vendorId: 'canteen',
        outlet: 'Canteen',
        userName: 'Tamper Tester',
        userEmail: 'tamper@hungerzone.com',
        userPhone: '9876543210',
        total: 1.0, // Client attempted total manipulation
        items: [
          { name: 'Special Thali', price: 100, quantity: 2 },
        ],
      },
    });

    expect(res.status()).toBe(201);
    const body = await res.json();
    // Server must calculate total from price * quantity = 200, ignoring client total of 1.0
    expect(body.order.total).toBe(200);
    console.log(`[PASS] Server-side price calculation verified: Client claimed ₹1, Server enforced ₹${body.order.total}`);
  });
});
