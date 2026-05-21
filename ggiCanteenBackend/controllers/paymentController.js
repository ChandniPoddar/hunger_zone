const axios = require('axios');
const crypto = require('crypto');

// Using standard PhonePe credentials structure
// For production, these should be in .env
const MERCHANT_ID = process.env.PHONEPE_MERCHANT_ID || 'PGTESTPAYUAT';
const SALT_KEY = process.env.PHONEPE_SALT_KEY || '099eb0cd-02cf-4e2a-8aca-3e6c6aff0399';
const SALT_INDEX = process.env.PHONEPE_SALT_INDEX || '1';
const ENV = process.env.PHONEPE_ENV || 'SANDBOX'; // 'SANDBOX' or 'PRODUCTION'

// PhonePe endpoints
const PHONEPE_HOST = ENV === 'PRODUCTION' 
    ? 'https://api.phonepe.com/apis/hermes' 
    : 'https://api-preprod.phonepe.com/apis/pg-sandbox';

exports.createPhonePeOrder = async (req, res) => {
    try {
        const { amount, userId, mobileNumber } = req.body;
        const merchantTransactionId = `TXN${Date.now()}`;

        // Standard S2S payload for PhonePe PG
        const payload = {
            merchantId: MERCHANT_ID,
            merchantTransactionId: merchantTransactionId,
            merchantUserId: userId || 'USER123',
            amount: Math.round(amount * 100), // in paise
            redirectUrl: `${process.env.BASE_URL || 'http://localhost:5000'}/api/payment/callback`,
            redirectMode: "POST",
            callbackUrl: `${process.env.BASE_URL || 'http://localhost:5000'}/api/payment/callback`,
            mobileNumber: mobileNumber || '9999999999',
            paymentInstrument: {
                type: "PAY_PAGE"
            }
        };

        const payloadString = JSON.stringify(payload);
        const base64Payload = Buffer.from(payloadString).toString('base64');
        const stringToSign = base64Payload + '/pg/v1/pay' + SALT_KEY;
        const checksum = crypto.createHash('sha256').update(stringToSign).digest('hex') + '###' + SALT_INDEX;

        const response = await axios.post(`${PHONEPE_HOST}/pg/v1/pay`, {
            request: base64Payload
        }, {
            headers: {
                'Content-Type': 'application/json',
                'X-VERIFY': checksum
            }
        });

        let token = base64Payload; // For some SDK versions, the token is just the base64 payload
        if (response.data && response.data.success && response.data.data.instrumentResponse?.intentUrl) {
            // Depending on the API mode, sometimes it returns a token/intentUrl
             token = response.data.data.instrumentResponse.intentUrl; 
        }

        res.status(200).json({
            success: true,
            orderId: merchantTransactionId,
            token: token,
            merchantId: MERCHANT_ID,
            amount: amount,
            environment: ENV
        });

    } catch (error) {
        console.error("PhonePe Create Order Error:", error.response ? error.response.data : error.message);
        res.status(500).json({ success: false, message: "Payment Initiation Failed" });
    }
};

exports.phonepeCallback = async (req, res) => {
    try {
        const { response } = req.body;
        if (!response) {
            return res.status(400).send("No response body");
        }
        
        // Decode base64 response
        const decodedString = Buffer.from(response, 'base64').toString('utf-8');
        const decodedJson = JSON.parse(decodedString);
        
        console.log("PhonePe Callback received:", decodedJson);
        
        if (decodedJson.code === 'PAYMENT_SUCCESS') {
            // Update order status in DB
            console.log("Payment successful for TXN:", decodedJson.data.merchantTransactionId);
        } else {
            console.log("Payment failed for TXN:", decodedJson.data.merchantTransactionId);
        }

        res.status(200).send("OK");
    } catch(err) {
        console.error("Callback Error:", err);
        res.status(500).send("Error");
    }
};
