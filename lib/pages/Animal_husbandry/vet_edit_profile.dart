import 'dart:convert';
import 'dart:io';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VetEditProfilePage extends StatefulWidget {
  const VetEditProfilePage({super.key});

  @override
  State<VetEditProfilePage> createState() => _VetEditProfilePageState();
}

class _VetEditProfilePageState extends State<VetEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  // รูปภาพ — ถ้า null = ยังใช้รูปเดิม (URL)
  File? _profileImageFile;
  File? _licenseImageFile;

  @override
  void initState() {
    super.initState();
    final vet = Provider.of<DataVetExpert>(context, listen: false).datauser;
    _nameCtrl = TextEditingController(text: vet.vetExpertName);
    _phoneCtrl = TextEditingController(text: vet.phonenumber);
    _emailCtrl = TextEditingController(text: vet.vetExpertEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: true,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cow Booking',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[900],
                  height: 1.1,
                ),
              ),
              Text(
                'แก้ไขข้อมูลส่วนตัว',
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: Colors.green[900],
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  // เลือกรูป
  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      if (isProfile) {
        _profileImageFile = File(picked.path);
      } else {
        _licenseImageFile = File(picked.path);
      }
    });
  }

  void _showImagePicker(bool isProfile) {
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('ถ่ายภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isProfile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('เลือกจากคลัง'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isProfile);
              },
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
      final vet = Provider.of<DataVetExpert>(context, listen: false).datauser;

      // เปลี่ยนจาก http.put เป็น multipart
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$apiEndpoint/vet/vetexpert/update-profile/${vet.id}'),
      );

      request.fields['vetexperts_name'] = _nameCtrl.text.trim();
      request.fields['vetexperts_phonenumber'] = _phoneCtrl.text.trim();
      request.fields['vetexperts_email'] = _emailCtrl.text.trim();

      // แนบไฟล์เฉพาะเมื่อมีรูปใหม่
      if (_profileImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImageFile!.path,
        ));
      }
      if (_licenseImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'license_image',
          _licenseImageFile!.path,
        ));
      }

      final streamedRes = await request.send();
      final response = await http.Response.fromStream(streamedRes);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final updatedVet = body['vet'];

        final dataVet = Provider.of<DataVetExpert>(context, listen: false);
        final updated = dataVet.datauser.copyWith(
          vetExpertName: updatedVet['vetexperts_name'],
          phonenumber: updatedVet['vetexperts_phonenumber'],
          vetExpertEmail: updatedVet['vetexperts_email'],
          profileImage: updatedVet['vetexperts_profile_image'],
          vetExpertPl: updatedVet['vetexperts_license'],
        );
        dataVet.setDataUser(updated);

        _showSnackbar('บันทึกข้อมูลสำเร็จ ✓', Colors.green);
        Navigator.pop(context);
      } else {
        final body = jsonDecode(response.body);
        _showSnackbar('เกิดข้อผิดพลาด: ${body['error']}', Colors.red);
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
    final vet = Provider.of<DataVetExpert>(context).datauser;

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
                      backgroundImage: _profileImageFile != null
                          ? FileImage(_profileImageFile!) as ImageProvider
                          : (vet.profileImage.isNotEmpty
                              ? NetworkImage(vet.profileImage)
                              : const NetworkImage(
                                  'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png')),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImagePicker(true),
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

              const SizedBox(height: 20),

              // รูปใบประกอบวิชาชีพ
              _sectionLabel('รูปใบประกอบวิชาชีพ'),
              _infoCard([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: _licenseImageFile != null
                              ? FileImage(_licenseImageFile!) as ImageProvider
                              : (vet.vetExpertPl.isNotEmpty
                                  ? NetworkImage(vet.vetExpertPl)
                                      as ImageProvider
                                  : const AssetImage(
                                      'assets/images/placeholder.png')),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _licensePlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _pickImage(ImageSource.camera, false),
                              icon: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.green),
                              label: const Text('ถ่ายภาพ',
                                  style: TextStyle(color: Colors.green)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _pickImage(ImageSource.gallery, false),
                              icon: const Icon(Icons.photo_library,
                                  size: 16, color: Colors.green),
                              label: const Text('เลือกรูป',
                                  style: TextStyle(color: Colors.green)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                          width: 20,
                          height: 20,
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

  Widget _licensePlaceholder() => Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('ยังไม่มีรูปใบประกอบวิชาชีพ',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
      );

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
                  labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );
}
