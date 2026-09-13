const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 8: Push Notifications & FCM Device Token Management', () => {

  const testEmail = `fcm.user.${Date.now()}@hungerzone.com`;
  const testFcmToken = `fcm_device_token_sample_${Date.now()}`;

  test('POST /notifications/register-token - Registers FCM token for a user', async ({ request }) => {
    const res = await request.post('/notifications/register-token', {
      data: {
        email: testEmail,
        fcmToken: testFcmToken,
        role: 'user',
        outletName: 'Canteen',
      },
    });

    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.success).toBe(true);
    expect(body.message).toContain('FCM token registered');
    console.log(`[PASS] FCM token registered for ${testEmail}`);
  });

  test('POST /notifications/register-token - Rejects missing parameters', async ({ request }) => {
    const res = await request.post('/notifications/register-token', {
      data: {
        email: '',
      },
    });
    expect(res.status()).toBe(400);
  });

  test('POST /notifications/remove-token - Cleans up FCM token on user logout', async ({ request }) => {
    const res = await request.post('/notifications/remove-token', {
      data: {
        email: testEmail,
        fcmToken: testFcmToken,
      },
    });

    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.success).toBe(true);
    console.log(`[PASS] FCM token removed successfully on logout for ${testEmail}`);
  });
});
