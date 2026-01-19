import 'dart:async';
import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart'; // The "Security" flex
import 'package:path/path.dart';

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  static Database? _database;

  factory OfflineManager() => _instance;
  OfflineManager._internal();

  // 1. SECURE DATABASE INIT
  Future<Database> get database async {
    if (_database != null) return _database!;
    // In production, password comes from SecureStorage
    _database = await initDB("transit_core_secure.db", "my_secure_password"); 
    return _database!;
  }

  Future<Database> initDB(String name, String password) async {
    String path = join(await getDatabasesPath(), name);
    return await openDatabase(
      path, 
      password: password, // SQLCipher Encryption
      version: 1, 
      onCreate: (db, version) async {
        // Local Manifest Table
        await db.execute('''
          CREATE TABLE manifest (
            ticketId TEXT PRIMARY KEY,
            seatNumber INTEGER,
            passengerName TEXT,
            isSynced INTEGER DEFAULT 0
          )
        ''');
        
        // Sync Queue Table (For Offline Actions)
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT,
            payload TEXT,
            timestamp INTEGER
          )
        ''');
      }
    );
  }

  // 2. OFFLINE-FIRST WRITE STRATEGY
  Future<void> queueTicketValidation(String ticketId) async {
    final db = await database;
    
    // A. Optimistic Update (Update UI immediately)
    await db.update('manifest', {'status': 'VALIDATED'}, 
      where: 'ticketId = ?', whereArgs: [ticketId]);

    // B. Add to Sync Queue (For when internet returns)
    await db.insert('sync_queue', {
      'action': 'VALIDATE_TICKET',
      'payload': jsonEncode({'ticketId': ticketId, 'agentId': 'AGT_001'}),
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
    
    print(">>> [OFFLINE] Action Queued: VALIDATE_TICKET for $ticketId");
  }

  // 3. BACKGROUND SYNC (Called by WorkManager)
  Future<void> processSyncQueue() async {
    final db = await database;
    final List<Map<String, dynamic>> queue = await db.query('sync_queue');
    
    if (queue.isEmpty) return;

    print(">>> [SYNC] Processing ${queue.length} offline actions...");
    // Loop through queue and POST to Node.js backend...
  }
}
