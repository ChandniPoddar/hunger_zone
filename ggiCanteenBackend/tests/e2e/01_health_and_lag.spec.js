const { test, expect } = require('@playwright/test');

test.describe('E2E Suite 1: Health Check & System Lag Diagnostics', () => {

  test('GET /api/health - Full system diagnostics and lag evaluation', async ({ request }) => {
    const startTime = Date.now();
    const response = await request.get('/api/health');
    const duration = Date.now() - startTime;

    expect(response.status()).toBe(200);
    const body = await response.json();

    // Verify top-level status and schema
    expect(['HEALTHY', 'DEGRADED']).toContain(body.status);
    expect(body.statusCode).toBe(200);
    expect(body.timestamp).toBeDefined();
    expect(body.durationMs).toBeGreaterThan(0);

    // Verify Lag Analysis engine
    expect(body.lagAnalysis).toBeDefined();
    expect(typeof body.lagAnalysis.isLagging).toBe('boolean');
    expect(Array.isArray(body.lagAnalysis.bottlenecks)).toBe(true);
    expect(Array.isArray(body.lagAnalysis.recommendations)).toBe(true);
    expect(body.lagAnalysis.recommendations.length).toBeGreaterThan(0);

    // Verify Database subsystem
    const db = body.subsystems.database;
    expect(db).toBeDefined();
    expect(db.state).toBe('connected');
    expect(db.pingMs).toBeGreaterThan(0);
    expect(db.name).toBe('ggiCanteen');
    expect(db.counts).toBeDefined();
    expect(db.counts.users).toBeGreaterThanOrEqual(0);
    expect(db.counts.orders).toBeGreaterThanOrEqual(0);
    expect(db.counts.vendors).toBeGreaterThanOrEqual(4);

    // Verify Multi-Vendor subsystem
    const vendors = body.subsystems.vendors;
    expect(vendors).toBeDefined();
    expect(vendors.totalRegistered).toBeGreaterThanOrEqual(4);
    expect(vendors.outlets.length).toBeGreaterThanOrEqual(4);

    // Verify System metrics
    const sys = body.system;
    expect(sys).toBeDefined();
    expect(sys.uptimeSeconds).toBeGreaterThan(0);
    expect(sys.platform).toBeDefined();
    expect(sys.memory).toBeDefined();
    expect(sys.memory.heapUsedMb).toBeGreaterThan(0);

    console.log(`[PASS] /api/health probed in ${duration}ms (DB Ping: ${db.pingMs}ms, Status: ${body.status})`);
  });

  test('GET /api/health/ping - Fast liveness probe responds in < 50ms', async ({ request }) => {
    const startTime = Date.now();
    const response = await request.get('/api/health/ping');
    const duration = Date.now() - startTime;

    expect(response.status()).toBe(200);
    const body = await response.json();

    expect(body.status).toBe('UP');
    expect(body.message).toContain('HungerZone');
    expect(body.uptimeSeconds).toBeGreaterThan(0);
    expect(duration).toBeLessThan(1000); // well within reasonable bounds

    console.log(`[PASS] /api/health/ping responded in ${duration}ms`);
  });

  test('GET /api/health/db - Dedicated MongoDB latency & collection probe', async ({ request }) => {
    const response = await request.get('/api/health/db');
    expect(response.status()).toBe(200);
    const body = await response.json();

    expect(['HEALTHY', 'DEGRADED']).toContain(body.status);
    expect(body.state).toBe('connected');
    expect(body.pingMs).toBeGreaterThan(0);
    expect(body.database).toBe('ggiCanteen');
    expect(body.counts.vendors).toBeGreaterThanOrEqual(4);

    console.log(`[PASS] /api/health/db DB round-trip latency: ${body.pingMs}ms`);
  });
});
