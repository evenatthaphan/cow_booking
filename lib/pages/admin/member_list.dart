import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;

  List<Map<String, dynamic>> _farmers         = [];
  List<Map<String, dynamic>> _vets            = [];
  List<Map<String, dynamic>> _filteredFarmers = [];
  List<Map<String, dynamic>> _filteredVets    = [];

  final _searchCtrl   = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMembers());
    _searchCtrl.addListener(_applyFilter);
    _provinceCtrl.addListener(_applyFilter);
    _districtCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  // ── fetch ────────────────────────────────────────────────
  Future<void> _fetchMembers() async {
    if (!mounted) return;
    final auth = context.read<DataAdmin>();
    setState(() => _isLoading = true);

    try {
      final headers = {
        'Content-Type': 'application/json',
        'admin-type': auth.datauser.adminType.toString(),
      };

      final farmerRes = await http.get(
        Uri.parse('$apiEndpoint/admin/members?type=farmer'),
        headers: headers,
      );
      final vetRes = await http.get(
        Uri.parse('$apiEndpoint/admin/members?type=vetexpert'),
        headers: headers,
      );

      if (farmerRes.statusCode == 200) {
        final body = jsonDecode(farmerRes.body);
        _farmers = List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
      if (vetRes.statusCode == 200) {
        final body = jsonDecode(vetRes.body);
        _vets = List<Map<String, dynamic>>.from(body['data'] ?? []);
      }

      _applyFilter();
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── filter ───────────────────────────────────────────────
  void _applyFilter() {
    final q        = _searchCtrl.text.toLowerCase();
    final province = _provinceCtrl.text.toLowerCase();
    final district = _districtCtrl.text.toLowerCase();

    bool match(Map<String, dynamic> m) {
      final name  = (m['name']     ?? '').toLowerCase();
      final email = (m['email']    ?? '').toLowerCase();
      final prov  = (m['province'] ?? '').toLowerCase();
      final dist  = (m['district'] ?? '').toLowerCase();
      return (q.isEmpty || name.contains(q) || email.contains(q)) &&
             (province.isEmpty || prov.contains(province)) &&
             (district.isEmpty || dist.contains(district));
    }

    setState(() {
      _filteredFarmers = _farmers.where(match).toList();
      _filteredVets    = _vets.where(match).toList();
    });
  }

  void _clearFilter() {
    _searchCtrl.clear();
    _provinceCtrl.clear();
    _districtCtrl.clear();
  }

  bool get _hasFilter =>
      _searchCtrl.text.isNotEmpty ||
      _provinceCtrl.text.isNotEmpty ||
      _districtCtrl.text.isNotEmpty;

  // ── delete ───────────────────────────────────────────────
  Future<void> _deleteMember(Map<String, dynamic> m, bool isFarmer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการลบ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('ต้องการลบ "${m['name']}" ออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final auth     = context.read<DataAdmin>();
    final endpoint = isFarmer
        ? '$apiEndpoint/admin/members/farmer/${m['id']}'
        : '$apiEndpoint/admin/members/vetexpert/${m['id']}';

    try {
      final res = await http.delete(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': auth.datauser.adminType.toString(),
        },
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _showSnack(body['message'] ?? 'ลบสำเร็จ');
        _fetchMembers();
      } else {
        _showSnack(body['message'] ?? 'เกิดข้อผิดพลาด', isError: true);
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    }
  }

  // ── edit dialog ──────────────────────────────────────────
  void _showEditDialog(Map<String, dynamic> m, bool isFarmer) {
    final nameCtrl    = TextEditingController(text: m['name']        ?? '');
    final emailCtrl   = TextEditingController(text: m['email']       ?? '');
    final phoneCtrl   = TextEditingController(text: m['phonenumber'] ?? '');
    final addressCtrl = TextEditingController(text: m['address']     ?? '');
    final formKey     = GlobalKey<FormState>();
    bool saving       = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    (isFarmer ? Colors.blue : Colors.orange).withOpacity(0.15),
                child: Text(
                  (m['name'] ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFarmer ? Colors.blue : Colors.orange),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'แก้ไข${isFarmer ? 'เกษตรกร' : 'สัตวบาล'}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogField(nameCtrl,    'ชื่อ',         Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'กรุณากรอกชื่อ'
                            : null),
                    const SizedBox(height: 12),
                    _dialogField(emailCtrl,   'อีเมล',        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
                          if (!v.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                          return null;
                        }),
                    const SizedBox(height: 12),
                    _dialogField(phoneCtrl,   'เบอร์โทรศัพท์', Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _dialogField(addressCtrl, 'ที่อยู่',       Icons.location_on_outlined,
                        maxLines: 2),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => saving = true);

                      final auth = context.read<DataAdmin>();
                      final endpoint = isFarmer
                          ? '$apiEndpoint/admin/members/farmer/${m['id']}'
                          : '$apiEndpoint/admin/members/vetexpert/${m['id']}';

                      try {
                        final res = await http.put(
                          Uri.parse(endpoint),
                          headers: {
                            'Content-Type': 'application/json',
                            'admin-type':
                                auth.datauser.adminType.toString(),
                          },
                          body: jsonEncode({
                            'name':        nameCtrl.text.trim(),
                            'email':       emailCtrl.text.trim(),
                            'phonenumber': phoneCtrl.text.trim(),
                            'address':     addressCtrl.text.trim(),
                          }),
                        );
                        final body = jsonDecode(res.body);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (res.statusCode == 200) {
                          _showSnack(body['message'] ?? 'แก้ไขสำเร็จ');
                          _fetchMembers();
                        } else {
                          _showSnack(body['message'] ?? 'เกิดข้อผิดพลาด',
                              isError: true);
                        }
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('บันทึก',
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: validator,
      );

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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ตัวกรองเพิ่มเติม',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800])),
                TextButton(
                  onPressed: () {
                    _clearFilter();
                    Navigator.pop(context);
                  },
                  child: const Text('ล้างทั้งหมด',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _filterField(_provinceCtrl, 'จังหวัด', Icons.location_city_outlined),
            const SizedBox(height: 12),
            _filterField(_districtCtrl, 'อำเภอ',   Icons.map_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('ค้นหา',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField(
          TextEditingController ctrl, String label, IconData icon) =>
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
        ),
      );

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final adminType = context.watch<DataAdmin>().datauser.adminType;
    final isMaster  = adminType == 1; // เฉพาะ master เท่านั้น

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
            Text('จัดการสมาชิก',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900])),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_outlined),
                tooltip: 'ตัวกรอง',
                onPressed: _showFilterSheet,
              ),
              if (_hasFilter)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green[900],
          labelColor: Colors.green[900],
          unselectedLabelColor: Colors.grey[600],
          tabs: [
            Tab(text: 'เกษตรกร (${_filteredFarmers.length})'),
            Tab(text: 'สัตวบาล (${_filteredVets.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อหรืออีเมล...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // filter chips
          if (_hasFilter)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_provinceCtrl.text.isNotEmpty)
                    _chip('จังหวัด: ${_provinceCtrl.text}',
                        () => _provinceCtrl.clear()),
                  if (_districtCtrl.text.isNotEmpty)
                    _chip('อำเภอ: ${_districtCtrl.text}',
                        () => _districtCtrl.clear()),
                ],
              ),
            ),

          // tab content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _memberList(_filteredFarmers,
                          isFarmer: true, isMaster: isMaster),
                      _memberList(_filteredVets,
                          isFarmer: false, isMaster: isMaster),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onRemove) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Chip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          deleteIcon: const Icon(Icons.close, size: 14),
          onDeleted: onRemove,
          backgroundColor: Colors.green[50],
          side: BorderSide(color: Colors.green[200]!),
          visualDensity: VisualDensity.compact,
        ),
      );

  Widget _memberList(List<Map<String, dynamic>> list,
      {required bool isFarmer, required bool isMaster}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFarmer
                  ? Icons.agriculture
                  : Icons.medical_services_outlined,
              size: 56,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text('ไม่พบข้อมูล',
                style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green,
      onRefresh: _fetchMembers,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) =>
            _memberCard(list[i], isFarmer: isFarmer, isMaster: isMaster),
      ),
    );
  }

  Widget _memberCard(Map<String, dynamic> m,
      {required bool isFarmer, required bool isMaster}) {
    final name     = m['name']        ?? '-';
    final email    = m['email']       ?? '-';
    final phone    = m['phonenumber'] ?? '-';
    final province = m['province']    ?? '';
    final district = m['district']    ?? '';
    final locality = m['locality']    ?? '';
    final license  = m['license']     ?? '';
    final status   = m['status'];
    final initial  = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color    = isFarmer ? Colors.blue : Colors.orange;

    return Container(
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
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.12),
              child: Text(initial,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
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
                      if (!isFarmer) _statusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _infoRow(Icons.email_outlined, email),
                  _infoRow(Icons.phone_outlined, phone),
                  if (province.isNotEmpty || district.isNotEmpty)
                    _infoRow(
                      Icons.location_on_outlined,
                      [locality, district, province]
                          .where((s) => s.isNotEmpty)
                          .join(', '),
                    ),
                  if (!isFarmer && license.isNotEmpty)
                    _infoRow(Icons.badge_outlined, 'ใบอนุญาต: $license'),
                ],
              ),
            ),

            // action buttons — master เท่านั้น
            if (isMaster)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.blue, size: 20),
                    tooltip: 'แก้ไข',
                    onPressed: () => _showEditDialog(m, isFarmer),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    tooltip: 'ลบ',
                    onPressed: () => _deleteMember(m, isFarmer),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

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

  Widget _statusBadge(dynamic status) {
    final s     = status as int? ?? 0;
    final label = s == 1 ? 'อนุมัติแล้ว' : s == 2 ? 'ถูกปฏิเสธ' : 'รออนุมัติ';
    final color = s == 1 ? Colors.green  : s == 2 ? Colors.red    : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color)),
    );
  }
}