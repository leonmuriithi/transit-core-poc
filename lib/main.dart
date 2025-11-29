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
      title: 'TransitCore',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: const BookingScreen(),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // 0=Standard, 1=Booked, 2=Selected, 3=Aisle, 4=VIP
  List<int> seatStatus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSeatData();
  }

  // Simulate API Call to Node.js Backend
  Future<void> _fetchSeatData() async {
    await Future.delayed(const Duration(seconds: 2)); // Fake Network Delay
    setState(() {
      seatStatus = List.generate(45, (index) {
        if (index % 5 == 2) return 3; // Aisle
        if (index < 10 && index % 5 != 2) return 4; // VIP
        if (index % 7 == 0 || index % 13 == 0) return 1; // Booked
        return 0; // Standard
      });
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRouteInfo(),
                    const SizedBox(height: 20),
                    _buildSeatLegend(),
                    const SizedBox(height: 20),
                    _buildBusLayout(),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1A237E),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text("Select Seats", style: TextStyle(color: Colors.white, fontSize: 16)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF283593), Color(0xFF1A237E)],
            ),
          ),
          child: const Center(
            child: Icon(Icons.directions_bus_filled, size: 80, color: Colors.white12),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nairobi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("08:00 AM", style: TextStyle(color: Colors.grey)),
            ],
          ),
          Icon(Icons.arrow_forward, color: Colors.indigo),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Mombasa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("16:00 PM", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusLayout() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Icon(Icons.circle, size: 10, color: Colors.grey), // Driver Wheel
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seatStatus.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => _buildSeatItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem(int index) {
    if (seatStatus[index] == 3) return const SizedBox(); // Aisle

    int status = seatStatus[index];
    Color color = status == 1 ? Colors.grey.shade300 : (status == 2 ? Colors.orange : (status == 4 ? Colors.indigo : Colors.white));
    Color border = status == 2 ? Colors.orange : Colors.grey.shade300;

    return GestureDetector(
      onTap: () {
        if (status == 1) return;
        setState(() {
          seatStatus[index] = (status == 2) ? (index < 10 ? 4 : 0) : 2;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 2),
          boxShadow: status == 2 ? [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 5)] : null,
        ),
        child: Icon(Icons.chair, color: status == 0 ? Colors.grey : Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LegendItem(color: Colors.white, label: "Std"),
        LegendItem(color: Colors.indigo, label: "VIP"),
        LegendItem(color: Colors.grey, label: "Taken"),
        LegendItem(color: Colors.orange, label: "Yours"),
      ],
    );
  }

  Widget _buildBottomBar() {
    int selected = seatStatus.where((s) => s == 2).length;
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$selected Seats • KES ${selected * 1500}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ElevatedButton(
              onPressed: selected > 0 ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text("BOOK NOW"),
            )
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(color: color, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
