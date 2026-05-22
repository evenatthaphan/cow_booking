import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/pages/farmers/see_doc_profile.dart';
import 'package:http/http.dart' as http;

class Cowdetailpage extends StatefulWidget {
  const Cowdetailpage({super.key});

  @override
  State<Cowdetailpage> createState() => _CowdetailpageState();
}

class _CowdetailpageState extends State<Cowdetailpage> {
  List<dynamic> vets = [];
  bool isLoading = true;
  bool isLiked = false;
  bool isLiking = false;

  int _currentImageIndex = 0;
  final PageController _imagePageController = PageController();

  // ── สีหลัก ──
  static const _darkGreen = Color(0xFF1B5E20);
  static const _green = Color(0xFF2E7D32);
  static const _midGreen = Color(0xFF43A047);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _border = Color(0xFFD8EDD8);
  static const _textPrimary = Color(0xFF1A2E1A);
  static const _textSecondary = Color(0xFF5A7A5A);
  static const _labelColor = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    fetchVets();
    _checkIsLiked();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _checkIsLiked() async {
    final farmerId = context.read<DataFarmers>().datauser.farmersId;
    final bullId =
        Provider.of<DataBull>(context, listen: false).selectedBull.bullId;
    if (farmerId == 0) return;
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/like_bull/farmer/$farmerId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final alreadyLiked =
            data.any((item) => item['ref_bulls_id'] == bullId);
        setState(() => isLiked = alreadyLiked);
      }
    } catch (e) {
      debugPrint('Error checking like: $e');
    }
  }

  Future<void> _toggleLike() async {
    final farmerId = context.read<DataFarmers>().datauser.farmersId;
    final bullId =
        Provider.of<DataBull>(context, listen: false).selectedBull.bullId;
    if (farmerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนกดถูกใจ')),
      );
      return;
    }
    setState(() => isLiking = true);
    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/farmer/like_bull'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'farmers_id': farmerId, 'bulls_id': bullId}),
      );
      if (response.statusCode == 201) {
        setState(() => isLiked = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มในรายการโปรดแล้ว',
                style: GoogleFonts.notoSansThai()),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (response.statusCode == 400) {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['error'] ?? 'เกิดข้อผิดพลาด',
                style: GoogleFonts.notoSansThai()),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('ไม่สามารถเชื่อมต่อได้', style: GoogleFonts.notoSansThai()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() => isLiking = false);
  }

  Future<void> fetchVets() async {
    final bull = Provider.of<DataBull>(context, listen: false).selectedBull;
    setState(() {
      isLoading = true;
      vets = [];
    });
    try {
      final response = await http
          .get(Uri.parse('$apiEndpoint/together/vet-by-bull/${bull.bullId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> listVets = [];
        if (data is List) {
          listVets = data;
        } else if (data is Map && data['vets'] is List) {
          listVets = data['vets'];
        }
        setState(() {
          vets = listVets;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ── Image gallery section ──
  Widget _buildImageGallery(bull) {
    final images = bull.images as List? ?? [];
    final hasImages = images.isNotEmpty;

    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // รูปภาพ
          hasImages
              ? PageView.builder(
                  controller: _imagePageController,
                  itemCount: images.length,
                  onPageChanged: (i) =>
                      setState(() => _currentImageIndex = i),
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/imagecow.jpg',
                        fit: BoxFit.cover),
                  ),
                )
              : Image.asset('assets/images/imagecow.jpg', fit: BoxFit.cover),

          // gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
                stops: const [0.0, 0.25, 0.55, 1.0],
              ),
            ),
          ),

          // ── ปุ่มกลับ + like ──
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: isLiking ? null : _toggleLike,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isLiked
                      ? Colors.pink.withOpacity(0.85)
                      : Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLiking
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),

          // ── ชื่อ + สายพันธุ์ ──
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bull.bullsName.isNotEmpty ? bull.bullsName : 'ไม่ทราบชื่อ',
                        style: GoogleFonts.notoSansThai(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            const Shadow(blurRadius: 8, color: Colors.black54)
                          ],
                        ),
                      ),
                      if (bull.bullsBreed.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            bull.bullsBreed,
                            style: GoogleFonts.notoSansThai(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // dot indicator
                if (hasImages && images.length > 1)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        width: 5,
                        height: _currentImageIndex == i ? 16 : 5,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == i
                              ? Colors.white
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info row helper ──
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: _midGreen),
          const SizedBox(width: 8),
          Text('$label  ',
              style: GoogleFonts.notoSansThai(
                  fontSize: 13, color: _labelColor)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    color: _textPrimary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Section header ──
  Widget _sectionHeader(String title, String? sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                  color: _green, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
          ],
        ),
        if (sub != null)
          Text(sub,
              style:
                  GoogleFonts.notoSansThai(fontSize: 12, color: _labelColor)),
      ],
    );
  }

  // ── Vet card ──
  Widget _buildVetCard(dynamic vet) {
    final vetName =
        vet['vetexperts_name']?.toString() ?? 'ไม่ระบุชื่อ';
    final province = vet['vetexperts_province'] ?? '-';
    final district = vet['vetexperts_district'] ?? '-';
    final locality = vet['vetexperts_locality'] ?? '-';
    final profileImg =
        vet['vetexperts_profile_image']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _border, width: 2),
              ),
              child: ClipOval(
                child: profileImg.isNotEmpty
                    ? Image.network(profileImg,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/profile.jpg',
                            fit: BoxFit.cover))
                    : Image.asset('assets/images/profile.jpg',
                        fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            // ข้อมูล
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vetName,
                      style: GoogleFonts.notoSansThai(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: _labelColor),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '$locality, $district, $province',
                          style: GoogleFonts.notoSansThai(
                              fontSize: 12, color: _labelColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ปุ่มดูโปรไฟล์
            GestureDetector(
              onTap: () {
                final vetId = vet['vetexperts_id'];
                if (vetId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Seedocprofilepage(
                          vetId: int.parse(vetId.toString())),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ไม่พบรหัสสัตวบาล')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: Text('ดูโปรไฟล์',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: _green,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bull = Provider.of<DataBull>(context).selectedBull;
    final traits = bull.bullsCharacteristics.isNotEmpty
        ? bull.bullsCharacteristics
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: SafeArea(
        child: Column(
          children: [
            // ── รูปภาพ ──
            _buildImageGallery(bull),

            // ── เนื้อหา ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ชื่อฟาร์ม ──
                    Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 16, color: _midGreen),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bull.farm.farmName.isNotEmpty
                                ? bull.farm.farmName
                                : 'ไม่ระบุฟาร์ม',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _green,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── ที่อยู่ฟาร์ม ──
                    if (bull.farm.province.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: _labelColor),
                          const SizedBox(width: 4),
                          Text(
                            [
                              bull.farm.locality,
                              bull.farm.district,
                              bull.farm.province
                            ]
                                .where((s) => s.isNotEmpty)
                                .join(', '),
                            style: GoogleFonts.notoSansThai(
                                fontSize: 12, color: _labelColor),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // ── ข้อมูลพ่อพันธุ์ ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          if (bull.bullsAge != null && bull.bullsAge.toString().isNotEmpty)
                            _infoRow(Icons.cake_outlined, 'อายุ',
                                '${bull.bullsAge} ปี'),
                          if (bull.contestRecords.isNotEmpty)
                            _infoRow(Icons.emoji_events_outlined,
                                'ประวัติการแข่งขัน', bull.contestRecords),
                        ],
                      ),
                    ),

                    // ── ลักษณะเด่น ──
                    if (traits.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sectionHeader('ลักษณะเด่น', null),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: traits.map((trait) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _lightGreen,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _border),
                            ),
                            child: Text(trait,
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 13, color: _green)),
                          );
                        }).toList(),
                      ),
                    ],

                    // ── สัตวบาล ──
                    const SizedBox(height: 20),
                    _sectionHeader(
                        'สัตวบาลที่มีน้ำเชื้อ',
                        isLoading ? null : 'พบ ${vets.length} ท่าน'),
                    const SizedBox(height: 12),

                    isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child:
                                  CircularProgressIndicator(color: _green),
                            ),
                          )
                        : vets.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_off_outlined,
                                        color: _labelColor, size: 18),
                                    const SizedBox(width: 8),
                                    Text('ไม่มีข้อมูลสัตวบาล',
                                        style: GoogleFonts.notoSansThai(
                                            fontSize: 14,
                                            color: _labelColor)),
                                  ],
                                ),
                              )
                            : Column(
                                children: vets
                                    .map((v) => _buildVetCard(v))
                                    .toList(),
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}