import 'package:flutter/material.dart';

class InseminationDashboardPage extends StatefulWidget {
  const InseminationDashboardPage({super.key});

  @override
  State<InseminationDashboardPage> createState() =>
      _InseminationDashboardPageState();
}

class _InseminationDashboardPageState extends State<InseminationDashboardPage> {
  // TODO: เปลี่ยนเป็นดึงจาก API จริง
  final overview = {'total': 10, 'success': 7, 'failed': 3, 'success_rate': 70.0};

  final statsByVet = [
    {'name': 'นายสมชาย ใจดี', 'total': 6, 'success': 5, 'success_rate': 83.3},
    {'name': 'นางสาวมานี รักดี', 'total': 4, 'success': 2, 'success_rate': 50.0},
  ];

  final statsByBull = [
    {'name': 'บราห์มัน #3', 'total': 5, 'success': 4, 'success_rate': 80.0},
    {'name': 'ชาโรเล่ #1', 'total': 5, 'success': 3, 'success_rate': 60.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('สถิติการผสมเทียม'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overview Cards ───────────────────────────
            Row(
              children: [
                _overviewCard('ทั้งหมด', '${overview['total']}', Icons.analytics, Colors.blue),
                const SizedBox(width: 10),
                _overviewCard('สำเร็จ', '${overview['success']}', Icons.check_circle, Colors.green),
                const SizedBox(width: 10),
                _overviewCard('ไม่สำเร็จ', '${overview['failed']}', Icons.cancel, Colors.red),
              ],
            ),

            const SizedBox(height: 12),

            // ── Success Rate ─────────────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('อัตราสำเร็จรวม',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (overview['success_rate'] as double) / 100,
                              minHeight: 16,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${overview['success_rate']}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── สถิติแยกตามหมอ ───────────────────────────
            const Text('สถิติแยกตามสัตวแพทย์',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ...statsByVet.map((vet) => _statsCard(
                  name: vet['name'] as String,
                  total: vet['total'] as int,
                  success: vet['success'] as int,
                  rate: vet['success_rate'] as double,
                  icon: Icons.person,
                  color: Colors.blue,
                )),

            const SizedBox(height: 20),

            // ── สถิติแยกตามน้ำเชื้อวัว ───────────────────
            const Text('สถิติแยกตามน้ำเชื้อวัว',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ...statsByBull.map((bull) => _statsCard(
                  name: bull['name'] as String,
                  total: bull['total'] as int,
                  success: bull['success'] as int,
                  rate: bull['success_rate'] as double,
                  icon: Icons.pets,
                  color: Colors.orange,
                )),
          ],
        ),
      ),
    );
  }

  // ── Widgets ย่อย ─────────────────────────────────────
  Widget _overviewCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsCard({
    required String name,
    required int total,
    required int success,
    required double rate,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('$rate%',
                    style: TextStyle(
                        color: rate >= 70 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: rate / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: rate >= 70 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('ทั้งหมด $total ครั้ง',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                Text('สำเร็จ $success ครั้ง',
                    style: const TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}