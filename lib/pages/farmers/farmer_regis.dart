import 'package:cow_booking/pages/Home/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/recaptcha_stub.dart'
    if (dart.library.html) 'recaptcha_web.dart';

class FarmerRegister extends StatefulWidget {
  const FarmerRegister({super.key});

  @override
  State<FarmerRegister> createState() => _FarmerRegisterState();
}

class _FarmerRegisterState extends State<FarmerRegister> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController farmNameController        = TextEditingController();
  final TextEditingController phoneNumberController     = TextEditingController();
  final TextEditingController emailController           = TextEditingController();
  final TextEditingController farmAddressController     = TextEditingController();
  final TextEditingController passwordController        = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // ── ข้อมูลจากแผนที่ ──
  double? selectedLat;
  double? selectedLng;
  String  selectedProvince    = '';
  String  selectedDistrict    = '';
  String  selectedSubDistrict = '';

  bool isLoading        = false;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  // ── สี ──
  static const _green      = Color(0xFF2E7D32);
  static const _greenLight = Color(0xFFE8F5E9);
  static const _border     = Color(0xFFDDDDDD);
  static const _labelColor = Color(0xFF757575);

  static const _googleApiKey = 'YOUR_GOOGLE_API_KEY';

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
                'ลงทะเบียนเกษตรกรใหม่',
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
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  @override
  void dispose() {
    farmNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    farmAddressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── เปิด MapPickerPage ───────────────────────────────────────────────────
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          googleApiKey: _googleApiKey,
          initialLat: selectedLat,
          initialLng: selectedLng,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLat         = result.lat;
        selectedLng         = result.lng;
        selectedProvince    = result.province;
        selectedDistrict    = result.district;
        selectedSubDistrict = result.subDistrict;
        if (farmAddressController.text.isEmpty && result.addressDetail.isNotEmpty) {
          farmAddressController.text = result.addressDetail;
        }
      });
    }
  }

  // ─── register ─────────────────────────────────────────────────────────────
  Future<void> registerFarmer() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedLat == null) {
      _showErrorDialog("กรุณาเลือกตำแหน่งฟาร์มบนแผนที่");
      return;
    }
    // ไม่ต้องเช็ครหัสผ่านซ้ำที่นี่ เพราะ validator จัดการแล้ว
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
                dialogCaptchaId   = data['captchaId'];
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
          title: Text("ยืนยันตัวตน",
              style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
          content: loading
              ? const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("กรอกตัวอักษรในภาพให้ถูกต้อง",
                        style: GoogleFonts.notoSansThai(
                            fontSize: 13, color: _labelColor)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
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
                            icon: const Icon(Icons.refresh,
                                color: _green, size: 20),
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
                        hintStyle:
                            GoogleFonts.notoSansThai(color: _labelColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("ยกเลิก",
                  style: GoogleFonts.notoSansThai(color: _labelColor)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("ยืนยัน",
                  style: GoogleFonts.notoSansThai(color: Colors.white)),
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
      final url = Uri.parse("$apiEndpoint/farmer/register");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode({
          "farm_name":    farmNameController.text.trim(),
          "phonenumber":  phoneNumberController.text.trim(),
          "farmer_email": emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
          "farm_password": passwordController.text.trim(),
          "farm_address":  farmAddressController.text.trim(),
          "province":      selectedProvince,
          "district":      selectedDistrict,
          "locality":      selectedSubDistrict,
          "lat":           selectedLat,
          "lng":           selectedLng,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog(
            jsonDecode(response.body)['message'] ?? "ลงทะเบียนสำเร็จ");
      } else {
        _showErrorDialog(
            jsonDecode(response.body)['error'] ?? "เกิดข้อผิดพลาด");
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
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("สำเร็จ ✓",
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.notoSansThai()),
        actions: [
          ElevatedButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("ตกลง",
                style: GoogleFonts.notoSansThai(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("เกิดข้อผิดพลาด",
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text("ตกลง", style: GoogleFonts.notoSansThai(color: _green)),
          ),
        ],
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

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
    List<TextInputFormatter>? inputFormatters,
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
                  style: GoogleFonts.notoSansThai(
                      fontSize: 13, color: _labelColor)),
              if (required)
                const Text(" *",
                    style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            inputFormatters: inputFormatters,
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
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
                  if (value == null || value.trim().isEmpty) return "กรุณากรอก$label";
                  return null;
                },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    final hasPicked = selectedLat != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("ตำแหน่งฟาร์ม",
                  style: GoogleFonts.notoSansThai(
                      fontSize: 13, color: _labelColor)),
              const Text(" *",
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),

          GestureDetector(
            onTap: _openMapPicker,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: hasPicked ? _greenLight : Colors.white,
                border: Border.all(
                  color: hasPicked ? _green : _border,
                  width: hasPicked ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    hasPicked
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color: hasPicked ? _green : _labelColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hasPicked
                          ? 'lat: ${selectedLat!.toStringAsFixed(5)},  lng: ${selectedLng!.toStringAsFixed(5)}'
                          : 'แตะเพื่อค้นหาหรือเลือกตำแหน่งบนแผนที่',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13,
                        color: hasPicked ? _green : _labelColor,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _labelColor, size: 18),
                ],
              ),
            ),
          ),

          if (hasPicked) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _greenLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _addressRow('จังหวัด', selectedProvince),
                  _addressRow('อำเภอ',   selectedDistrict),
                  _addressRow('ตำบล',    selectedSubDistrict),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text('$label:',
                style: GoogleFonts.notoSansThai(
                    fontSize: 12, color: _labelColor)),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: GoogleFonts.notoSansThai(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: value.isNotEmpty ? Colors.black87 : Colors.grey,
              ),
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
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Banner ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco_outlined, size: 16, color: _green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "กรอกข้อมูลให้ครบถ้วนเพื่อเข้าใช้งานระบบการจองคิวผสมเทียม",
                          style: GoogleFonts.notoSansThai(
                              fontSize: 12, color: _green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── ข้อมูลบัญชี ──
              _sectionHeader("ข้อมูลบัญชี", Icons.person_outline),

              // ชื่อผู้ใช้
              _buildField(
                label: "ชื่อผู้ใช้",
                controller: farmNameController,
                required: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'กรุณากรอกชื่อผู้ใช้';
                  return null;
                },
              ),

              // เบอร์โทรศัพท์ — ตัวเลขเท่านั้น, 9-10 หลัก
              _buildField(
                label: "เบอร์โทรศัพท์",
                controller: phoneNumberController,
                required: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
                  if (v.length < 9) return 'เบอร์โทรต้องมี 9-10 หลัก';
                  return null;
                },
              ),

              // อีเมล — ไม่บังคับ แต่ถ้ากรอกต้องถูกรูปแบบ
              _buildField(
                label: "อีเมล",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final emailRegex =
                      RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'รูปแบบอีเมลไม่ถูกต้อง';
                  }
                  return null;
                },
              ),

              // ── ที่อยู่ฟาร์ม ──
              _sectionHeader("ที่อยู่ฟาร์ม", Icons.home_outlined),
              _buildLocationPicker(),
              _buildField(
                label: "ที่อยู่เพิ่มเติม",
                controller: farmAddressController,
                required: true,
              ),

              // ── รหัสผ่าน ──
              _sectionHeader("รหัสผ่าน", Icons.lock_outline),

              // รหัสผ่าน — อย่างน้อย 8 ตัว
              _buildField(
                label: "รหัสผ่าน",
                controller: passwordController,
                required: true,
                obscure: _obscurePassword,
                showObscureToggle: true,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                  if (v.length < 8) return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                  return null;
                },
              ),

              // ยืนยันรหัสผ่าน
              _buildField(
                label: "ยืนยันรหัสผ่าน",
                controller: confirmPasswordController,
                required: true,
                obscure: _obscureConfirm,
                showObscureToggle: true,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                  if (v != passwordController.text) return 'รหัสผ่านไม่ตรงกัน';
                  return null;
                },
              ),

              // ── ปุ่มลงทะเบียน ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerFarmer,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
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