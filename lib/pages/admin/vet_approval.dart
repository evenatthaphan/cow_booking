import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VetApprovalPage extends StatefulWidget {
  const VetApprovalPage({super.key});

  @override
  State<VetApprovalPage> createState() => _VetApprovalPageState();
}

class _VetApprovalPageState extends State<VetApprovalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;

  List<Map<String, dynamic>> _pending  = [];
  List<Map<String, dynamic>> _approved = [];
  List<Map<String, dynamic>> _rejected = [];

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchVets());
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── fetch ────────────────────────────────────────────────
  Future<void> _fetchVets() async {
    if (!mounted) return;
    final auth = context.read<DataAdmin>();
    setState(() => _isLoading = true);

    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/admin/members?type=vetexpert'),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': auth.datauser.adminType.toString(),
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final all  = List<Map<String, dynamic>>.from(body['data'] ?? []);
        setState(() {
          _pending  = all.where((v) => (v['status'] as int? ?? 0) == 0).toList();
          _approved = all.where((v) => (v['status'] as int? ?? 0) == 1).toList();
          _rejected = all.where((v) => (v['status'] as int? ?? 0) == 2).toList();
        });
      } else if (res.statusCode == 403) {
        _showSnack('ไม่มีสิทธิ์เข้าถึง', isError: true);
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── approve / reject ─────────────────────────────────────
  Future<void> _updateStatus(Map<String, dynamic> vet, int status) async {
    final actionLabel = status == 1 ? 'อนุมัติ' : 'ปฏิเสธ';
    final actionColor = status == 1 ? Colors.green : Colors.red;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ยืนยันการ$actionLabel',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('ต้องการ$actionLabel "${vet['name']}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(actionLabel,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final auth = context.read<DataAdmin>();
    try {
      final res = await http.put(
        Uri.parse('$apiEndpoint/admin/verify-vet/${vet['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': auth.datauser.adminType.toString(),
        },
        body: jsonEncode({
          'status': status,
          'admin_id': auth.datauser.adminsId,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _showSnack(body['message'] ?? '$actionLabelสำเร็จ');
        _fetchVets();
      } else {
        _showSnack(body['message'] ?? 'เกิดข้อผิดพลาด', isError: true);
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    }
  }

  // ── fullscreen image viewer ──────────────────────────────
  void _openImageViewer(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewerPage(imageUrl: imageUrl),
      ),
    );
  }

  // ── detail bottom sheet ──────────────────────────────────
  void _showDetail(Map<String, dynamic> vet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final status    = vet['status'] as int? ?? 0;
        final isPending = status == 0;
        final licenseUrl = vet['license'] as String? ?? '';

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 16),

                // header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.orange.withOpacity(0.15),
                      child: Text(
                        (vet['name'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vet['name'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _statusBadge(status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // ข้อมูลติดต่อ
                _detailLabel('ข้อมูลติดต่อ'),
                _detailRow(Icons.email_outlined,       'อีเมล',    vet['email']       ?? '-'),
                _detailRow(Icons.phone_outlined,       'เบอร์โทร', vet['phonenumber'] ?? '-'),
                _detailRow(Icons.location_on_outlined, 'ที่อยู่',  vet['address']     ?? '-'),
                const SizedBox(height: 12),

                // ที่ตั้ง
                _detailLabel('ที่ตั้ง'),
                _detailRow(Icons.location_city_outlined, 'จังหวัด', vet['province'] ?? '-'),
                _detailRow(Icons.map_outlined,           'อำเภอ',   vet['district'] ?? '-'),
                _detailRow(Icons.place_outlined,         'ตำบล',    vet['locality'] ?? '-'),
                const SizedBox(height: 12),

                // ใบประกอบวิชาชีพ
                _detailLabel('ใบประกอบวิชาชีพ'),
                const SizedBox(height: 8),

                if (licenseUrl.isEmpty)
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined,
                            size: 36, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('ไม่มีรูปใบประกอบวิชาชีพ',
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                else
                  // thumbnail กดดู fullscreen
                  GestureDetector(
                    onTap: () => _openImageViewer(licenseUrl),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            licenseUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.orange, strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_outlined,
                                      size: 36, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text('โหลดรูปไม่สำเร็จ',
                                      style: TextStyle(color: Colors.grey[400])),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // overlay icon กดดู
                        Positioned(
                          bottom: 8, right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text('ดูขยาย',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ปุ่ม action เฉพาะ pending
                if (isPending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateStatus(vet, 2);
                          },
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 18),
                          label: const Text('ปฏิเสธ',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateStatus(vet, 1);
                          },
                          icon: const Icon(Icons.check,
                              color: Colors.white, size: 18),
                          label: const Text('อนุมัติ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── helpers ──────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((v) {
      return (v['name']    ?? '').toLowerCase().contains(_searchQuery) ||
             (v['email']   ?? '').toLowerCase().contains(_searchQuery) ||
             (v['license'] ?? '').toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pending  = _filterList(_pending);
    final approved = _filterList(_approved);
    final rejected = _filterList(_rejected);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[900]),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🐄', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Text('อนุมัติสัตวบาล',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900])),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green[900],
          labelColor: Colors.green[900],
          unselectedLabelColor: Colors.grey[600],
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('รออนุมัติ'),
                  if (_pending.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('${_pending.length}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'อนุมัติแล้ว (${_approved.length})'),
            Tab(text: 'ถูกปฏิเสธ (${_rejected.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อ, อีเมล, เลขใบอนุญาต...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _vetList(pending,  status: 0),
                      _vetList(approved, status: 1),
                      _vetList(rejected, status: 2),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _vetList(List<Map<String, dynamic>> list, {required int status}) {
    if (list.isEmpty) {
      final labels = [
        'ไม่มีรายการรออนุมัติ',
        'ยังไม่มีการอนุมัติ',
        'ยังไม่มีการปฏิเสธ'
      ];
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(labels[status], style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _fetchVets,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _vetCard(list[i], status: status),
      ),
    );
  }

  Widget _vetCard(Map<String, dynamic> vet, {required int status}) {
    final name       = vet['name']        ?? '-';
    final email      = vet['email']       ?? '-';
    final phone      = vet['phonenumber'] ?? '-';
    final licenseUrl = vet['license']     as String? ?? '';
    final initial    = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => _showDetail(vet),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.orange.withOpacity(0.12),
                child: Text(initial,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 16)),
              ),
              const SizedBox(width: 12),

              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                        _statusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _infoRow(Icons.email_outlined, email),
                    _infoRow(Icons.phone_outlined, phone),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // thumbnail ใบอนุญาต
              if (licenseUrl.isNotEmpty)
                GestureDetector(
                  onTap: () => _openImageViewer(licenseUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      licenseUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              width: 52, height: 52,
                              color: Colors.grey[100],
                              child: const Center(
                                child: SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.orange),
                                ),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.grey[400], size: 24),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey[400], size: 24),
                ),

              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── shared widgets ────────────────────────────────────────
  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            Icon(icon, size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );

  Widget _statusBadge(int status) {
    final label = status == 1 ? 'อนุมัติแล้ว' : status == 2 ? 'ถูกปฏิเสธ' : 'รออนุมัติ';
    final color = status == 1 ? Colors.green  : status == 2 ? Colors.red    : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _detailLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800])),
      );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

// ============================================================
// หน้า Fullscreen Image Viewer
// ============================================================
class _ImageViewerPage extends StatelessWidget {
  final String imageUrl;
  const _ImageViewerPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ใบประกอบวิชาชีพ',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          // ปุ่มดาวน์โหลด / share (optional)
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            tooltip: 'เปิดในเบราว์เซอร์',
            onPressed: () {
              // ถ้าต้องการเปิด URL ภายนอก ใช้ url_launcher
              // launchUrl(Uri.parse(imageUrl));
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text('กำลังโหลดรูป...',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              );
            },
            errorBuilder: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined,
                    size: 64, color: Colors.grey[600]),
                const SizedBox(height: 12),
                Text('โหลดรูปไม่สำเร็จ',
                    style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}