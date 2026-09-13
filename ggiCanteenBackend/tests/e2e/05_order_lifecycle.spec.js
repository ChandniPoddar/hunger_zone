const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 5: Order Lifecycle & Status Progression', () => {

  let createdOrderId;
  let createdMongoId;
  const testOrderId = `TEST_E2E_${Date.now()}`;
  const testEmail = `e2e.buyer.${Date.now()}@hungerzone.com`;

  test('POST /api/orders - Creates a valid Cash-at-Counter order with server-side pricing', async ({ request }) => {
    const res = await request.post('/api/orders', {
      data: {
        orderId: testOrderId,
        vendorId: 'canteen',
        outlet: 'Canteen',
        userName: 'Playwright Test Buyer',
        userEmail: testEmail,
        userPhone: '9876543210',
        paymentMethod: 'Cash at Counter',
        items: [
          { name: 'Samosa', price: 15, quantity: 2 },
          { name: 'Tea', price: 10, quantity: 1 },
        ],
      },
    });

    expect(res.status()).toBe(201);
    const body = await res.json();
    expect(body.order).toBeDefined();
    expect(body.order.orderId).toBe(testOrderId);
    expect(body.order.outlet).toBe('Canteen');
    expect(body.order.paymentMethod).toBe('Cash at Counter');
    expect(body.order.paymentStatus).toBe('COD');
    expect(body.order.status).toBe('Pending');
    expect(body.order.total).toBe(40); // 15*2 + 10*1 = 40

    createdOrderId = body.order.orderId;
    createdMongoId = body.order._id;
    console.log(`[PASS] Order created: ${createdOrderId} (Mongo ID: ${createdMongoId}, Total: ₹${body.order.total})`);
  });

  test('GET /api/orders/:outlet - Verifies order is listed in outlet admin queue', async ({ request }) => {
    const res = await request.get('/api/orders/canteen');
    expect(res.status()).toBe(200);
    const orders = await res.json();
    expect(Array.isArray(orders)).toBe(true);
    const found = orders.find(o => o.orderId === testOrderId);
    expect(found).toBeDefined();
    expect(found.total).toBe(40);
  });

  test('GET /api/orders/user/email/:email - Verifies order is listed in consumer history', async ({ request }) => {
    const res = await request.get(`/api/orders/user/email/${encodeURIComponent(testEmail)}`);
    expect(res.status()).toBe(200);
    const orders = await res.json();
    expect(Array.isArray(orders)).toBe(true);
    expect(orders.length).toBeGreaterThanOrEqual(1);
    expect(orders[0].orderId).toBe(testOrderId);
  });

  test('PUT /api/orders/:id/status - Progresses order from Pending -> Accepted -> Preparing -> Ready -> Completed', async ({ request }) => {
    const stages = ['Accepted', 'Preparing', 'Ready', 'Completed'];

    for (const nextStatus of stages) {
      const res = await request.put(`/api/orders/${createdMongoId}/status`, {
        data: { status: nextStatus },
      });

      expect(res.status()).toBe(200);
      const updated = await res.json();
      expect(updated.status).toBe(nextStatus);
      console.log(`[PASS] Order ${createdOrderId} successfully transitioned to: ${nextStatus}`);
    }
  });
});
