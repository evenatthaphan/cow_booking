import 'dart:convert';
import 'dart:io';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Editprofilepage extends StatefulWidget {
  const Editprofilepage({super.key});

  @override
  State<Editprofilepage> createState() => _EditprofilepageState();
}

class _EditprofilepageState extends State<Editprofilepage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // late TextEditingController _nameCtrl;
  // late TextEditingController _phoneCtrl;
  // late TextEditingController _emailCtrl;
  TextEditingController _nameCtrl  = TextEditingController();
  TextEditingController _phoneCtrl = TextEditingController();
  TextEditingController _emailCtrl = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final farmer = Provider.of<DataFarmers>(context, listen: false).datauser;
    _nameCtrl  = TextEditingController(text: farmer.farmersName);
    _phoneCtrl = TextEditingController(text: farmer.farmersPhonenumber);
    _emailCtrl = TextEditingController(text: farmer.farmersEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  static const _green = Color(0xFF2E7D32);

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _green,
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          ),
        ),
      ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cow Booking',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'แก้ไขข้อมูลส่วนตัว',
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: Colors.white70,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
            height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  // เลือกรูป
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('ถ่ายภาพ'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('เลือกจากคลัง'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // บันทึก
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final farmer  = Provider.of<DataFarmers>(context, listen: false).datauser;
      final farmerId = farmer.farmersId;

      final uri     = Uri.parse('$apiEndpoint/farmer/edit/$farmerId');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Accept'] = 'application/json'
        ..fields['farm_name']    = _nameCtrl.text.trim()
        ..fields['phonenumber']  = _phoneCtrl.text.trim()
        ..fields['farmer_email'] = _emailCtrl.text.trim();

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'profile_image', _selectedImage!.path));
      }

      final streamed = await request.send();
      final body     = await streamed.stream.bytesToString();

      if (!mounted) return;

      if (streamed.statusCode == 200) {
        await Provider.of<DataFarmers>(context, listen: false)
            .fetchFarmerById(farmerId);
        _showSnackbar('บันทึกข้อมูลสำเร็จ ✓', Colors.green);
        Navigator.pop(context);
      } else {
        final decoded = jsonDecode(body);
        _showSnackbar(decoded['error'] ?? 'เกิดข้อผิดพลาด', Colors.red);
      }
    } catch (e) {
      _showSnackbar('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final farmer = Provider.of<DataFarmers>(context).datauser;

    // ImageProvider รูปโปรไฟล์
    final ImageProvider profileImage = _selectedImage != null
        ? FileImage(_selectedImage!)
        : (farmer.farmersProfileImage.isNotEmpty
            ? NetworkImage(farmer.farmersProfileImage) as ImageProvider
            : const NetworkImage(
                'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png'));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // รูปโปรไฟล์ 
              _sectionLabel('รูปโปรไฟล์'),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: profileImage,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 8),
                const Center(
                  child: Text('รูปใหม่พร้อมบันทึก',
                      style: TextStyle(fontSize: 12, color: Colors.green)),
                ),
              ],

              const SizedBox(height: 24),

              // ข้อมูลส่วนตัว
              _sectionLabel('ข้อมูลส่วนตัว'),
              _infoCard([
                _inputField(
                  controller: _nameCtrl,
                  label: 'ชื่อ-นามสกุล',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อ' : null,
                ),
                _divider(),
                _inputField(
                  controller: _phoneCtrl,
                  label: 'เบอร์โทรศัพท์',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกเบอร์โทร' : null,
                ),
                _divider(),
                _inputField(
                  controller: _emailCtrl,
                  label: 'อีเมล',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกอีเมล' : null,
                ),
              ]),

              const SizedBox(height: 32),

              // ปุ่มบันทึก 
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('บันทึกข้อมูล',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                letterSpacing: 0.5)),
      );

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );

  Widget _divider() =>
      const Divider(height: 1, indent: 52, color: Color(0xFFEEEEEE));

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.green[600]),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle:
                      const TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
}