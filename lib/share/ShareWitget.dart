import 'dart:convert';
import 'dart:ui'; // Required for BackdropFilter and ImageFilter
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cow_booking/model/response/allerrorresponse.dart';
import 'package:http/http.dart' as http;

class MyWidget {
  void showCustomSnackbar(String title, String msgValue) {
    Get.rawSnackbar(  
      snackPosition: SnackPosition.TOP,
      backgroundColor:
          Colors.transparent, // Transparent to allow the blur to show
      duration: const Duration(seconds: 2),
      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Background color with transparency
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msgValue,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HandleError {
  MyWidget myWidget = MyWidget();
  void handleError(http.Response response) {
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    if (jsonResponse is Map<String, dynamic>) {
      final msgValue = jsonResponse['msg'];
      if (msgValue is String) {
        myWidget.showCustomSnackbar('Message', msgValue);
      } else if (msgValue is Map<String, dynamic>) {
        try {
          final msg = allerrorresponsegetFromJson(jsonEncode(msgValue));
          myWidget.showCustomSnackbar('Message', msg.toString());
        } catch (e) {
          myWidget.showCustomSnackbar('Message', 'Error parsing "msg": $e');
        }
      }
    } else {
      myWidget.showCustomSnackbar('Error', 'Unexpected response format');
    }
  }
}