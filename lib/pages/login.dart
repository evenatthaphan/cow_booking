import 'package:cow_booking/pages/chooselogin.dart';
import 'package:cow_booking/pages/chooseregis.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  child: Image.asset(
                'assets/images/logo.png',
              )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'สวัสดี',
                          style: GoogleFonts.notoSansThai(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'ขอต้อนรับเข้าสู่การจองคิวการผสมเทียม',
                            style: GoogleFonts.notoSansThai(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'เข้าสู่ระบบเพื่อใช้งาน',
                            style: GoogleFonts.notoSansThai(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 5, 30, 10),
                height: 2.0,
                color: Colors.green[900],
              ),
              const SizedBox(
                height: 30,
                width: 100,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: FilledButton(
                              onPressed: chooselogin,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.green[900]!),
                              ),
                              child: Text(
                                'เข้าสู่ระบบ',
                                style: GoogleFonts.notoSansThai(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: chooseregis,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.white),
                              ),
                              child: Text('ลงทะเบียน',
                                  style: GoogleFonts.notoSansThai(
                                    textStyle:
                                        Theme.of(context).textTheme.displayLarge,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void chooselogin() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChooseLogin(),
        ));
  }

  void chooseregis() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Chooseregis(),
        ));
  }
}


