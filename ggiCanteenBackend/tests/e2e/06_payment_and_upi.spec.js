const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 6: Dynamic Multi-Vendor UPI Payments', () => {

  const canteenOrderId = `UPI_CANTEEN_${Date.now()}`;
  const nescafeOrderId = `UPI_NESCAFE_${Date.now()}`;
  let canteenTxnRef;

  test('Step 1: Create UPI orders for Canteen and Nescafe', async ({ request }) => {
    // 1. Canteen Order
    const cRes = await request.post('/api/orders', {
      data: {
        orderId: canteenOrderId,
        vendorId: 'canteen',
        outlet: 'Canteen',
        userName: 'UPI Tester',
        userEmail: 'upi.test@hungerzone.com',
        userPhone: '9876543210',
        paymentMethod: 'UPI',
        items: [{ name: 'Thali', price: 80, quantity: 1 }],
      },
    });
    expect(cRes.status()).toBe(201);

    // 2. Nescafé Order
    const nRes = await request.post('/api/orders', {
      data: {
        orderId: nescafeOrderId,
        vendorId: 'nescafe',
        outlet: 'Nescafe',
        userName: 'UPI Tester',
        userEmail: 'upi.test@hungerzone.com',
        userPhone: '9876543210',
        paymentMethod: 'UPI',
        items: [{ name: 'Cold Coffee', price: 40, quantity: 1 }],
      },
    });
    expect(nRes.status()).toBe(201);
  });

  test('POST /api/payment/create-intent - Main Canteen returns dynamic BharatPe parameters', async ({ request }) => {
    const res = await request.post('/api/payment/create-intent', {
      data: {
        orderId: canteenOrderId,
        vendorId: 'canteen',
      },
    });

    expect(res.status()).toBe(200);
    const intent = await res.json();
    expect(intent.success).toBe(true);
    expect(intent.receiverUpiId).toBe('BHARATPE.9J0E0Z0U0M847077@unitype');
    expect(intent.receiverName).toBe('SIMON RAJKUMAR GROVER');
    expect(intent.merchantId).toBe('5812');
    expect(intent.amount).toBe(80);
    expect(intent.transactionRef).toContain(`HZ_${canteenOrderId}`);

    canteenTxnRef = intent.transactionRef;
    console.log(`[PASS] Dynamic UPI intent generated for Main Canteen: VPA ${intent.receiverUpiId}, Amount ₹${intent.amount}`);
  });

  test('POST /api/payment/create-intent - Nescafé strictly rejected with HTTP 400 (Unconfigured Vendor)', async ({ request }) => {
    const res = await request.post('/api/payment/create-intent', {
      data: {
        orderId: nescafeOrderId,
        vendorId: 'nescafe',
      },
    });

    expect(res.status()).toBe(400);
    const body = await res.json();
    expect(body.message).toBe('Payment is currently unavailable for this vendor.');

    console.log('[PASS] Unconfigured outlet (Nescafé) correctly blocked from online UPI intent.');
  });

  test('POST /api/payment/verify - Verifies payment approval and updates paymentStatus to SUCCESS', async ({ request }) => {
    const res = await request.post('/api/payment/verify', {
      data: {
        orderId: canteenOrderId,
        transactionRef: canteenTxnRef,
        status: 'SUCCESS',
        approvalRefNo: 'UTR_PLAYWRIGHT_998877',
      },
    });

    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.success).toBe(true);
    expect(body.order.paymentStatus).toBe('SUCCESS');
    expect(body.order.approvalRefNo).toBe('UTR_PLAYWRIGHT_998877');

    console.log('[PASS] UPI payment verified and order status transitioned to SUCCESS.');
  });
});
