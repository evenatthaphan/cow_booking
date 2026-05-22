import 'dart:convert';

import 'package:cow_booking/pages/Animal_husbandry/insert_cow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';

class CowListPage extends StatefulWidget {
  const CowListPage({super.key});

  @override
  State<CowListPage> createState() => _CowListPageState();
}

class _CowListPageState extends State<CowListPage> {
  Map<String, List<dynamic>> _groupedBulls = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBulls();
  }

  Future<void> _fetchBulls() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vetId = context.read<DataVetExpert>().datauser.id;

      final uri = Uri.parse(
        '$apiEndpoint/bull/getby_vetid/$vetId',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _groupedBulls = Map<String, List<dynamic>>.from(
            data.map(
              (key, value) => MapEntry(
                key,
                List<dynamic>.from(value),
              ),
            ),
          );
        });
      } else {
        setState(() {
          _errorMessage =
              'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),

      floatingActionButton: FloatingActionButton.extended(
      backgroundColor: Colors.lightGreen[700],
      foregroundColor: Colors.white,

      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const InsertCowPage()),
        );
      },

      icon: const Icon(Icons.add),
      label: Text(
        'เพิ่มรายการ',
        style: GoogleFonts.notoSansThai(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

      appBar: AppBar(
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
                    'รายการวัวของฉัน',
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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.green[900]),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Colors.grey[400],
              ),

              const SizedBox(height: 16),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _fetchBulls,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'ลองใหม่',
                  style: GoogleFonts.notoSansThai(),
                ),
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

    if (_groupedBulls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 80,
              color: Colors.grey[300],
            ),

            const SizedBox(height: 16),

            Text(
              'ยังไม่มีข้อมูลวัว',
              style: GoogleFonts.notoSansThai(
                fontSize: 18,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBulls,
      color: Colors.lightGreen[700],

      child: ListView(
        padding: const EdgeInsets.all(12),

        children: _groupedBulls.entries.map((entry) {
          final breed = entry.key;
          final bulls = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  breed,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),

              ...bulls.map(
                (bull) => _buildBullCard(bull),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBullCard(dynamic bull) {
    final List<dynamic> images = bull['images'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

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
          // ───────── รูป ─────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            
              child: images.isNotEmpty
                  ? Image.network(
                      images.first,
                      width: 110,
                      height: 130,
                      fit: BoxFit.cover,
            
                      errorBuilder: (_, __, ___) {
                        return _placeholderImage();
                      },
                    )
                  : _placeholderImage(),
            ),
          ),

          // ───────── ข้อมูล ─────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    bull['bulls_name'] ?? '-',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 15,
                        color: Colors.green[700],
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          bull['bulls_breed'] ??
                              'ไม่ระบุสายพันธุ์',

                          style:
                              GoogleFonts.notoSansThai(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  if ((bull['bulls_characteristics'] ??
                          '')
                      .toString()
                      .isNotEmpty)
                    Text(
                      bull['bulls_characteristics'],
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 16,
                        color: Colors.blue[400],
                      ),

                      const SizedBox(width: 4),

                      Text(
                        'คงเหลือ ${bull['semen_stock'] ?? 0} โดส',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.orange[700],
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${bull['price_per_dose'] ?? 0} บาท/โดส',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'ฟาร์ม: ${bull['farm']?['farm_name'] ?? '-'}',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: ไปหน้าแก้ไขวัว
                            // Navigator.push(...)
                          },

                          icon: const Icon(Icons.edit, size: 18),

                          label: Text(
                            'แก้ไข',
                            style: GoogleFonts.notoSansThai(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[700],
                            side: BorderSide(
                              color: Colors.green.shade300,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: เปิดหน้ารายละเอียด
                          },

                          icon: const Icon(Icons.visibility, size: 18),

                          label: Text(
                            'ดูข้อมูล',
                            style: GoogleFonts.notoSansThai(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreen[700],
                            foregroundColor: Colors.white,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 110,
      height: 130,
      color: Colors.grey[200],

      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[400],
        size: 34,
      ),
    );
  }
}