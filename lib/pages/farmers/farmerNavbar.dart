import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/farmers/farmmerNoti.dart';
import 'package:cow_booking/pages/farmers/farmmerbooking.dart';
import 'package:cow_booking/share/ShareData.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class FarmerNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final Size screenSize;

  const FarmerNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 65,
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(color: Colors.white, fontSize: screenSize.width * 0.035),
          ),
          iconTheme: WidgetStateProperty.all(
            IconThemeData(size: screenSize.width * 0.06),
          ),
          indicatorColor: Colors.white.withOpacity(0.2),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: NavigationBar(
          backgroundColor: const Color.fromARGB(255, 2, 91, 29),
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            onDestinationSelected(index); // Call the passed function

            // Navigate to the corresponding page based on the selected index
            switch (index) {
              case 0:
                navigateCheckQueues(context);
                break;
              case 1:
                navigateHomePage(context);
                break;
              case 2:
                navigateNotification(context);
                break;
              // case 3:
              //   navigateBuyLotto(context);
              //   break;
              // case 4:
              //   navigateProfile(context);
              //   break;
            }
          },
          destinations: const [
            NavigationDestination(
                icon: Icon(Iconsax.folder_2, color: Colors.white,), label: "คิวของฉัน"),
            NavigationDestination(icon: Icon(Iconsax.home,  color: Colors.white), label: "หน้าหลัก"),
            NavigationDestination(
                icon: Icon(Iconsax.notification,  color: Colors.white), label: "แจ้งเตือน"),
            // NavigationDestination(
            //     icon: Icon(Iconsax.money_tick), label: "ซื้อสลาก"),
            // NavigationDestination(
            //     icon: Icon(Iconsax.profile_2user), label: "โปรไฟล์"),
          ],
        ),
      ),
    );
  }

  void navigateHomePage(BuildContext context) {
  _setperiod(context);

  // reset data stack 
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Homepage()),
    (route) => false, // delete all route out of stack
  );
}


  void navigateCheckQueues(BuildContext context) {
    _setperiod(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Farmmerbookingpage()),
    );
  }

  void navigateNotification(BuildContext context) {
    _setperiod(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FarmerNotificationPage()),
    );
  }


  void _setperiod(BuildContext context) {
    final FarmerId = context.read<DataFarmers>();
    FarmerId.setPeriod(FarmerId.lastperiod);
  }
}
