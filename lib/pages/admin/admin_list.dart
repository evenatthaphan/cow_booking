import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/admin/admin_form.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _admins    = [];
  List<Map<String, dynamic>> _filtered  = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAdmins());
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // fetch 
  Future<void> _fetchAdmins() async {
    if (!mounted) return;
    final auth = context.read<DataAdmin>();
    setState(() => _isLoading = true);

    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/admin/list'),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': auth.datauser.adminType.toString(),
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = List<Map<String, dynamic>>.from(body['data']);
        setState(() {
          _admins   = list;
          _filtered = list;
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

  // search 
  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _admins.where((a) {
        return (a['admins_name']  ?? '').toLowerCase().contains(q) ||
               (a['admins_email'] ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  // ── delete ──────────────────────────────────────────────
  Future<void> _deleteAdmin(Map<String, dynamic> admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการลบ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'ต้องการลบ "${admin['admins_name']}" ออกจากระบบใช่หรือไม่?'),
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
            child:
                const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final auth = context.read<DataAdmin>();
    try {
      final res = await http.delete(
        Uri.parse('$apiEndpoint/admin/delete/${admin['admins_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'admin-type': auth.datauser.adminType.toString(),
        },
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _showSnack(body['message'] ?? 'ลบสำเร็จ');
        _fetchAdmins();
      } else {
        _showSnack(body['message'] ?? 'เกิดข้อผิดพลาด', isError: true);
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    }
  }

  // navigate to form 
  Future<void> _openForm({Map<String, dynamic>? admin}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminFormPage(admin: admin),
      ),
    );
    if (result == true) _fetchAdmins(); // reload หลังบันทึก
  }

  // helpers
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

  String _typeLabel(int type) {
    switch (type) {
      case 1:  return 'Master';
      case 2:  return 'Super';
      default: return 'Admin';
    }
  }

  Color _typeColor(int type) {
    switch (type) {
      case 1:  return Colors.purple;
      case 2:  return Colors.orange;
      default: return Colors.green;
    }
  }

  // ── build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final adminType = context.watch<DataAdmin>().datauser.adminType;
    final canCreate = adminType <= 2;
    final canDelete = adminType <= 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        elevation: 0,
        title: const Text(
          'จัดการผู้ดูแลระบบ',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: 'เพิ่ม Admin',
              onPressed: () => _openForm(),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อหรืออีเมล...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch();
                        },
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

          // ── Count ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                Text(
                  'ทั้งหมด ${_filtered.length} คน',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // ── List ────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text('ไม่พบข้อมูล',
                                style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.green,
                        onRefresh: _fetchAdmins,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) =>
                              _adminCard(_filtered[i], canDelete, adminType),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _adminCard(
      Map<String, dynamic> admin, bool canDelete, int myType) {
    final type    = admin['admin_type'] as int? ?? 3;
    final name    = admin['admins_name']  ?? '-';
    final email   = admin['admins_email'] ?? '-';
    final phone   = admin['admins_phonenumber'] ?? '-';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    // Super ลบได้เฉพาะ type=3
    final canDeleteThis =
        canDelete && (myType == 1 || (myType == 2 && type == 3));

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
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _typeColor(type).withOpacity(0.15),
          child: Text(
            initial,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _typeColor(type),
                fontSize: 16),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _typeColor(type).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _typeLabel(type),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _typeColor(type)),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.email_outlined, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(email,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.phone_outlined, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(phone,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ปุ่มแก้ไข (master + super)
            if (myType <= 2)
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.blue, size: 20),
                tooltip: 'แก้ไข',
                onPressed: () => _openForm(admin: admin),
              ),
            // ปุ่มลบ
            if (canDeleteThis)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                tooltip: 'ลบ',
                onPressed: () => _deleteAdmin(admin),
              ),
          ],
        ),
      ),
    );
  }
}