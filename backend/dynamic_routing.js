/**
 * TRANSIT-CORE: Dynamic Segment Locking Engine
 * Prevents double-booking on multi-stop routes (e.g., Nairobi->Nakuru->Eldoret)
 */

const mongoose = require('mongoose');

const lockSeatTransaction = async (routeId, seatNo, segmentIds, userId) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    // 1. ATOMIC CHECK: Check availability for these specific segments ONLY
    const availableSeats = await SeatInventory.find({
      route: routeId,
      seatNumber: seatNo,
      segmentId: { $in: segmentIds }, 
      status: 'OPEN'
    }).session(session);

    // If we requested 2 segments but only 1 is free, FAIL the booking
    if (availableSeats.length !== segmentIds.length) {
      throw new Error('Seat conflict: Segments no longer available.');
    }

    // 2. LOCK: Update status to LOCKED for these segments
    await SeatInventory.updateMany(
      { route: routeId, seatNumber: seatNo, segmentId: { $in: segmentIds } },
      { 
        $set: { 
          status: 'LOCKED', 
          lockedBy: userId, 
          paymentStatus: 'PENDING_STK_PUSH',
          lockedAt: new Date()
        } 
      }
    ).session(session);

    await session.commitTransaction();
    return { success: true, message: "Seat Locked. Proceed to M-Pesa." };

  } catch (error) {
    await session.abortTransaction();
    return { success: false, error: error.message };
  } finally {
    session.endSession();
  }
};