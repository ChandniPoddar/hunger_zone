const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 3: Authentication & Admin Security', () => {

  test('POST /login - Authenticate all 4 outlet admins with seeded credentials', async ({ request }) => {
    const adminAccounts = [
      { email: 'admin.canteen@hungerzone.com', pass: 'canteen123', outlet: 'Canteen' },
      { email: 'admin.nescafe@hungerzone.com', pass: 'nescafe123', outlet: 'Nescafe' },
      { email: 'admin.lipton@hungerzone.com', pass: 'lipton123', outlet: 'Lipton' },
      { email: 'admin.fruit@hungerzone.com', pass: 'fruit123', outlet: 'Fruit Corner' },
    ];

    for (const admin of adminAccounts) {
      const res = await request.post('/login', {
        data: {
          email: admin.email,
          password: admin.pass,
        },
      });

      expect(res.status()).toBe(200);
      const user = await res.json();
      expect(user.email).toBe(admin.email);
      expect(user.role).toContain('admin');
      console.log(`[PASS] Admin login verified for: ${admin.outlet} (${admin.email})`);
    }
  });

  test('POST /login - Rejects incorrect password', async ({ request }) => {
    const res = await request.post('/login', {
      data: {
        email: 'admin.canteen@hungerzone.com',
        password: 'wrong_password_attempt',
      },
    });

    expect(res.status()).toBe(401);
    const body = await res.json();
    expect(body.message).toBe('Invalid email or password');
  });

  test('POST /login - Rejects non-existent email', async ({ request }) => {
    const res = await request.post('/login', {
      data: {
        email: 'ghost.user.999@hungerzone.com',
        password: 'somepassword123',
      },
    });

    expect(res.status()).toBe(401);
  });

  test('POST /login - Rejects missing fields', async ({ request }) => {
    const res = await request.post('/login', {
      data: { email: '' },
    });
    expect(res.status()).toBe(400);
  });

  test('POST /api/admin/change-credentials - Validates credentials before modifying', async ({ request }) => {
    // 1. Rejects wrong current password
    const failRes = await request.post('/api/admin/change-credentials', {
      data: {
        currentEmail: 'admin.canteen@hungerzone.com',
        currentPassword: 'invalid_current_password',
        newPassword: 'newSecretPassword123!',
      },
    });
    expect(failRes.status()).toBe(401);

    // 2. Rejects missing fields
    const missingRes = await request.post('/api/admin/change-credentials', {
      data: {
        currentEmail: 'admin.canteen@hungerzone.com',
        currentPassword: 'canteen123',
      },
    });
    expect(missingRes.status()).toBe(400);

    console.log('[PASS] Admin credential modification endpoint secured against unauthorized changes.');
  });

  test('POST /request-email-otp - Validates email format', async ({ request }) => {
    const res = await request.post('/request-email-otp', {
      data: { email: 'not-an-email' },
    });
    expect(res.status()).toBe(400);
    const body = await res.json();
    expect(body.message).toBe('Invalid email format');
  });
});
