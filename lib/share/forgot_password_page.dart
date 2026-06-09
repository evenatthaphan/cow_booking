import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 1;
  bool _loading = false;

  final _phoneController       = TextEditingController();
  final _otpController         = TextEditingController();
  final _newPassController     = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  // Firebase
  final _auth = FirebaseAuth.instance;
  String? _verificationId;

  // ---- Step 1: ส่ง OTP ผ่าน Firebase ----
  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('กรุณากรอกเบอร์โทรศัพท์');
      return;
    }

    // แปลงเบอร์ไทย 0812345678 → +66812345678
    final e164 = '+66${phone.replaceFirst(RegExp(r'^0'), '')}';

    setState(() => _loading = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: e164,
        timeout: const Duration(seconds: 60),

        // SMS ส่งสำเร็จ
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _step = 2;
            _loading = false;
          });
        },

        // Auto verify (บางเครื่อง Android ดึง OTP อัตโนมัติ)
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },

        verificationCompleted: (credential) async {
          // Auto-fill OTP บนบางเครื่อง
          final otp = credential.smsCode;
          if (otp != null) {
            _otpController.text = otp;
          }
        },

        verificationFailed: (e) {
          if (!mounted) return;
          setState(() => _loading = false);
          _showError('ส่ง OTP ไม่สำเร็จ: ${e.message}');
        },
      );
    } catch (e) {
      setState(() => _loading = false);
      _showError('เกิดข้อผิดพลาด: $e');
    }
  }

  // ---- Step 2: ยืนยัน OTP ----
  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('OTP ต้องเป็นตัวเลข 6 หลัก');
      return;
    }
    if (_verificationId == null) {
      _showError('ไม่พบ verification ID กรุณาขอ OTP ใหม่');
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // ยืนยันกับ Firebase
      await _auth.signInWithCredential(credential);

      if (!mounted) return;
      setState(() {
        _step = 3;
        _loading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      if (e.code == 'invalid-verification-code') {
        _showError('OTP ไม่ถูกต้อง กรุณาลองใหม่');
      } else {
        _showError('เกิดข้อผิดพลาด: ${e.message}');
      }
    }
  }

  // ---- Step 3: Reset Password ในฐานข้อมูล ----
  Future<void> _resetPassword() async {
    final newPass     = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();
    final phone       = _phoneController.text.trim();

    if (newPass.length < 8) {
      _showError('รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร');
      return;
    }
    if (newPass != confirmPass) {
      _showError('รหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$apiEndpoint/reset-password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'newPassword': newPass,
        }),
      );

      final data = jsonDecode(res.body);
      if (!mounted) return;
      setState(() => _loading = false);

      if (res.statusCode == 200 && data['success'] == true) {
        // Sign out Firebase หลังเปลี่ยนรหัสสำเร็จ
        await _auth.signOut();

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('สำเร็จ'),
            content: const Text('เปลี่ยนรหัสผ่านสำเร็จแล้ว'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // กลับหน้า login
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      } else {
        _showError(data['error'] ?? 'ไม่สามารถเปลี่ยนรหัสผ่านได้');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('ลืมรหัสผ่าน',
            style: GoogleFonts.notoSansThai(
                fontWeight: FontWeight.bold, color: Colors.green[900])),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 40),
            if (_step == 1) _buildStep1(),
            if (_step == 2) _buildStep2(),
            if (_step == 3) _buildStep3(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final active = (i + 1) <= _step;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active ? Colors.green[700] : Colors.grey[300],
                child: Text('${i + 1}',
                    style: TextStyle(
                        color: active ? Colors.white : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              if (i < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: (i + 1) < _step ? Colors.green[700] : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('กรอกเบอร์โทรศัพท์',
            style: GoogleFonts.notoSansThai(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[900])),
        const SizedBox(height: 8),
        Text('ระบบจะส่งรหัส OTP ไปยัง SMS ของคุณ',
            style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 30),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration('เบอร์โทรศัพท์', Icons.phone),
        ),
        const SizedBox(height: 30),
        _buildButton('ส่ง OTP', _sendOTP),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('กรอกรหัส OTP',
            style: GoogleFonts.notoSansThai(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[900])),
        const SizedBox(height: 8),
        Text('รหัส 6 หลักถูกส่งไปยัง ${_phoneController.text}',
            style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 30),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: _inputDecoration('รหัส OTP', Icons.lock_clock),
        ),
        Center(
          child: TextButton(
            onPressed: _loading ? null : () => setState(() => _step = 1),
            child: Text('ไม่ได้รับ OTP? ขอใหม่',
                style: GoogleFonts.notoSansThai(color: Colors.green[700])),
          ),
        ),
        const SizedBox(height: 14),
        _buildButton('ยืนยัน OTP', _verifyOTP),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ตั้งรหัสผ่านใหม่',
            style: GoogleFonts.notoSansThai(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[900])),
        const SizedBox(height: 8),
        Text('รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร',
            style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 30),
        TextField(
          controller: _newPassController,
          obscureText: _obscureNew,
          decoration: _inputDecorationSuffix(
            'รหัสผ่านใหม่', Icons.lock_outline, _obscureNew,
            () => setState(() => _obscureNew = !_obscureNew),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmPassController,
          obscureText: _obscureConfirm,
          decoration: _inputDecorationSuffix(
            'ยืนยันรหัสผ่านใหม่', Icons.lock, _obscureConfirm,
            () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        const SizedBox(height: 30),
        _buildButton('เปลี่ยนรหัสผ่าน', _resetPassword),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.notoSansThai(),
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
      ),
    );
  }

  InputDecoration _inputDecorationSuffix(
      String label, IconData icon, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.notoSansThai(),
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
        onPressed: toggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(label,
                style: GoogleFonts.notoSansThai(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}