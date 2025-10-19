import 'package:cow_booking/pages/farmers/farmerprofile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cow_booking/pages/Home/seach.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/share/ShareData.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ดูทั้งหมด',
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
            onPressed: seach,
          ),
          // รูปโปรไฟล์
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
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
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.bulls.length,
        itemBuilder: (context, index) {
          final bull = widget.bulls[index];
          final bullImages = bull['images'] as List<dynamic>? ?? [];
          final firstImage = bullImages.isNotEmpty ? bullImages[0] : '';

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              color: Colors.white,
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // ให้สูงตามเนื้อหา
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                          width: 130,
                          height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: firstImage.isNotEmpty
                            ? Image.network(firstImage, fit: BoxFit.cover)
                            : Image.asset('assets/images/supperman.jpg',
                                fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
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
                            style: GoogleFonts.notoSansThai(
                                fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            bull['contest_records'] ?? '',
                            style: GoogleFonts.notoSansThai(
                                fontSize: 12, color: Colors.black),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 40,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: (bull['characteristics'] as String)
                                    .split(' ')
                                    .map((c) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: OutlinedButton(
                                            onPressed: () {},
                                            child: Text(
                                              c,
                                              style: GoogleFonts.notoSansThai(
                                                  fontSize: 10,
                                                  color: Colors.green[900]),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void seach() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Seachpage(),
        ));
  }

  void seedoctor() {}

  void seedetail() {}
}
