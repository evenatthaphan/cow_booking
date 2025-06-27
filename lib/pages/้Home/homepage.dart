import 'package:cow_booking/pages/%E0%B9%89Home/seach.dart';
import 'package:cow_booking/pages/%E0%B9%89Home/seeall.dart';
import 'package:cow_booking/pages/farmers/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  double _currentPage = 0.0;

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
            fontSize: 24,
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
                MaterialPageRoute(builder: (context) => YourNewPage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png',
                ),
              ),
            ),
          ),

          // const Padding(
          //   padding: EdgeInsets.only(right: 10),
          //   child: CircleAvatar(
          //     radius: 20,
          //     backgroundImage: NetworkImage(
          //         'https://www.pngall.com/wp-content/uploads/5/User-Profile-PNG-Image.png'),
          //   ),
          // ),
        ],
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
                  // SizedBox(
                  //   width: 150,
                  //   child: Card.outlined(
                  //     child: Column(
                  //       children: [
                  //         ClipRRect(
                  //           borderRadius: const BorderRadius.only(
                  //             topLeft: Radius.circular(12),
                  //             topRight: Radius.circular(12),
                  //           ),
                  //           child: Image.asset(
                  //             'assets/images/supperman.jpg',
                  //             fit: BoxFit.cover,
                  //             height:
                  //                 120,
                  //             width: double.infinity,
                  //           ),
                  //         ),
                  //         Text('ซุปเปอร์แมน',
                  //             style: GoogleFonts.notoSansThai(fontSize: 16)),
                  //         Text('บุญน้อมฟาร์ม',
                  //             style: GoogleFonts.notoSansThai(
                  //                 fontSize: 14, color: const Color.fromARGB(255, 52, 122, 55)))
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
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
                  // SizedBox(
                  //   width: 150,
                  //   child: Card.outlined(
                  //     child: Column(
                  //       children: [
                  //         ClipRRect(
                  //           borderRadius: const BorderRadius.only(
                  //             topLeft: Radius.circular(12),
                  //             topRight: Radius.circular(12),
                  //           ),
                  //           child: Image.asset(
                  //             'assets/images/supperman.jpg',
                  //             fit: BoxFit.cover,
                  //             height:
                  //                 120,
                  //             width: double.infinity,
                  //           ),
                  //         ),
                  //         Text('ซุปเปอร์แมน',
                  //             style: GoogleFonts.notoSansThai(fontSize: 16)),
                  //         Text('บุญน้อมฟาร์ม',
                  //             style: GoogleFonts.notoSansThai(
                  //                 fontSize: 14, color: const Color.fromARGB(255, 52, 122, 55)))
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

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
  
  YourNewPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Profilepage(),
        ));
  }
}
