import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Farms_response.dart';
import 'package:cow_booking/pages/Home/cows_detail.dart';
import 'package:cow_booking/pages/Home/seach.dart';
import 'package:cow_booking/pages/Home/seeall.dart';
import 'package:cow_booking/pages/farmers/farmer_navbar.dart';
import 'package:cow_booking/pages/farmers/farmer_profile.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  //const Homepage({super.key});
  // final String userId;
  // const Homepage({super.key, required this.userId});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  double _currentPage = 0.0;
  Map<String, dynamic>? userData; // เก็บข้อมูล user
  late Future<void> loadData;

  List<dynamic> topBulls = []; // เพิ่ม

  Future<void> fetchTopBulls() async {
    try {
      final response = await http.get(
        Uri.parse('$apiEndpoint/stats/insemination/top-bulls'),
      );
      if (response.statusCode == 200) {
        setState(() {
          topBulls = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching top bulls: $e');
    }
  }

  Map<String, List<dynamic>> bullGroups = {}; // เก็บข้อมูลแยกตามพันธุ์

  Future<void> fetchBulls() async {
    try {
      final url = Uri.parse("$apiEndpoint/bull/getbull");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bullGroups = Map<String, List<dynamic>>.from(data);
        });
      } else {
        print("Failed to load bulls: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching bulls: $e");
    }
  }

  String _normalizeProfileImageUrl(String? url) {
    print("RAW IMAGE URL: $url"); // debug ดูค่าที่ได้มา

    if (url == null || url.isEmpty) return '';

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return '$apiEndpoint/$url';
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
    fetchBulls();
    fetchTopBulls();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget buildBullSection(String breed, List<dynamic> bulls) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + ดูทั้งหมด 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('พ่อพันธุ์$breed',
                  style: GoogleFonts.notoSansThai(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SeeallPage(breed: breed, bulls: bulls)),
                ),
                child: Text('ดูทั้งหมด',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900])),
              ),
            ],
          ),

          // รายการวัวแยกตามพันธุ์
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: bulls.map((bull) {
                final bullImages = bull['images'] as List<dynamic>? ?? [];
                final firstImage = bullImages.isNotEmpty ? bullImages[0] : '';
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 10),
                  child: Card.outlined(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              final dataBull =
                                  Provider.of<DataBull>(context, listen: false);
                              dataBull.setSelectedBull(
                                  FarmbullRequestResponse.fromJson(bull));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Cowdetailpage()),
                              );
                            },
                            child: SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: firstImage.isNotEmpty
                                  ? Image.network(firstImage, fit: BoxFit.cover)
                                  : Image.asset('assets/images/supperman.jpg',
                                      fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(bull['bulls_name'] ?? '',
                                  style:
                                      GoogleFonts.notoSansThai(fontSize: 16),
                                  overflow: TextOverflow.ellipsis),
                              Text(bull['farm']?['farm_name'] ?? '',
                                  style: GoogleFonts.notoSansThai(
                                      fontSize: 14,
                                      color: const Color.fromARGB(
                                          255, 52, 122, 55)),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'หน้าหลัก',
          style: GoogleFonts.notoSansThai(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: taptoseach),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Farmerprofilepage())),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Consumer<DataFarmers>(
                builder: (context, dataFarmer, _) {
                  final imageUrl = _normalizeProfileImageUrl(
                      dataFarmer.datauser.farmersProfileImage);

                  print("FINAL IMAGE URL: $imageUrl"); // debug

                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: imageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              imageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              // แสดง loading ระหว่างโหลด
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.green,
                                  ),
                                );
                              },
                              errorBuilder: (_, error, __) {
                                print("IMAGE ERROR: $error"); // debug
                                return const Icon(Icons.person, color: Colors.grey);
                              },
                            ),
                          )
                        : const Icon(Icons.person, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // หัวข้อ Top Bulls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('สุดยอดพ่อพันธุ์   ',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text('ยอดนิยม',
                    style: GoogleFonts.notoSansThai(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900])),
              ],
            ),
            const SizedBox(height: 20),

            // PageView Top 3 วัว
            SizedBox(
              height: 250,
              child: topBulls.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: topBulls.length,
                      itemBuilder: (context, index) {
                        final bull = topBulls[index];
                        final imageUrl = bull['bulls_image'] ?? '';
                        final scale = (_currentPage - index).abs() < 1
                            ? 1 - (_currentPage - index).abs() * 0.3
                            : 0.7;

                        return TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 350),
                          tween: Tween<double>(begin: scale, end: scale),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // รูปวัว
                                    Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      clipBehavior: Clip.antiAlias,
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                      'assets/images/imagecow.jpg',
                                                      fit: BoxFit.cover),
                                            )
                                          : Image.asset(
                                              'assets/images/imagecow.jpg',
                                              fit: BoxFit.cover),
                                    ),

                                    // Badge อันดับ 
                                    Positioned(
                                      top: 10,
                                      left: 18,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: [
                                            Colors.amber,
                                            Colors.grey.shade400,
                                            Colors.brown.shade300,
                                          ][index],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          ['🥇 อันดับ 1', '🥈 อันดับ 2', '🥉 อันดับ 3'][index],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),

                                    // ── ชื่อ + อัตราสำเร็จ ──
                                    Positioned(
                                      bottom: 10,
                                      left: 18,
                                      right: 18,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.black.withOpacity(0.45),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              bull['bulls_name'] ?? '-',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            Text(
                                              '✅ ${bull['success_rate']}%',
                                              style: const TextStyle(
                                                  color: Colors.greenAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // รายการวัวแยกตามพันธุ์ 
            if (bullGroups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else
              ...bullGroups.entries.map((entry) {
                return buildBullSection(entry.key, entry.value);
              }).toList(),
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

  // Future<void> loadDataAsync() async {
  //   var config = await Configuration.getConfig();
  //   url = config['apiEndpoint'];

  //   var res = await http.get(Uri.parse('$url/trips'));
  //   log(res.body);
  //   tripGetResponses = tripGetResponseFromJson(res.body);
  //   log(tripGetResponses.length.toString());
  // }

  void taptoseach() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Seachpage(),
        ));
  }

  void detailpage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Cowdetailpage(),
        ));
  }
}
