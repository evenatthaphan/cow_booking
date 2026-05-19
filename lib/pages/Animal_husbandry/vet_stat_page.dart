import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:provider/provider.dart';

class InseminationDashboardStatPage extends StatefulWidget {
  const InseminationDashboardStatPage({super.key});

  @override
  State<InseminationDashboardStatPage> createState() =>
      _InseminationDashboardStatPageState();
}

class _InseminationDashboardStatPageState extends State<InseminationDashboardStatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // สถิติรวมทั้งระบบ
  bool isLoadingGlobal = true;
  Map<String, dynamic> overviewGlobal = {};
  List<dynamic> statsByVet = [];
  List<dynamic> statsByBull = [];

  // สถิติของฉัน 
  bool isLoadingMine = true;
  Map<String, dynamic> overviewMine = {};
  List<dynamic> statsByVetMine = [];
  List<dynamic> statsByBullMine = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchGlobal();
    _fetchMine();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ดึงสถิติรวมทั้งระบบ 
  Future<void> _fetchGlobal() async {
    setState(() => isLoadingGlobal = true);
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$apiEndpoint/stats/stats/overview')),
        http.get(Uri.parse('$apiEndpoint/stats/insemination/by-vet')),
        http.get(Uri.parse('$apiEndpoint/stats/insemination/by-bull')),
      ]);
      setState(() {
        overviewGlobal = jsonDecode(responses[0].body);
        statsByVet = jsonDecode(responses[1].body);
        statsByBull = jsonDecode(responses[2].body);
        isLoadingGlobal = false;
      });
    } catch (e) {
      setState(() => isLoadingGlobal = false);
    }
  }

  // ดึงสถิติเฉพาะของฉัน 
  Future<void> _fetchMine() async {
    final Vetexport_id =
        context.read<DataVetExpert>().datauser.id;
    setState(() => isLoadingMine = true);
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(
            '$apiEndpoint/stats/insemination/my-overview/$Vetexport_id')),
        http.get(Uri.parse(
            '$apiEndpoint/stats/insemination/my-by-vet/$Vetexport_id')),
        http.get(Uri.parse(
            '$apiEndpoint/stats/insemination/my-by-bull/$Vetexport_id')),
      ]);
      setState(() {
        overviewMine = jsonDecode(responses[0].body);
        statsByVetMine = jsonDecode(responses[1].body);
        statsByBullMine = jsonDecode(responses[2].body);
        isLoadingMine = false;
      });
    } catch (e) {
      setState(() => isLoadingMine = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        title: Text('สถิติการผสมเทียม',
            style: GoogleFonts.notoSansThai(
                color: Colors.lightGreen[800], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.lightGreen[800],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green[900],
          labelColor: Colors.lightGreen[800],
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              child: Text('ของฉัน',
                  style: GoogleFonts.notoSansThai(fontSize: 15)),
            ),
            Tab(
              child: Text('ทั้งระบบ',
                  style: GoogleFonts.notoSansThai(fontSize: 15)),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1 farmer stats
          _buildStatsView(
            isLoading: isLoadingMine,
            overview: overviewMine,
            byVet: statsByVetMine,
            byBull: statsByBullMine,
            onRefresh: _fetchMine,
            emptyText: 'คุณยังไม่มีประวัติการผสม',
          ),

          // Tab 2 system stats
          _buildStatsView(
            isLoading: isLoadingGlobal,
            overview: overviewGlobal,
            byVet: statsByVet,
            byBull: statsByBull,
            onRefresh: _fetchGlobal,
          ),
        ],
      ),
    );
  }

  // main view 
  Widget _buildStatsView({
    required bool isLoading,
    required Map<String, dynamic> overview,
    required List<dynamic> byVet,
    required List<dynamic> byBull,
    required Future<void> Function() onRefresh,
    String emptyText = 'ยังไม่มีข้อมูล',
  }) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.green));
    }

    final total = (overview['total'] ?? 0) as int;

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text(emptyText,
                style: GoogleFonts.notoSansThai(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards 
            Row(
              children: [
                _overviewCard('ทั้งหมด', '${overview['total'] ?? 0}',
                    Icons.analytics, Colors.blue),
                const SizedBox(width: 10),
                _overviewCard('สำเร็จ', '${overview['success'] ?? 0}',
                    Icons.check_circle, Colors.green),
                const SizedBox(width: 10),
                _overviewCard('ไม่สำเร็จ', '${overview['failed'] ?? 0}',
                    Icons.cancel, Colors.red),
              ],
            ),

            const SizedBox(height: 16),

            // Pie Chart
            _sectionTitle('อัตราสำเร็จรวม'),
            const SizedBox(height: 8),
            _pieChartCard(overview),

            const SizedBox(height: 20),

            // Bar Chart หมอ 
            _sectionTitle('อัตราสำเร็จแยกตามสัตวแพทย์'),
            const SizedBox(height: 8),
            _barChartCard(
              dataList: byVet,
              labelKey: 'vetexpert_name',
              valueKey: 'success_rate',
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            // Bar Chart น้ำเชื้อ 
            _sectionTitle('อัตราสำเร็จแยกตามน้ำเชื้อวัว'),
            const SizedBox(height: 8),
            _barChartCard(
              dataList: byBull,
              labelKey: 'bull_name',
              valueKey: 'success_rate',
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            // รายละเอียดหมอ
            _sectionTitle('รายละเอียดแยกตามสัตวแพทย์'),
            const SizedBox(height: 8),
            ...byVet.map((v) => _statsCard(
                  name: v['vetexpert_name'] ?? '-',
                  total: v['total'] ?? 0,
                  success: v['success'] ?? 0,
                  rate: (v['success_rate'] ?? 0).toDouble(),
                  icon: Icons.person,
                  color: Colors.blue,
                )),

            const SizedBox(height: 20),

            // รายละเอียดน้ำเชื้อ 
            _sectionTitle('รายละเอียดแยกตามน้ำเชื้อวัว'),
            const SizedBox(height: 8),
            ...byBull.map((b) => _statsCard(
                  name: b['bull_name'] ?? '-',
                  total: b['total'] ?? 0,
                  success: b['success'] ?? 0,
                  rate: (b['success_rate'] ?? 0).toDouble(),
                  icon: Icons.pets,
                  color: Colors.orange,
                )),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _pieChartCard(Map<String, dynamic> overview) {
    final success = (overview['success'] ?? 0).toDouble();
    final failed = (overview['failed'] ?? 0).toDouble();
    final total = success + failed;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: total == 0
            ? const Center(child: Text('ยังไม่มีข้อมูล'))
            : Row(
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: success,
                          color: Colors.green,
                          title:
                              '${(success / total * 100).toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                          radius: 55,
                        ),
                        PieChartSectionData(
                          value: failed,
                          color: Colors.red,
                          title:
                              '${(failed / total * 100).toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                          radius: 55,
                        ),
                      ],
                    )),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendDot(Colors.green, 'สำเร็จ'),
                      const SizedBox(height: 8),
                      _legendDot(Colors.red, 'ไม่สำเร็จ'),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _barChartCard({
    required List<dynamic> dataList,
    required String labelKey,
    required String valueKey,
    required Color color,
  }) {
    if (dataList.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('ยังไม่มีข้อมูล')),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            maxY: 100,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final name = dataList[groupIndex][labelKey] ?? '-';
                  return BarTooltipItem(
                    '$name\n${rod.toY.toStringAsFixed(1)}%',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 25,
                  getTitlesWidget: (value, _) => Text('${value.toInt()}%',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.grey)),
                  reservedSize: 36,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= dataList.length) {
                      return const SizedBox();
                    }
                    final name =
                        (dataList[index][labelKey] ?? '-').toString();
                    final short = name.length > 8
                        ? '${name.substring(0, 8)}..'
                        : name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(short,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: dataList.asMap().entries.map((entry) {
              final rate = (entry.value[valueKey] ?? 0).toDouble();
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: rate,
                    color: color,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
          )),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title,
            style: GoogleFonts.notoSansThai(
                fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _overviewCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 14,
            height: 14,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
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
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold))),
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
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
                const Spacer(),
                Text('สำเร็จ $success ครั้ง',
                    style: const TextStyle(
                        color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}