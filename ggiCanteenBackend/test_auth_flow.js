const http = require('http');

const options = (path, method = 'POST') => ({
    hostname: 'localhost',
    port: 5000,
    path: path,
    method: method,
    headers: {
        'Content-Type': 'application/json'
    }
});

function makeRequest(path, data, method = 'POST') {
    return new Promise((resolve, reject) => {
        const req = http.request(options(path, method), (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => resolve({ status: res.statusCode, data: JSON.parse(body) }));
        });
        req.on('error', (e) => reject(e));
        if (data) req.write(JSON.stringify(data));
        req.end();
    });
}

async function testAuth() {
    console.log('--- Testing Auth Flow ---');

    const phone = '1234567890';
    const otp = '123456';

    try {
        // 1. Request OTP
        console.log('\n1. Requesting OTP...');
        const reqOtp = await makeRequest('/request-otp', { phoneNumber: phone });
        console.log('Status:', reqOtp.status, reqOtp.data);

        // 2. Signup
        console.log('\n2. Testing Signup...');
        const signup = await makeRequest('/signup', {
            name: 'Test User',
            phoneNumber: phone,
            password: 'password123',
            role: 'user',
            otp: otp
        });
        console.log('Status:', signup.status, signup.data);

        // 3. Login
        console.log('\n3. Testing Login...');
        const login = await makeRequest('/login', {
            phoneNumber: phone,
            password: 'password123'
        });
        console.log('Status:', login.status, login.data);

        // 4. Daily Verify (for Operator)
        console.log('\n4. Testing Daily Verify...');
        await makeRequest('/request-otp', { phoneNumber: phone });
        const verify = await makeRequest('/daily-verify', {
            phoneNumber: phone,
            otp: otp
        });
        console.log('Status:', verify.status, verify.data);

    } catch (err) {
        console.error('Test failed:', err);
    }
}

testAuth();
