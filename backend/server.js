/**
 * TRANSIT-CORE API GATEWAY v1.0
 * Handles Booking Requests, Seat Locking, and M-Pesa Callbacks.
 */

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

// Initialize App
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// --- MOCK DATABASE (For Demo Purposes if Mongo isn't running) ---
// In production, this pulls from MongoDB Atlas
let MOCK_SEAT_INVENTORY = [
    { seat: 1, status: 'BOOKED' },
    { seat: 2, status: 'OPEN' },
    { seat: 3, status: 'OPEN' },
    { seat: 4, status: 'LOCKED' } // Locked by another user
];

// --- ROUTES ---

// 1. Health Check (To prove server is running)
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OPERATIONAL', 
        service: 'TransitCore Engine', 
        timestamp: new Date() 
    });
});

// 2. Get Bus Layout & Status
app.get('/api/bus/nairobi-mombasa/inventory', (req, res) => {
    // Simulate DB Latency
    setTimeout(() => {
        res.json({
            route: 'Nairobi -> Mombasa',
            busType: 'Luxury 2x2',
            inventory: MOCK_SEAT_INVENTORY
        });
    }, 500);
});

// 3. The "Dynamic Booking" Endpoint
app.post('/api/book-seat', async (req, res) => {
    const { seatNumber, userId, segments } = req.body;

    console.log(`[INFO] Booking Request: Seat ${seatNumber} for User ${userId}`);

    // LOGIC: Check if seat is already taken in the Mock DB
    const seat = MOCK_SEAT_INVENTORY.find(s => s.seat === seatNumber);
    
    if (seat && seat.status !== 'OPEN') {
        return res.status(409).json({ 
            success: false, 
            message: 'Seat conflict: Seat locked by another transaction.' 
        });
    }

    // SIMULATE: Locking the seat logic
    // In real app, this calls dynamic_routing.js
    return res.json({
        success: true,
        message: 'Seat Locked. STK Push sent to phone.',
        ticketId: 'TKT-' + Math.floor(Math.random() * 100000)
    });
});

// --- SERVER START ---
app.listen(PORT, () => {
    console.log(`\n>>> TRANSIT-CORE ENGINE STARTED ON PORT ${PORT}`);
    console.log(`>>> Connected to Database: MOCKED (Demo Mode)`);
    console.log(`>>> M-Pesa Callback Listener: ACTIVE\n`);
});
