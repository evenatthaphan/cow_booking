import 'dart:convert';
import 'package:cow_booking/config/internal_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Seachpage extends StatefulWidget {
  const Seachpage({super.key});

  @override
  State<Seachpage> createState() => _SeachpageState();
}

class _SeachpageState extends State<Seachpage> {
  String _searchText = "";
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedLocality;

  List<dynamic> _searchResults = [];
  bool _loading = false;

  Future<void> searchBulls() async {
    setState(() {
      _loading = true;
    });

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
      setState(() {
        _loading = false;
      });
      print("Error fetching bulls: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            onSubmitted: (_) => searchBulls(),
            decoration: const InputDecoration(
              hintText: 'พิมพ์พ่อพันธุ์ที่ต้องการค้นหา',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.black),
            cursorColor: Colors.black,
          ),
        ),
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                filterButton('ทั้งหมด', () {
                  selectedProvince = null;
                  selectedDistrict = null;
                  selectedLocality = null;
                  searchBulls();
                }),
                filterButton('จังหวัด', () {
                  // TODO: เลือกจังหวัด
                }),
                filterButton('อำเภอ', () {
                  // TODO: เลือกอำเภอ
                }),
                filterButton('ตำบล', () {
                  // TODO: เลือกตำบล
                }),
              ],
            ),
          ),

          const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 15),
              Text(
                'ผลการค้นหา : ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Search Results
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final bull = _searchResults[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 120, // ให้รูปสูงประมาณนี้
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              bull['image1'] ??
                                  'https://via.placeholder.com/130',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bull['Bullname'] ?? '',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                bull['farm_name'] ?? '',
                                style: GoogleFonts.notoSansThai(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                bull['contest_records'] ?? '',
                                style: GoogleFonts.notoSansThai(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: (bull['characteristics'] as String?)
                                          ?.split(' ')
                                          .map((c) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: OutlinedButton(
                                                  onPressed: () {},
                                                  child: Text(
                                                    c,
                                                    style: GoogleFonts
                                                        .notoSansThai(
                                                            fontSize: 10),
                                                  ),
                                                ),
                                              ))
                                          .toList() ??
                                      [],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  SizedBox filterButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      height: 40,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]!),
        ),
        child: Text(
          text,
          style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}
