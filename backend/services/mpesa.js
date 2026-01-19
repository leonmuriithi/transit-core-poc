/**
 * M-PESA DARAJA API INTEGRATION
 * Handles STK Push and Callbacks
 */
const axios = require('axios');
const datetime = require('node-datetime');

const CONSUMER_KEY = process.env.MPESA_KEY;
const CONSUMER_SECRET = process.env.MPESA_SECRET;
const PASSKEY = process.env.MPESA_PASSKEY;

// 1. GENERATE AUTH TOKEN
const getOAuthToken = async () => {
    const auth = Buffer.from(`${CONSUMER_KEY}:${CONSUMER_SECRET}`).toString('base64');
    try {
        const response = await axios.get(
            'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials',
            { headers: { Authorization: `Basic ${auth}` } }
        );
        return response.data.access_token;
    } catch (error) {
        throw new Error("M-Pesa Auth Failed");
    }
};

// 2. TRIGGER STK PUSH (Lipa Na M-Pesa Online)
const triggerSTKPush = async (phoneNumber, amount, accountRef) => {
    const token = await getOAuthToken();
    const date = datetime.create();
    const timestamp = date.format('YmdHMS');
    
    // Password generation for STK
    const password = Buffer.from(
        `174379${PASSKEY}${timestamp}`
    ).toString('base64');

    const payload = {
        "BusinessShortCode": 174379,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": phoneNumber,
        "PartyB": 174379,
        "PhoneNumber": phoneNumber,
        "CallBackURL": "https://api.transitcore.io/hooks/mpesa",
        "AccountReference": accountRef,
        "TransactionDesc": "Bus Ticket Payment"
    };

    try {
        const response = await axios.post(
            'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
            payload,
            { headers: { Authorization: `Bearer ${token}` } }
        );
        console.log(`>>> [M-PESA] STK Push Sent to ${phoneNumber}`);
        return response.data;
    } catch (error) {
        console.error(">>> [M-PESA] STK Failed:", error.response.data);
        return null;
    }
};

module.exports = { triggerSTKPush };
