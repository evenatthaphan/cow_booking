import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cow_booking/share/ShareData.dart';
// TODO: แก้ path ให้ตรงกับที่วาง model จริง
import 'package:cow_booking/model/response/getfevbull_farmer.dart';
import 'package:cow_booking/config/internal_config.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Fevbull> _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;

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
                  'รายการที่ถูกใจ',
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

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final farmerId = context.read<DataFarmers>().datauser.farmersId;
      final uri = Uri.parse(
        '$apiEndpoint/farmer/like_bull/farmer/$farmerId',
      );

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() {
          _favorites = fevbullFromJson(response.body); // ใช้ function จาก model โดยตรง
        });
      } else {
        setState(() =>
            _errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      setState(() => _errorMessage = 'เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(Fevbull bull) async {
    // ── ลบออก UI ก่อน (optimistic update) ──
    setState(() => _favorites.removeWhere((b) => b.likeId == bull.likeId));

    // TODO: ถ้ามี endpoint DELETE ให้ uncomment และแก้ URL
    // try {
    //   final uri = Uri.parse('https://your-api.com/like_bull/${bull.likeId}');
    //   await http.delete(uri);
    // } catch (e) {
    //   // rollback ถ้า API ล้มเหลว
    //   setState(() => _favorites.insert(0, bull));
    // }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ลบ ${bull.bullsName} ออกจากรายการถูกใจแล้ว',
            style: GoogleFonts.notoSansThai()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(Fevbull bull) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('ลบรายการถูกใจ',
            style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold)),
        content: Text(
            'ต้องการลบ "${bull.bullsName}" ออกจากรายการที่ถูกใจ?',
            style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก',
                style: GoogleFonts.notoSansThai(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('ลบ', style: GoogleFonts.notoSansThai(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(color: Colors.grey[600])),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchFavorites,
                icon: const Icon(Icons.refresh),
                label: Text('ลองใหม่', style: GoogleFonts.notoSansThai()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('ยังไม่มีรายการที่ถูกใจ',
                style: GoogleFonts.notoSansThai(
                    fontSize: 18, color: Colors.grey[500])),
            const SizedBox(height: 8),
            Text('กดหัวใจที่หน้าข้อมูลวัวเพื่อเพิ่มรายการ',
                style: GoogleFonts.notoSansThai(
                    fontSize: 14, color: Colors.grey[400])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFavorites,
      color: Colors.lightGreen[700],
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _favorites.length,
        itemBuilder: (context, index) => _buildBullCard(_favorites[index]),
      ),
    );
  }

  Widget _buildBullCard(Fevbull bull) {
    return Dismissible(
      key: Key('bull_${bull.likeId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('ลบออก',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) async => await _showDeleteDialog(bull),
      onDismissed: (_) => _removeFavorite(bull),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── รูปวัว ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: bull.bullsImage.isNotEmpty
                  ? Image.network(
                      bull.bullsImage,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),

            // ── ข้อมูล ──
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bull.bullsName,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pets, size: 13, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(bull.bullsBreed,
                            style: GoogleFonts.notoSansThai(
                                fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (bull.bullsCharacteristics.isNotEmpty)
                      Text(
                        bull.bullsCharacteristics,
                        style: GoogleFonts.notoSansThai(
                            fontSize: 12, color: Colors.grey[500]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),

            // ── ไอคอนหัวใจ ──
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child:
                  Icon(Icons.favorite, color: Colors.redAccent[200], size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 100,
      height: 110,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.grey[400], size: 32),
    );
  }
}