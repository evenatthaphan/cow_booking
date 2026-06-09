import 'dart:convert';
import 'dart:ui'; // Required for BackdropFilter and ImageFilter
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cow_booking/model/response/allerrorresponse.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class MyWidget {
  void showCustomSnackbar(String title, String msgValue) {
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor:
          Colors.transparent, // Transparent to allow the blur to show
      duration: const Duration(seconds: 2),
      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msgValue,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HandleError {
  MyWidget myWidget = MyWidget();
  void handleError(http.Response response) {
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    if (jsonResponse is Map<String, dynamic>) {
      final msgValue = jsonResponse['msg'];
      if (msgValue is String) {
        myWidget.showCustomSnackbar('Message', msgValue);
      } else if (msgValue is Map<String, dynamic>) {
        try {
          final msg = allerrorresponsegetFromJson(jsonEncode(msgValue));
          myWidget.showCustomSnackbar('Message', msg.toString());
        } catch (e) {
          myWidget.showCustomSnackbar('Message', 'Error parsing "msg": $e');
        }
      }
    } else {
      myWidget.showCustomSnackbar('Error', 'Unexpected response format');
    }
  }
}

/// ฟังก์ชันหลักตรวจสอบความปลอดภัยด้วย Slider Captcha แบบ Native Flutter
Future<String?> verifySecurity(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => const _SliderCaptchaDialog(),
  );
}

// ─────────────────────────────────────────────────────────────
//  Slider Captcha Dialog (Native Flutter — ไม่ต้องพึ่ง WebView)
// ─────────────────────────────────────────────────────────────

class _SliderCaptchaDialog extends StatefulWidget {
  const _SliderCaptchaDialog();

  @override
  State<_SliderCaptchaDialog> createState() => _SliderCaptchaDialogState();
}

class _SliderCaptchaDialogState extends State<_SliderCaptchaDialog>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _verified = false;
  bool _dragging = false;

  late AnimationController _successController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _onVerified() {
    setState(() => _verified = true);
    _successController.forward();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.of(context)
            .pop('verified_${DateTime.now().millisecondsSinceEpoch}');
      }
    });
  }

  void _resetSlider() {
    if (_verified) return;
    setState(() {
      _progress = 0.0;
      _dragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      elevation: 24,
      child: Container(
        width: 320,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[900]!, Colors.green[700]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'การตรวจสอบความปลอดภัย',
              style: GoogleFonts.notoSansThai(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        children: [
          // ─── Icon Section ───
          AnimatedBuilder(
            animation: _successController,
            builder: (_, __) => Transform.scale(
              scale: _verified ? 0.85 + 0.15 * _scaleAnim.value : 1.0,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _verified ? Colors.green[50] : Colors.grey[100],
                  border: Border.all(
                    color: _verified ? Colors.green[300]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _verified ? Icons.check_circle_rounded : Icons.shield_outlined,
                  size: 42,
                  color: _verified ? Colors.green[600] : Colors.grey[500],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ─── Label ───
          AnimatedBuilder(
            animation: _successController,
            builder: (_, __) => FadeTransition(
              opacity: _verified ? _fadeAnim : const AlwaysStoppedAnimation(1),
              child: Text(
                _verified ? 'ยืนยันตัวตนสำเร็จ! ✓' : 'เลื่อนแถบไปทางขวาเพื่อยืนยัน',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _verified ? Colors.green[700] : Colors.grey[700],
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          if (!_verified)
            Text(
              'ลากปุ่ม  ›  ไปจนสุดขวา',
              style: GoogleFonts.notoSansThai(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),

          const SizedBox(height: 22),

          // ─── Slider ───
          _buildSlider(),

          const SizedBox(height: 16),

          // ─── Footer note ───
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'ระบบป้องกันการเข้าถึงโดยอัตโนมัติ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    const thumbSize = 52.0;
    const trackHeight = 52.0;

    return LayoutBuilder(builder: (context, constraints) {
      final trackWidth = constraints.maxWidth;
      final maxOffset = trackWidth - thumbSize;
      final thumbOffset = (_progress * maxOffset).clamp(0.0, maxOffset);

      return Container(
        width: trackWidth,
        height: trackHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(trackHeight / 2),
          color: _verified ? Colors.green[50] : Colors.grey[100],
          border: Border.all(
            color: _verified ? Colors.green[400]! : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Fill bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: thumbOffset + thumbSize,
              height: trackHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackHeight / 2),
                gradient: LinearGradient(
                  colors: _verified
                      ? [Colors.green[500]!, Colors.green[700]!]
                      : [Colors.green[200]!, Colors.green[300]!],
                ),
              ),
            ),

            // Center text (only when not dragging and not verified)
            if (!_verified && !_dragging && _progress < 0.1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: thumbSize),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        Icon(Icons.chevron_right_rounded,
                            size: 20, color: Colors.grey[400]),
                      ],
                      Text(
                        ' เลื่อนเพื่อยืนยัน',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_verified)
              Center(
                child: Text(
                  '✓  ยืนยันแล้ว',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            // Thumb button
            Positioned(
              left: thumbOffset,
              top: 0,
              child: GestureDetector(
                onHorizontalDragStart: (_) {
                  if (_verified) return;
                  setState(() => _dragging = true);
                },
                onHorizontalDragUpdate: (details) {
                  if (_verified) return;
                  setState(() {
                    final newProgress =
                        (_progress + details.delta.dx / maxOffset)
                            .clamp(0.0, 1.0);
                    _progress = newProgress;
                  });
                  if (_progress >= 0.95) _onVerified();
                },
                onHorizontalDragEnd: (_) => _resetSlider(),
                onHorizontalDragCancel: () => _resetSlider(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _verified ? Colors.green[600] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: (_dragging ? Colors.green : Colors.black)
                            .withOpacity(_dragging ? 0.25 : 0.15),
                        blurRadius: _dragging ? 12 : 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _verified
                        ? Icons.check_rounded
                        : Icons.arrow_forward_ios_rounded,
                    color: _verified ? Colors.white : Colors.green[700],
                    size: _verified ? 26 : 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}