import 'package:cow_booking/model/response/Farms_response.dart';
import 'package:cow_booking/pages/Home/cows_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cow_booking/pages/Home/seach.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/share/share_data.dart';

class SeeallPage extends StatefulWidget {
  final String breed;
  final List<dynamic> bulls;

  const SeeallPage({
    super.key,
    required this.breed,
    required this.bulls,
  });

  @override
  State<SeeallPage> createState() => _SeeallPageState();
}

class _SeeallPageState extends State<SeeallPage> {
  // ── สีหลัก (เหมือนกันทั้งแอป) ──
  static const _darkGreen = Color(0xFF1B5E20);
  static const _green = Color(0xFF2E7D32);
  static const _midGreen = Color(0xFF43A047);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _pageBg = Color(0xFFF1F8F1);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _border = Color(0xFFD8EDD8);
  static const _textPrimary = Color(0xFF1A2E1A);
  static const _textSecondary = Color(0xFF5A7A5A);
  static const _labelColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── summary bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'พ่อพันธุ์${widget.breed}',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                  ),
                  child: Text(
                    '${widget.bulls.length} รายการ',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: _green,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),

          // ── list ──
          Expanded(
            child: widget.bulls.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 24),
                    itemCount: widget.bulls.length,
                    itemBuilder: (_, i) => _buildCard(widget.bulls[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Card ──
  Widget _buildCard(dynamic bull) {
    final bullImages = bull['images'] as List<dynamic>? ?? [];
    final firstImage = bullImages.isNotEmpty ? bullImages[0] : '';
    final farm = bull['farm'] as Map<String, dynamic>? ?? {};
    final traits = (bull['bulls_characteristics'] as String? ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () {
        final dataBull = Provider.of<DataBull>(context, listen: false);
        dataBull.setSelectedBull(FarmbullRequestResponse.fromJson(bull));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Cowdetailpage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _green.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── รูป ──
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(13)),
              child: Stack(
                children: [
                  SizedBox(
                    width: 115,
                    height: 145,
                    child: firstImage.isNotEmpty
                        ? Image.network(
                            firstImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/supperman.jpg',
                                fit: BoxFit.cover),
                          )
                        : Image.asset('assets/images/supperman.jpg',
                            fit: BoxFit.cover),
                  ),
                  // gradient bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.22),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── ข้อมูล ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อ + badge พันธุ์
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            bull['bulls_name'] ?? '',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (bull['bulls_breed'] != null)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _lightGreen,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _border),
                            ),
                            child: Text(
                              bull['bulls_breed'],
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 10,
                                  color: _green,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ฟาร์ม
                    Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 12, color: _midGreen),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            farm['farm_name'] ?? '',
                            style: GoogleFonts.notoSansThai(
                                fontSize: 12, color: _textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // พื้นที่
                    if (farm['province'] != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: _labelColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [farm['locality'], farm['district'], farm['province']]
                                  .whereType<String>()
                                  .where((s) => s.isNotEmpty)
                                  .join(', '),
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 11, color: _labelColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ราคา + stock
                    if (bull['price_per_dose'] != null ||
                        bull['semen_stock'] != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (bull['price_per_dose'] != null)
                            _infoPill(
                              icon: Icons.monetization_on_outlined,
                              label: '฿${bull['price_per_dose']}',
                              color: const Color(0xFF1565C0),
                              bg: const Color(0xFFE3F2FD),
                            ),
                          if (bull['price_per_dose'] != null &&
                              bull['semen_stock'] != null)
                            const SizedBox(width: 6),
                          if (bull['semen_stock'] != null)
                            _infoPill(
                              icon: Icons.science_outlined,
                              label: 'สต็อก ${bull['semen_stock']}',
                              color: _green,
                              bg: _lightGreen,
                            ),
                        ],
                      ),
                    ],

                    // ลักษณะเด่น
                    if (traits.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: traits.take(3).map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFDDDDDD)),
                            ),
                            child: Text(t,
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 10, color: _textSecondary)),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.notoSansThai(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: _border),
          const SizedBox(height: 12),
          Text('ไม่มีข้อมูลพ่อพันธุ์',
              style: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary)),
        ],
      ),
    );
  }

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
            colors: [_darkGreen, _midGreen],
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
                'ดูทั้งหมด · ${widget.breed}',
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
        Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, size: 22),
            color: Colors.white,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Seachpage())),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
      ),
    );
  }
}