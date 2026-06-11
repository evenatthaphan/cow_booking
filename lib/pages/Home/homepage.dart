import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Farms_response.dart';
import 'package:cow_booking/pages/Home/cows_detail.dart';
import 'package:cow_booking/pages/Home/seach.dart';
import 'package:cow_booking/pages/Home/seeall.dart';
import 'package:cow_booking/pages/farmers/farmer_navbar.dart';
import 'package:cow_booking/pages/farmers/farmer_profile.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

/// หน้าหลัก — ไม่มีลูกศรกลับ และเป็น root ของ stack
/// ทุกที่ที่ navigate มาหน้านี้ให้ใช้:
///   Navigator.pushAndRemoveUntil(
///     context,
///     MaterialPageRoute(builder: (_) => Homepage()),
///     (route) => false,
///   );
class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PageController _pageController = PageController(viewportFraction: 0.82);
  double _currentPage = 0.0;

  List<dynamic> topBulls = [];
  Map<String, List<dynamic>> bullGroups = {};

  // ── สีหลัก ──
  static const _darkGreen = Color(0xFF1B5E20);
  static const _green = Color(0xFF2E7D32);
  static const _midGreen = Color(0xFF43A047);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _accent = Color(0xFF00C853);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _pageBg = Color(0xFFF1F8F1);
  static const _textPrimary = Color(0xFF1A2E1A);
  static const _textSecondary = Color(0xFF5A7A5A);
  static const _border = Color(0xFFD8EDD8);

  Future<void> fetchTopBulls() async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/stats/insemination/top-bulls'),
      );
      if (response.statusCode == 200) {
        setState(() => topBulls = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching top bulls: $e');
    }
  }

  Future<void> fetchBulls() async {
    try {
      final response = await http.get(Uri.parse("$apiEndpoint/bull/getbull"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => bullGroups = Map<String, List<dynamic>>.from(data));
      }
    } catch (e) {
      debugPrint("Error fetching bulls: $e");
    }
  }

  String _normalizeProfileImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$apiEndpoint/$url';
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page!);
    });
    fetchBulls();
    fetchTopBulls();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Top Bull Card (PageView) ──
  Widget _buildTopBullCard(int index) {
    final bull = topBulls[index];
    final imageUrl = bull['bulls_image'] ?? '';
    final diff = (_currentPage - index).abs();
    final isCenter = diff < 0.5;
    final scale = isCenter ? 1.0 : (1.0 - (diff * 0.12).clamp(0.0, 0.12));

    final rankColors = [
      const Color(0xFFFFC107), // gold
      const Color(0xFF90A4AE), // silver
      const Color(0xFFBF8970), // bronze
    ];
    final rankLabels = ['🥇 อันดับ 1', '🥈 อันดับ 2', '🥉 อันดับ 3'];
    final rankGradients = [
      [const Color(0xFFFFD54F), const Color(0xFFFFA000)],
      [const Color(0xFFB0BEC5), const Color(0xFF78909C)],
      [const Color(0xFFBCAAA4), const Color(0xFF8D6E63)],
    ];

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: GestureDetector(
          onTap: () {
            final dataBull = Provider.of<DataBull>(context, listen: false);
            dataBull.setSelectedBull(FarmbullRequestResponse.fromJson(bull));
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Cowdetailpage()));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _green.withOpacity(isCenter ? 0.25 : 0.10),
                  blurRadius: isCenter ? 20 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── รูปพ่อพันธุ์ ──
                  imageUrl.isNotEmpty
                      ? Image.network(imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/imagecow.jpg',
                              fit: BoxFit.cover))
                      : Image.asset('assets/images/imagecow.jpg',
                          fit: BoxFit.cover),

                  // ── gradient overlay ──
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.65),
                        ],
                        stops: const [0.4, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // ── rank badge ──
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: rankGradients[index % 3],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: rankColors[index % 3].withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        rankLabels[index % 3],
                        style: GoogleFonts.notoSansThai(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // ── success rate badge ──
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _accent.withOpacity(0.6), width: 1),
                      ),
                      child: Text(
                        '✅ ${bull['success_rate']}%',
                        style: const TextStyle(
                          color: Color(0xFF69F0AE),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // ── ชื่อ + ฟาร์ม ──
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bull['bulls_name'] ?? '-',
                          style: GoogleFonts.notoSansThai(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            shadows: [
                              const Shadow(blurRadius: 6, color: Colors.black54)
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (bull['farm_name'] != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: Colors.white70),
                              const SizedBox(width: 3),
                              Text(
                                bull['farm_name'],
                                style: GoogleFonts.notoSansThai(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bull Card (horizontal list) ──
  Widget _buildBullCard(dynamic bull) {
    final bullImages = bull['images'] as List<dynamic>? ?? [];
    final firstImage = bullImages.isNotEmpty ? bullImages[0] : '';

    return GestureDetector(
      onTap: () {
        final dataBull = Provider.of<DataBull>(context, listen: false);
        dataBull.setSelectedBull(FarmbullRequestResponse.fromJson(bull));
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Cowdetailpage()));
      },
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูป
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 105,
                    width: double.infinity,
                    child: firstImage.isNotEmpty
                        ? Image.network(firstImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/supperman.jpg',
                                fit: BoxFit.cover))
                        : Image.asset('assets/images/supperman.jpg',
                            fit: BoxFit.cover),
                  ),
                  // subtle gradient ด้านล่างรูป
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.18)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ข้อมูล
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bull['bulls_name'] ?? '',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.store_outlined, size: 11, color: _midGreen),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          bull['farm']?['farm_name'] ?? '',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header พร้อม "ดูทั้งหมด" ──
  Widget _buildSectionHeader(String breed, List<dynamic> bulls) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'พ่อพันธุ์$breed',
                style: GoogleFonts.notoSansThai(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SeeallPage(breed: breed, bulls: bulls)),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _green,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _green.withOpacity(0.3)),
              ),
            ),
            child: Text(
              'ดูทั้งหมด',
              style: GoogleFonts.notoSansThai(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bull section (header + horizontal scroll) ──
  Widget _buildBullSection(String breed, List<dynamic> bulls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(breed, bulls),
          SizedBox(
            height: 185,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemCount: bulls.length,
              itemBuilder: (_, i) => _buildBullCard(bulls[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero / Top Bulls section label ──
  Widget _buildTopBullsLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _darkGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สุดยอดพ่อพันธุ์',
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Text(
                'จัดอันดับจากอัตราสำเร็จการผสม',
                style: GoogleFonts.notoSansThai(
                    fontSize: 12, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Page dots indicator ──
  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(topBulls.length, (i) {
        final active = (_currentPage.round() == i);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? _green : _border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bulls label ──
            _buildTopBullsLabel(),
            const SizedBox(height: 16),

            // ── PageView ──
            SizedBox(
              height: 260,
              child: topBulls.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: topBulls.length,
                      itemBuilder: (_, i) => _buildTopBullCard(i),
                    ),
            ),

            // ── dots ──
            if (topBulls.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildPageDots(),
            ],

            const SizedBox(height: 28),

            // ── Divider label for breed sections ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'พ่อพันธุ์แยกตามสายพันธุ์',
                      style: GoogleFonts.notoSansThai(
                          fontSize: 13, color: _textSecondary),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),

            // ── Bull sections ──
            if (bullGroups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...bullGroups.entries
                  .map((e) => _buildBullSection(e.key, e.value)),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: FarmerNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (value) {},
        screenSize: screenSize,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _green,
      automaticallyImplyLeading: false,
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
                'หน้าหลัก',
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
      actions: [
        // Search button
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, size: 22),
            color: Colors.white,
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Seachpage())),
          ),
        ),
        // Profile avatar
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Farmerprofilepage())),
            child: Consumer<DataFarmers>(
              builder: (context, dataFarmer, _) {
                final imageUrl = _normalizeProfileImageUrl(
                    dataFarmer.datauser.farmersProfileImage);
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: imageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              imageUrl,
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          )
                        : const Icon(Icons.person_rounded,
                            color: Colors.white, size: 18),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }

  void taptoseach() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const Seachpage()));
  }

  void detailpage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const Cowdetailpage()));
  }

  ImageProvider _profileImage(String url) {
    if (url.isEmpty) {
      return const NetworkImage(
          'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png');
    }
    // ✅ เพิ่ม timestamp ทำให้ Flutter มองว่าเป็น URL ใหม่ทุกครั้ง
    final busted = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    return NetworkImage(busted);
  }
}
