import 'package:cow_booking/pages/Home/cowdetail.dart';
import 'package:cow_booking/pages/Home/seach.dart';
import 'package:cow_booking/pages/Home/seeall.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
    fetchUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text('ยอดนิยม',
                    style: GoogleFonts.notoSansThai(
                        textStyle: Theme.of(context).textTheme.displayLarge,
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
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                height: 2.0,
                color: const Color.fromARGB(255, 35, 121, 41),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("พ่อพันธุ์บราห์มัน",
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextButton(
                      onPressed: seeabramanll,
                      child: Text('ดูทั้งหมด',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900]))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 25),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Card.outlined(
                        child: Column(
                          children: [
                            // ClipRRect(
                            //   borderRadius: const BorderRadius.only(
                            //     topLeft: Radius.circular(12),
                            //     topRight: Radius.circular(12),
                            //   ),
                            //   child: Image.asset(
                            //     'assets/images/supperman.jpg',
                            //     fit: BoxFit.cover,
                            //     height: 120,
                            //     width: double.infinity,
                            //   ),
                            // ),
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: InkWell(
                                onTap: detailpage,
                                child: Image.asset(
                                  'assets/images/supperman.jpg',
                                  fit: BoxFit.cover,
                                  height: 120,
                                  width: double.infinity,
                                ),
                              ),
                            ),

                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(fontSize: 16)),
                            Text('บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 52, 122, 55)))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Card.outlined(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/supperman.jpg',
                                fit: BoxFit.cover,
                                height: 120,
                                width: double.infinity,
                              ),
                            ),
                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(fontSize: 16)),
                            Text('บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 52, 122, 55)))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Card.outlined(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/supperman.jpg',
                                fit: BoxFit.cover,
                                height: 120,
                                width: double.infinity,
                              ),
                            ),
                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(fontSize: 16)),
                            Text('บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 52, 122, 55)))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("พ่อพันธุ์บีฟมาสเตอร์",
                      style: GoogleFonts.notoSansThai(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextButton(
                      onPressed: seemasterall,
                      child: Text('ดูทั้งหมด',
                          style: GoogleFonts.notoSansThai(
                              textStyle:
                                  Theme.of(context).textTheme.displayLarge,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900]))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 25),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Card.outlined(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/master.jpg',
                                fit: BoxFit.cover,
                                height: 120,
                                width: double.infinity,
                              ),
                            ),
                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(fontSize: 16)),
                            Text('บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 52, 122, 55)))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Card.outlined(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/master.jpg',
                                fit: BoxFit.cover,
                                height: 120,
                                width: double.infinity,
                              ),
                            ),
                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(fontSize: 16)),
                            Text('บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 52, 122, 55)))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Card.outlined(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/master.jpg',
                                fit: BoxFit.cover,
                                height: 120,
                                width: double.infinity,
                              ),
                            ),
                            Text('ซุปเปอร์แมน',
                                style: GoogleFonts.notoSansThai(fontSize: 16)),
                            Text('บุญน้อมฟาร์ม',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    color:
                                        const Color.fromARGB(255, 52, 122, 55)))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> fetchUserData() async {
    try {
      final url = Uri.parse(
        "https://cowbooking-api.onrender.com/farmer/getfarmer",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
        });
      } else {
        print("Failed to load user: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
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

  void seeabramanll() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Allmramanpage(),
        ));
  }

  void seemasterall() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Allmramanpage(),
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
