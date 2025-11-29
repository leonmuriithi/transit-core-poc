/**
 * TRANSIT-CORE: Seat Inventory Schema
 * Tracks seat availability PER SEGMENT, not just per bus.
 */

const mongoose = require('mongoose');

const SeatInventorySchema = new mongoose.Schema({
  routeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Route' },
  date: { type: String, required: true }, // YYYY-MM-DD
  
  // ✅ SEGMENT TRACKING
  // Instead of blocking the whole bus, we block specific legs.
  // Example: Segment A (Nrb->Nakuru) can be LOCKED while Segment B (Nakuru->Kisumu) is OPEN.
  segments: [
    {
      segmentId: String,    // e.g., "SEG_NRB_NKR"
      fromStop: String,
      toStop: String,
      seats: [
        {
          number: Number,
          status: { type: String, enum: ['OPEN', 'LOCKED', 'BOOKED'], default: 'OPEN' },
          lockedBy: { type: String, default: null } // User ID
        }
      ]
    }
  ]
});

module.exports = mongoose.model('SeatInventory', SeatInventorySchema);
