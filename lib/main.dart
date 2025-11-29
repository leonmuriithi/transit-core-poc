import 'package:flutter/material.dart';

void main() {
  runApp(const TransitCoreApp());
}

class TransitCoreApp extends StatelessWidget {
  const TransitCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransitCore Pro',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const SeatSelectionScreen(),
    );
  }
}

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // 0=Standard, 1=Booked, 2=Selected, 3=Aisle, 4=VIP Available
  late List<int> seatStatus;

  @override
  void initState() {
    super.initState();
    seatStatus = List.generate(45, (index) {
      if (index % 5 == 2) return 3; // Aisle
      if (index < 10 && index % 5 != 2) return 4; // First 2 rows are VIP
      if (index % 7 == 0 || index % 13 == 0) return 1; // Booked
      return 0; // Standard
    });
  }

  int get totalPrice {
    int standardCount = seatStatus.where((s) => s == 2 && _isStandardIndex(seatStatus.indexOf(s))).length; // Simplified logic
    int vipSelected = seatStatus.where((s) => s == 2).length; 
    // Quick math: VIP = 2500, Standard = 1200. 
    // Note: For this visual demo, we just multiply total selected by avg price or count specifically.
    // Let's count properly:
    int total = 0;
    for (int i = 0; i < seatStatus.length; i++) {
      if (seatStatus[i] == 2) {
        total += (i < 10) ? 2500 : 1200; // VIP is top 2 rows
      }
    }
    return total;
  }

  bool _isStandardIndex(int index) => index >= 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nairobi ➔ Kisumu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Luxury Liner • AC • WiFi', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
            child: const Text("45 MIN TO DEPART", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          _buildLegend(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDriverCabin(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: seatStatus.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) => _buildSeat(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildDriverCabin() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("DRIVER", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 10)),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.only(right: 30),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: Colors.grey)),
            child: const Icon(Icons.sports_esports, color: Colors.white, size: 20), // Steering Wheel
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(int index) {
    if (seatStatus[index] == 3) {
      return Center(child: Text("${(index ~/ 5) + 1}", style: const TextStyle(color: Colors.grey, fontSize: 10)));
    }

    bool isVIP = index < 10;
    bool isBooked = seatStatus[index] == 1;
    bool isSelected = seatStatus[index] == 2;

    Color color;
    if (isBooked) {
      color = Colors.grey.shade300;
    } else if (isSelected) {
      color = const Color(0xFFFF6D00); // Selection Orange
    } else if (isVIP) {
      color = const Color(0xFF1A237E); // VIP Navy
    } else {
      color = Colors.white; // Standard
    }

    return GestureDetector(
      onTap: () {
        if (isBooked) return;
        setState(() => seatStatus[index] = isSelected ? (isVIP ? 4 : 0) : 2);
      },
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? const Color(0xFFFF6D00) : (isVIP ? Colors.transparent : Colors.grey.shade300), width: 2),
              boxShadow: isSelected ? [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 8)] : null,
            ),
            child: Icon(Icons.chair, color: isBooked ? Colors.white : (isSelected || isVIP ? Colors.white : Colors.grey), size: 20),
          ),
          const SizedBox(height: 4),
          Text(isVIP ? "VIP" : "STD", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isVIP ? const Color(0xFF1A237E) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(const Color(0xFF1A237E), "VIP (2.5k)"),
          _legendItem(Colors.white, "Standard (1.2k)", border: true),
          _legendItem(Colors.grey.shade300, "Booked"),
          _legendItem(const Color(0xFFFF6D00), "Selected"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool border = false}) {
    return Row(children: [
      Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: color, 
          borderRadius: BorderRadius.circular(4),
          border: border ? Border.all(color: Colors.grey.shade300) : null
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0,-5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TOTAL AMOUNT", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text("KES $totalPrice", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              ],
            ),
            ElevatedButton(
              onPressed: totalPrice > 0 ? _showMpesaDialog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853), // M-Pesa Green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(children: [
                Icon(Icons.phone_android, size: 18),
                SizedBox(width: 5),
                Text("PAY WITH M-PESA"),
              ]),
            )
          ],
        ),
      ),
    );
  }

  void _showMpesaDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Confirm Payment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Enter your M-Pesa PIN on your phone when prompted.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const TextField(
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixText: "+254 ",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.contact_phone, color: Colors.green),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("SEND STK PUSH"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}