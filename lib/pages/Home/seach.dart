import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Farms_response.dart';
import 'package:cow_booking/pages/Home/cows_detail.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Seachpage extends StatefulWidget {
  const Seachpage({super.key});

  @override
  State<Seachpage> createState() => _SeachpageState();
}

class _SeachpageState extends State<Seachpage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _searchText = "";
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedLocality;

  // ── Province data ──
  List provinces = [];
  List districts = [];
  List subDistricts = [];

  List<dynamic> _searchResults = [];
  bool _loading = false;
  bool _hasSearched = false;

  // ── สีหลัก ──
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
  void initState() {
    super.initState();
    fetchProvinces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> fetchProvinces() async {
    try {
      final url = Uri.parse(
        "https://raw.githubusercontent.com/kongvut/thai-province-data/refs/heads/master/api/latest/province_with_district_and_sub_district.json",
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() => provinces = jsonDecode(res.body));
      }
    } catch (_) {}
  }

  Future<void> searchBulls() async {
    _searchFocus.unfocus();
    setState(() {
      _loading = true;
      _hasSearched = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/together/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "keyword": _searchText,
          "province": selectedProvince,
          "district": selectedDistrict,
          "locality": selectedLocality,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _clearFilters() {
    setState(() {
      selectedProvince = null;
      selectedDistrict = null;
      selectedLocality = null;
      districts = [];
      subDistricts = [];
    });
    searchBulls();
  }

  bool get _hasActiveFilter =>
      selectedProvince != null ||
      selectedDistrict != null ||
      selectedLocality != null;

  // ── Province/District/Locality picker dialog ──
  Future<void> _showLocationFilter() async {
    String? tempProvince = selectedProvince;
    String? tempDistrict = selectedDistrict;
    String? tempLocality = selectedLocality;
    List tempDistricts = tempProvince != null
        ? (provinces.firstWhere((p) => p['name_th'] == tempProvince,
                orElse: () => {})['districts'] ??
            [])
        : [];
    List tempSubs = tempDistrict != null
        ? (tempDistricts.firstWhere((d) => d['name_th'] == tempDistrict,
                orElse: () => {})['sub_districts'] ??
            [])
        : [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: _green, size: 18),
                    const SizedBox(width: 8),
                    Text('กรองตามพื้นที่',
                        style: GoogleFonts.notoSansThai(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // จังหวัด
                      _modalDropdown(
                        label: 'จังหวัด',
                        value: tempProvince,
                        items: provinces,
                        onChanged: (val) {
                          setModal(() {
                            tempProvince = val;
                            tempDistrict = null;
                            tempLocality = null;
                            final p = provinces.firstWhere(
                                (p) => p['name_th'] == val,
                                orElse: () => {});
                            tempDistricts = p['districts'] ?? [];
                            tempSubs = [];
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // อำเภอ
                      _modalDropdown(
                        label: 'อำเภอ',
                        value: tempDistrict,
                        items: tempDistricts,
                        enabled: tempDistricts.isNotEmpty,
                        onChanged: (val) {
                          setModal(() {
                            tempDistrict = val;
                            tempLocality = null;
                            final d = tempDistricts.firstWhere(
                                (d) => d['name_th'] == val,
                                orElse: () => {});
                            tempSubs = d['sub_districts'] ?? [];
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // ตำบล
                      _modalDropdown(
                        label: 'ตำบล',
                        value: tempLocality,
                        items: tempSubs,
                        enabled: tempSubs.isNotEmpty,
                        onChanged: (val) => setModal(() => tempLocality = val),
                      ),
                    ],
                  ),
                ),
              ),
              // ปุ่ม
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModal(() {
                            tempProvince = null;
                            tempDistrict = null;
                            tempLocality = null;
                            tempDistricts = [];
                            tempSubs = [];
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text('ล้าง',
                            style:
                                GoogleFonts.notoSansThai(color: _labelColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            selectedProvince = tempProvince;
                            selectedDistrict = tempDistrict;
                            selectedLocality = tempLocality;
                          });
                          searchBulls();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text('ค้นหา',
                            style: GoogleFonts.notoSansThai(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalDropdown({
    required String label,
    required String? value,
    required List items,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _green, width: 1.5)),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
          ),
          hint: Text('เลือก$label',
              style:
                  GoogleFonts.notoSansThai(fontSize: 14, color: _labelColor)),
          items: items.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem(
              value: item['name_th'],
              child: Text(item['name_th'],
                  style: GoogleFonts.notoSansThai(fontSize: 14)),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }

  // ── Result card ──
  Widget _buildResultCard(dynamic bull) {
    final images = bull['images'] as List<dynamic>? ?? [];
    final firstImage = images.isNotEmpty ? images[0] : '';
    final farm = bull['farm'] as Map<String, dynamic>? ?? {};

    final characteristics = (bull['bulls_characteristics'] as String? ?? '')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () {
        final dataBull = Provider.of<DataBull>(context, listen: false);
        dataBull.setSelectedBull(FarmbullRequestResponse.fromJson(bull));
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Cowdetailpage()));
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
              child: SizedBox(
                width: 120,
                height: 148,
                child: firstImage.isNotEmpty
                    ? Image.network(firstImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/supperman.jpg',
                            fit: BoxFit.cover))
                    : Image.asset('assets/images/supperman.jpg',
                        fit: BoxFit.cover),
              ),
            ),

            // ── ข้อมูล ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อ + พันธุ์
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

                    if (bull['vet_name'] != null) ...[
                      const SizedBox(height: 3),
                      _infoPill(
                        icon: Icons.person_outline_rounded,
                        label: bull['vet_name'],
                        color:
                            const Color(0xFF6A1B9A), // สีม่วง แยกจาก pill อื่น
                        bg: const Color(0xFFF3E5F5),
                      ),
                    ],

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
                              [
                                farm['locality'],
                                farm['district'],
                                farm['province']
                              ].whereType<String>().join(', '),
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 11, color: _labelColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 5),

                    // ราคา + stock
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

                    // ลักษณะเด่น
                    if (characteristics.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: characteristics
                            .take(3)
                            .map((c) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F3F3),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: const Color(0xFFDDDDDD)),
                                  ),
                                  child: Text(c,
                                      style: GoogleFonts.notoSansThai(
                                          fontSize: 10, color: _textSecondary)),
                                ))
                            .toList(),
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
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Empty / initial state ──
  Widget _buildEmptyState() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: _border),
            const SizedBox(height: 12),
            Text('พิมพ์ชื่อพ่อพันธุ์หรือฟาร์มที่ต้องการ',
                style:
                    GoogleFonts.notoSansThai(fontSize: 14, color: _labelColor)),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: _border),
          const SizedBox(height: 12),
          Text('ไม่พบผลลัพธ์',
              style: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary)),
          const SizedBox(height: 4),
          Text('ลองเปลี่ยนคำค้นหาหรือตัวกรอง',
              style:
                  GoogleFonts.notoSansThai(fontSize: 13, color: _labelColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _green,
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
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (v) => setState(() => _searchText = v),
            onSubmitted: (_) => searchBulls(),
            style: GoogleFonts.notoSansThai(color: Colors.white, fontSize: 14),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'ค้นหาพ่อพันธุ์ ฟาร์ม...',
              hintStyle:
                  GoogleFonts.notoSansThai(color: Colors.white60, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Colors.white70, size: 20),
              suffixIcon: _searchText.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchText = '');
                      },
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white70, size: 18),
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          // ปุ่มค้นหา
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: searchBulls,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text('ค้นหา',
                  style: GoogleFonts.notoSansThai(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter bar ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // ปุ่มกรองพื้นที่
                GestureDetector(
                  onTap: _showLocationFilter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _hasActiveFilter ? _lightGreen : _pageBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _hasActiveFilter ? _green : _border,
                        width: _hasActiveFilter ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 15,
                            color: _hasActiveFilter ? _green : _labelColor),
                        const SizedBox(width: 5),
                        Text(
                          _hasActiveFilter
                              ? (selectedProvince ?? 'กรองพื้นที่')
                              : 'กรองพื้นที่',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 13,
                            color: _hasActiveFilter ? _green : _labelColor,
                            fontWeight: _hasActiveFilter
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (_hasActiveFilter) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _clearFilters,
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: _green),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ปุ่ม "ทั้งหมด" (reset)
                GestureDetector(
                  onTap: () {
                    _clearFilters();
                    _searchController.clear();
                    setState(() {
                      _searchText = '';
                      _searchResults = [];
                      _hasSearched = false;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _pageBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
                    child: Text(
                      'ล้างทั้งหมด',
                      style: GoogleFonts.notoSansThai(
                          fontSize: 13, color: _labelColor),
                    ),
                  ),
                ),

                const Spacer(),

                // จำนวนผล
                if (_hasSearched && !_loading)
                  Text(
                    '${_searchResults.length} รายการ',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 12, color: _textSecondary),
                  ),
              ],
            ),
          ),

          // divider
          const Divider(height: 1, color: Color(0xFFE8E8E8)),

          // ── Results ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _green))
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        itemCount: _searchResults.length,
                        itemBuilder: (_, i) =>
                            _buildResultCard(_searchResults[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
