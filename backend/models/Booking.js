/**
 * TRANSIT-CORE: Booking Schema
 * Designed for Dynamic Inventory Management (Segment-Based).
 */

const mongoose = require('mongoose');

const BookingSchema = new mongoose.Schema({
  ticketId: { type: String, required: true, unique: true },
  passengerName: { type: String, required: true },
  
  // ✅ THE CRITICAL FIELDS FOR DYNAMIC ROUTING
  // Allows us to sell the same seat twice if segments don't overlap.
  routeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Route' },
  seatNumber: { type: Number, required: true },
  
  boardingStop: { 
    stopId: String, 
    name: String, 
    orderIndex: Number // e.g., 1 (Nairobi)
  },
  
  dropOffStop: { 
    stopId: String, 
    name: String, 
    orderIndex: Number // e.g., 2 (Nakuru)
  },

  // Payment State Machine
  paymentStatus: { 
    type: String, 
    enum: ['PENDING_STK_PUSH', 'COMPLETED', 'FAILED'], 
    default: 'PENDING_STK_PUSH' 
  },
  mpesaReceipt: { type: String },

  createdAt: { type: Date, default: Date.now }
});

// ✅ INDEXING FOR SPEED
// Ensures fast lookup when checking "Is Seat 4 free between Index 1 and 3?"
BookingSchema.index({ routeId: 1, seatNumber: 1, "boardingStop.orderIndex": 1 });

module.exports = mongoose.model('Booking', BookingSchema);
