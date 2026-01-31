import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cow_booking/pages/farmers/seedocprofile.dart';
import 'package:http/http.dart' as http;

class Cowdetailpage extends StatefulWidget {
  const Cowdetailpage({super.key});

  @override
  State<Cowdetailpage> createState() => _CowdetailpageState();
}

class _CowdetailpageState extends State<Cowdetailpage> {
  List<dynamic> vets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVets(); // Reload Vetexpert
  }

  Future<void> fetchVets() async {
    final bull = Provider.of<DataBull>(context, listen: false).selectedBull;
    final bullId = bull.bullId;

    setState(() {
      isLoading = true;
      vets = []; 
    });

    try {
      final response = await http
          .get(Uri.parse('$apiEndpoint/together/vet-by-bull/$bullId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            vets = data;
            isLoading = false;
          });
        } else {
          print('Unexpected vets format');
          setState(() => isLoading = false);
        }
      } else {
        print('Error fetching vets: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Exception: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bull = Provider.of<DataBull>(context).selectedBull;

    return Scaffold(
      backgroundColor: Colors.lightGreen[700],
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 350,
                  child: bull.images != null && bull.images!.isNotEmpty
                      ? PageView.builder(
                          itemCount: bull.images!.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Image.network(
                              bull.images![index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 350,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/images/imagecow.jpg',
                                      fit: BoxFit.cover),
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/imagecow.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 350,
                        ),
                ),

                // ปุ่มย้อนกลับ
                Positioned(
                  top: 20,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                // ชื่อวัว
                Positioned(
                  bottom: 10,
                  left: 14,
                  child: Text(
                    bull.bullsName.isNotEmpty ? bull.bullsName : "ไม่ทราบชื่อ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // แสดงสายพันธุ์
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(142, 238, 229, 229),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bull.bullsBreed.isNotEmpty
                          ? bull.bullsBreed
                          : "ไม่ระบุสายพันธุ์",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // bull.farmName ?? "ไม่ระบุฟาร์ม",
                            bull.farm.farmName.isNotEmpty
                              ? bull.farm.farmName
                              : "ไม่ระบุฟาร์ม",
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border,
                                color: Colors.white),
                            label: const Text(
                              "ชอบ",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        bull.contestRecords.isNotEmpty
                            ? bull.contestRecords
                            : "ไม่มีข้อมูลเพิ่มเติม",
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      // ลักษณะเด่น
                     Wrap(
                        spacing: 8,
                        children: (bull.bullsCharacteristics.isNotEmpty
                                ? bull.bullsCharacteristics.split(',')
                                : ['ไม่มีข้อมูล'])
                            .map((trait) {
                          return OutlinedButton(
                            onPressed: () {},
                            child: Text(
                              trait.trim(),
                              style: GoogleFonts.notoSansThai(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          height: 2.0,
                          color: const Color.fromARGB(255, 35, 121, 41),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('สัตวบาลที่มีน้ำเชื้อ',
                                style: GoogleFonts.notoSansThai(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextButton(
                                onPressed: seedocall,
                                child: Text('ดูทั้งหมด',
                                    style: GoogleFonts.notoSansThai(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[400]))),
                          ],
                        ),
                      ),

                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vets.isEmpty
                              ? const Text('ไม่มีข้อมูลสัตวบาล')
                              : Column(
                                  children: vets.map((vet) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: vet[
                                                      'profile_image'] !=
                                                  null
                                              ? NetworkImage(
                                                  vet['profile_image'])
                                              : const AssetImage(
                                                      'assets/images/pin.jpg')
                                                  as ImageProvider,
                                        ),
                                        title: Text(
                                          vet['VetExpert_name'],
                                          style: TextStyle(
                                              color: Colors.green[900],
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          'จังหวัด:${vet['province'] ?? ''} อำเภอ:${vet['district'] ?? ''} ตำบล:${vet['locality'] ?? ''}',
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () => seedocprofile(vet['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            minimumSize: const Size(40, 40),
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Icon(Icons.navigate_next,
                                              color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }).toList(),
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

  void seedocall() {}

  void seedocprofile(int vetId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Seedocprofilepage(vetId: vetId),
    ),
  );
}

}
