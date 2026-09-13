// @ts-check
const { defineConfig } = require('@playwright/test');

/**
 * Playwright E2E Configuration for HungerZone
 * Supports direct API testing & web testing
 */
module.exports = defineConfig({
  testDir: './tests/e2e',
  timeout: 30000,
  expect: {
    timeout: 10000,
  },
  fullyParallel: false, // Run suites sequentially to prevent race conditions on shared DB
  workers: 1,
  reporter: [['list'], ['json', { outputFile: 'test-results.json' }]],
  use: {
    baseURL: process.env.TEST_BASE_URL || 'http://localhost:5000',
    extraHTTPHeaders: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    trace: 'on-first-retry',
  },
});
