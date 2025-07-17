import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cowdetailpage extends StatefulWidget {
  const Cowdetailpage({super.key});

  @override
  State<Cowdetailpage> createState() => _CowdetailpageState();
}

class _CowdetailpageState extends State<Cowdetailpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      backgroundColor: Colors.green[900],
      body: SafeArea(
        child: Column(
          children: [
            // ภาพบน
            Stack(
              children: [
                Image.asset(
                  'assets/images/imagecow.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 350,
                ),
                Positioned(
                  top: 20,
                  left: 16,
                  child: Positioned(
                    top: 20,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // กลับไปหน้าก่อนหน้า
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    'ซุปเปอร์แมน',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Positioned(
                //   bottom: 16,
                //   right: 16,
                //   child: Container(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: Colors.white24,
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: const Text(
                //       '28 ตอน',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/logo.png'),
                            radius: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Cynxweek 💗',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ใครจะคิดว่านักแข่งทีมที่ชอบจะมาสารภาพรัก...',
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.pinkAccent),
                          SizedBox(width: 4),
                          Text('715 คน', style: TextStyle(color: Colors.black)),
                          SizedBox(width: 16),
                          Icon(Icons.visibility, color: Colors.black),
                          SizedBox(width: 4),
                          Text('122k', style: TextStyle(color: Colors.black)),
                          SizedBox(width: 16),
                          Icon(Icons.comment, color: Colors.black),
                          SizedBox(width: 4),
                          Text('1.3k', style: TextStyle(color: Colors.black)),
                          SizedBox(width: 16),
                          Icon(Icons.bookmark, color: Colors.black),
                          SizedBox(width: 4),
                          Text('5.3k', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite_border),
                              label: const Text("ชอบ"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.bookmark_border),
                              label: const Text("เพิ่มแล้ว"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.remove_red_eye),
                              label: const Text("อ่านเลย"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
