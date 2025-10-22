import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/model/response/Farms_response.dart';
import 'package:cow_booking/pages/Home/cowdetail.dart';
import 'package:cow_booking/pages/Home/seach.dart';
import 'package:cow_booking/pages/Home/seeall.dart';
import 'package:cow_booking/pages/farmers/farmerNavbar.dart';
import 'package:cow_booking/pages/farmers/farmerprofile.dart';
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

  final List<String> imagePaths = [
    'assets/images/imagecow.jpg',
    'assets/images/imagecow.jpg',
    'assets/images/imagecow.jpg',
  ];

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

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
    fetchBulls();
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
          // หัวข้อพันธุ์ + ปุ่มดูทั้งหมด
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "พ่อพันธุ์${breed}",
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  //
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SeeallPage(breed: breed, bulls: bulls),
                    ),
                  );
                },
                child: Text(
                  'ดูทั้งหมด',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),
            ],
          ),
          // รายการพ่อพันธุ์แนวนอน
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
                                  builder: (context) => const Cowdetailpage(),
                                ),
                              );
                            },
                            child: firstImage.isNotEmpty
                                ? Image.network(firstImage, fit: BoxFit.cover)
                                : Image.asset('assets/images/supperman.jpg',
                                    fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(
                                bull["Bullname"] ?? "",
                                style: GoogleFonts.notoSansThai(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                bull["farm_name"] ?? "",
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 52, 122, 55),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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
        iconTheme: const IconThemeData(
          color: Colors.white, // กำหนดสีของไอคอนใน AppBar ให้เป็นสีขาว
        ),
        actions: [
          // ปุ่มค้นหา
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: taptoseach,
          ),
          // รูปโปรไฟล์
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Farmerprofilepage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Consumer<DataFarmers>(
                builder: (context, dataVet, _) {
                  final imageUrl = dataVet.datauser.profileImage;
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage: (imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : const NetworkImage(
                            'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
                          ),
                  );
                },
              ),
            ),
          ),
        ],

        // const Padding(
        //   padding: EdgeInsets.only(right: 10),
        //   child: CircleAvatar(
        //     radius: 20,
        //     backgroundImage: NetworkImage(
        //         'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png'),
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              imagePaths[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            if (bullGroups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else
              //  Section
              ...bullGroups.entries.map((entry) {
                final breed = entry.key;
                final bulls = entry.value;
                return buildBullSection(breed, bulls);
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
