const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

test.describe('E2E Suite 9: Public Root Banner & Static Policy Documents', () => {

  test('GET / - Root endpoint returns welcoming API operational message', async ({ request }) => {
    const res = await request.get('/');
    expect(res.status()).toBe(200);
    const text = await res.text();
    expect(text).toContain('Hunger Zone API is running');
    console.log('[PASS] Root endpoint verified: "Hunger Zone API is running 🍽️"');
  });

  test('Validate HTML policy documents (privacy, terms, refund, landing)', async () => {
    const docs = ['index.html', 'privacy.html', 'terms.html', 'refund.html'];
    const projectRoot = path.resolve(__dirname, '../../../');

    for (const doc of docs) {
      const filePath = path.join(projectRoot, doc);
      expect(fs.existsSync(filePath)).toBe(true);

      const content = fs.readFileSync(filePath, 'utf-8');
      expect(content).toContain('<!DOCTYPE html>');
      expect(content).toContain('Hunger Zone');
      console.log(`[PASS] Verified policy/landing document: ${doc} (${content.length} bytes)`);
    }
  });
});
