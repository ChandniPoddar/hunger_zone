const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 4: Menus, Catalog & Shop Status', () => {

  const categories = ['canteen', 'nescafe', 'lipton', 'fruit_corner'];

  for (const category of categories) {
    test(`GET /items/${category} - Fetches food items for ${category}`, async ({ request }) => {
      const res = await request.get(`/items/${category}`);
      expect(res.status()).toBe(200);

      const items = await res.json();
      expect(Array.isArray(items)).toBe(true);

      if (items.length > 0) {
        const item = items[0];
        expect(item._id).toBeDefined();
        expect(item.name).toBeDefined();
        expect(typeof item.price).toBe('number');
        expect(item.price).toBeGreaterThan(0);
        console.log(`[PASS] ${category} has ${items.length} items (Sample: "${item.name}" - ₹${item.price})`);
      } else {
        console.log(`[PASS] ${category} returned empty catalog array (0 items).`);
      }
    });
  }

  test('GET & PUT /shop-status/:outlet - Verifies shop open/close control', async ({ request }) => {
    // Fetch canteen shop status
    const getRes = await request.get('/shop-status/canteen');
    expect(getRes.status()).toBe(200);
    const getBody = await getRes.json();
    expect(getBody.outlet).toBe('canteen');
    expect(typeof getBody.isOpen).toBe('boolean');

    // Toggle shop status to true
    const putRes = await request.put('/shop-status/canteen', {
      data: { isOpen: true },
    });
    expect(putRes.status()).toBe(200);
    const putBody = await putRes.json();
    expect(putBody.isOpen).toBe(true);

    console.log('[PASS] Shop status endpoint verified for outlet controls.');
  });
});
