import 'dart:convert';

import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/pages/Home/homepage.dart';
import 'package:cow_booking/pages/farmers/farmmer_noti.dart';
import 'package:cow_booking/pages/farmers/farmmer_booking.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class FarmerNavigationBar extends StatefulWidget {
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
  State<FarmerNavigationBar> createState() => _FarmerNavigationBarState();
}

class _FarmerNavigationBarState extends State<FarmerNavigationBar> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUnreadCount());
  }

  Future<void> _loadUnreadCount() async {
    final farmerId = context.read<DataFarmers>().datauser.farmersId;
    if (farmerId == 0) return;

    try {
      final res = await http.get(
        Uri.parse('$apiEndpoint/farmer/notifications/farmer/$farmerId'),
      );
      if (res.statusCode == 200) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        final unread = list.where((n) => n['is_read'] == 0).length;
        if (mounted) setState(() => _unreadCount = unread);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 65,
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(color: Colors.green[900], fontSize: widget.screenSize.width * 0.035),
          ),
          iconTheme: WidgetStateProperty.all(
            IconThemeData(size: widget.screenSize.width * 0.06),
          ),
          indicatorColor: Colors.green[900]?.withOpacity(0.2),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: NavigationBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: (int index) {
            widget.onDestinationSelected(index); // Call the passed function

            switch (index) {
              case 0:
                _navigateCheckQueues(context);
                break;
              case 1:
                _navigateHomePage(context);
                break;
              case 2:
                _navigateNotification(context);
                break;
            }
          },
          destinations: [
            NavigationDestination(
                icon: Icon(Iconsax.folder_2, color: Colors.green[900]), label: "คิวของฉัน"),
            NavigationDestination(icon: Icon(Iconsax.home, color: Colors.green[900]), label: "หน้าหลัก"),
            NavigationDestination(
                icon: _buildNotificationIcon(), label: "แจ้งเตือน"),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Iconsax.notification, color: Colors.green[900]),
        if (_unreadCount > 0)
          Positioned(
            right: -2,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _navigateHomePage(BuildContext context) {
    _setPeriod(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
      (route) => false,
    );
  }

  void _navigateCheckQueues(BuildContext context) {
    _setPeriod(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Farmmerbookingpage()),
    );
  }

  void _navigateNotification(BuildContext context) {
    _setPeriod(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FarmerNotificationPage()),
    );
  }

  void _setPeriod(BuildContext context) {
    final farmerData = context.read<DataFarmers>();
    farmerData.setPeriod(farmerData.lastperiod);
  }
}
