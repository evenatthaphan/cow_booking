import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/Home/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class DoctorRegis extends StatefulWidget {
  const DoctorRegis({super.key});

  @override
  State<DoctorRegis> createState() => _DoctorRegisState();
}

class _DoctorRegisState extends State<DoctorRegis> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController subdistrictCtrl = TextEditingController();

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubDistrict;

  List provinces = [];
  List districts = [];
  List subDistricts = [];

  double? selectedLat;
  double? selectedLng;

  File? _imageFile;
  String? _imageFileName;

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ── สี (เหมือนกับ FarmerRegister) ──
  static const _green = Color(0xFF2E7D32);
  static const _greenLight = Color(0xFFE8F5E9);
  static const _border = Color(0xFFDDDDDD);
  static const _labelColor = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final url = Uri.parse(
      "https://raw.githubusercontent.com/kongvut/thai-province-data/refs/heads/master/api/latest/province_with_district_and_sub_district.json",
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() => provinces = jsonDecode(res.body));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    provinceCtrl.dispose();
    districtCtrl.dispose();
    subdistrictCtrl.dispose();
    super.dispose();
  }

  // ── CAPTCHA ──

  Future<void> registerVetExpert() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      _showErrorDialog("กรุณาแนบใบประกอบวิชาชีพหรือใบรับรอง");
      return;
    }
    if (selectedLat == null) {
      _showErrorDialog("กรุณาเลือกตำแหน่งที่อยู่บนแผนที่");
      return;
    }
    await showCaptchaDialog();
  }

  Future<void> showCaptchaDialog() async {
    String? dialogCaptchaId;
    String? dialogCaptchaCode;
    TextEditingController dialogCaptchaController = TextEditingController();
    bool loading = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        Future<void> fetchCaptcha() async {
          setState(() => loading = true);
          try {
            final url = Uri.parse("$apiEndpoint/api/captcha");
            final response = await http.get(url);
            if (response.statusCode == 201) {
              final data = jsonDecode(response.body);
              setState(() {
                dialogCaptchaId = data['captchaId'];
                dialogCaptchaCode = data['captcha'];
              });
            }
          } catch (e) {
            _showErrorDialog("เกิดข้อผิดพลาด: $e");
          } finally {
            setState(() => loading = false);
          }
        }

        if (dialogCaptchaId == null) fetchCaptcha();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "ยืนยันตัวตน",
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600),
          ),
          content: loading
              ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("กรอกตัวอักษรในภาพให้ถูกต้อง",
                        style: GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            dialogCaptchaCode ?? "",
                            style: const TextStyle(
                              fontSize: 22,
                              letterSpacing: 6,
                              fontWeight: FontWeight.bold,
                              color: _green,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: fetchCaptcha,
                            icon: const Icon(Icons.refresh, color: _green, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dialogCaptchaController,
                      decoration: InputDecoration(
                        hintText: "กรอก CAPTCHA",
                        hintStyle: GoogleFonts.notoSansThai(color: _labelColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("ยกเลิก", style: GoogleFonts.notoSansThai(color: _labelColor)),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (dialogCaptchaController.text.isEmpty) return;
                      final isValid = await verifyCaptcha(
                          dialogCaptchaId!, dialogCaptchaController.text);
                      if (isValid) {
                        Navigator.of(context).pop();
                        await submitForm();
                      } else {
                        await fetchCaptcha();
                        dialogCaptchaController.clear();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("ยืนยัน", style: GoogleFonts.notoSansThai(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  Future<bool> verifyCaptcha(String captchaId, String answer) async {
    try {
      final url = Uri.parse("$apiEndpoint/api/captcha/verify");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"captchaId": captchaId, "answer": answer}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) return true;
      _showErrorDialog(data['message'] ?? "CAPTCHA ไม่ถูกต้อง");
      return false;
    } catch (e) {
      _showErrorDialog("เกิดข้อผิดพลาด: $e");
      return false;
    }
  }

  Future<void> submitForm() async {
    setState(() => isLoading = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiEndpoint/vet/register'),
      );

      request.fields['VetExpert_name'] = nameController.text.trim();
      request.fields['VetExpert_password'] = passwordController.text.trim();
      request.fields['phonenumber'] = phoneController.text.trim();
      request.fields['VetExpert_email'] = emailController.text.trim();
      request.fields['VetExpert_address'] = addressController.text.trim();
      request.fields['province'] = provinceCtrl.text.trim();
      request.fields['district'] = districtCtrl.text.trim();
      request.fields['locality'] = subdistrictCtrl.text.trim();
      if (selectedLat != null) request.fields['lat'] = selectedLat.toString();
      if (selectedLng != null) request.fields['lng'] = selectedLng.toString();

      request.files.add(
        await http.MultipartFile.fromPath('VetExpert_PL', _imageFile!.path),
      );

      final response = await request.send();
      if (response.statusCode == 201) {
        _showSuccessDialog("ระบบได้รับข้อมูลของคุณแล้ว\nกรุณารอการตรวจสอบจากผู้ดูแลก่อนเข้าใช้งาน");
      } else {
        _showErrorDialog("ลงทะเบียนไม่สำเร็จ กรุณาลองใหม่อีกครั้ง");
      }
    } catch (e) {
      _showErrorDialog("เกิดข้อผิดพลาด: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("ลงทะเบียนสำเร็จ ✓",
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.notoSansThai()),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("ตกลง", style: GoogleFonts.notoSansThai(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("เกิดข้อผิดพลาด",
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("ตกลง", style: GoogleFonts.notoSansThai(color: _green)),
          ),
        ],
      ),
    );
  }

  // ── Image Picker ──

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: _green),
              title: Text('เลือกรูปจากแกลลอรี่',
                  style: GoogleFonts.notoSansThai()),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _green),
              title: Text('ถ่ายภาพใหม่', style: GoogleFonts.notoSansThai()),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageFileName = pickedFile.name;
      });
    }
  }

  void _showFullImage() {
    if (_imageFile == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Stack(
          children: [
            Image.file(_imageFile!, fit: BoxFit.contain),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers (เหมือนกับ FarmerRegister) ──

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 8, left: 20, right: 20),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _green),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoSansThai(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _green,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: _border, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    TextInputType? keyboardType,
    bool obscure = false,
    bool? showObscureToggle,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
              if (required)
                const Text(" *", style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: GoogleFonts.notoSansThai(fontSize: 14),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _green, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: showObscureToggle == true
                  ? IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: _labelColor,
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
            ),
            validator: validator ??
                (value) {
                  if (!required) return null;
                  if (value == null || value.isEmpty) return "กรุณากรอก$label";
                  return null;
                },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List items,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
              const Text(" *", style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _green, width: 1.5),
              ),
              filled: true,
              fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
            ),
            items: items.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem(
                value: item["name_th"],
                child: Text(item["name_th"],
                    style: GoogleFonts.notoSansThai(fontSize: 14)),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: (v) => (v == null || v.isEmpty) ? "กรุณาเลือก$label" : null,
          ),
        ],
      ),
    );
  }

  /// ปุ่มเลือกพิกัด (เหมือนกับ FarmerRegister)
  Widget _buildLocationPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("ตำแหน่งที่อยู่",
                  style: GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
              const Text(" *", style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapPickerPage()),
              );
              if (result != null) {
                setState(() {
                  selectedLat = result['lat'];
                  selectedLng = result['lng'];
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: selectedLat != null ? _greenLight : Colors.white,
                border: Border.all(
                  color: selectedLat != null ? _green : _border,
                  width: selectedLat != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedLat != null
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color: selectedLat != null ? _green : _labelColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedLat != null
                          ? 'lat: ${selectedLat!.toStringAsFixed(5)},  lng: ${selectedLng!.toStringAsFixed(5)}'
                          : 'แตะเพื่อเลือกตำแหน่งบนแผนที่',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13,
                        color: selectedLat != null ? _green : _labelColor,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _labelColor, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ช่องอัพโหลดใบประกอบวิชาชีพ
  Widget _buildLicenseUploader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("ใบประกอบวิชาชีพ / ใบรับรอง",
                  style: GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
              const Text(" *", style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _showImageSourceOptions,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: _imageFile != null ? _greenLight : Colors.white,
                border: Border.all(
                  color: _imageFile != null ? _green : _border,
                  width: _imageFile != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file_outlined,
                            size: 32, color: _labelColor),
                        const SizedBox(height: 6),
                        Text("แตะเพื่อเลือกหรือถ่ายภาพ",
                            style: GoogleFonts.notoSansThai(
                                fontSize: 13, color: _labelColor)),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: GestureDetector(
                            onTap: _showFullImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.fullscreen,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (_imageFileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined,
                      size: 14, color: _green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _imageFileName!,
                      style: GoogleFonts.notoSansThai(
                          fontSize: 12, color: _green),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _imageFile = null;
                      _imageFileName = null;
                    }),
                    child: const Icon(Icons.close, size: 14, color: _labelColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'ลงทะเบียนสัตวบาล',
          style: GoogleFonts.notoSansThai(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── ข้อมูลบัญชี ──
              _sectionHeader("ข้อมูลบัญชี", Icons.person_outline),
              _buildField(
                  label: "ชื่อผู้ใช้",
                  controller: nameController,
                  required: true),
              _buildField(
                  label: "เบอร์โทรศัพท์",
                  controller: phoneController,
                  required: true,
                  keyboardType: TextInputType.phone),
              _buildField(
                  label: "อีเมล",
                  controller: emailController,
                  required: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "กรุณากรอกอีเมล";
                    if (!v.contains('@')) return "รูปแบบอีเมลไม่ถูกต้อง";
                    return null;
                  }),

              // ── ที่อยู่ ──
              _sectionHeader("ที่อยู่", Icons.home_outlined),
              _buildDropdown(
                label: "จังหวัด",
                value: selectedProvince,
                items: provinces,
                onChanged: (val) {
                  setState(() {
                    selectedProvince = val;
                    provinceCtrl.text = val ?? '';
                    selectedDistrict = null;
                    selectedSubDistrict = null;
                    final p = provinces.firstWhere(
                        (p) => p["name_th"] == val, orElse: () => {});
                    districts = p["districts"] ?? [];
                    subDistricts = [];
                  });
                },
              ),
              _buildDropdown(
                label: "อำเภอ",
                value: selectedDistrict,
                items: districts,
                enabled: districts.isNotEmpty,
                onChanged: (val) {
                  setState(() {
                    selectedDistrict = val;
                    districtCtrl.text = val ?? '';
                    selectedSubDistrict = null;
                    final d = districts.firstWhere(
                        (d) => d["name_th"] == val, orElse: () => {});
                    subDistricts = d["sub_districts"] ?? [];
                  });
                },
              ),
              _buildDropdown(
                label: "ตำบล",
                value: selectedSubDistrict,
                items: subDistricts,
                enabled: subDistricts.isNotEmpty,
                onChanged: (val) {
                  setState(() {
                    selectedSubDistrict = val;
                    subdistrictCtrl.text = val ?? '';
                  });
                },
              ),
              _buildLocationPicker(),
              _buildField(
                  label: "ที่อยู่เพิ่มเติม",
                  controller: addressController,
                  required: true),

              // ── เอกสาร ──
              _sectionHeader("เอกสารประกอบ", Icons.badge_outlined),
              _buildLicenseUploader(),

              // ── รหัสผ่าน ──
              _sectionHeader("รหัสผ่าน", Icons.lock_outline),
              _buildField(
                label: "รหัสผ่าน",
                controller: passwordController,
                required: true,
                obscure: _obscurePassword,
                showObscureToggle: true,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              _buildField(
                label: "ยืนยันรหัสผ่าน",
                controller: confirmPasswordController,
                required: true,
                obscure: _obscureConfirm,
                showObscureToggle: true,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return "กรุณายืนยันรหัสผ่าน";
                  if (v != passwordController.text) return "รหัสผ่านไม่ตรงกัน";
                  return null;
                },
              ),

              // ── หมายเหตุ ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Color(0xFFF9A825)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "หลังลงทะเบียน ระบบจะรอการตรวจสอบจากผู้ดูแลก่อนอนุมัติบัญชี",
                          style: GoogleFonts.notoSansThai(
                              fontSize: 12, color: const Color(0xFF795548)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── ปุ่มลงทะเบียน ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerVetExpert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'ลงทะเบียน',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}