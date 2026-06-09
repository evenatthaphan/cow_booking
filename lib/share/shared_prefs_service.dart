import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  // ฟังก์ชันสำหรับเปิดใช้งานครั้งแรก (เรียกใช้ใน main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // บันทึก Token
  static Future<bool> setToken(String token) async {
    return await _prefs?.setString('user_token', token) ?? false;
  }

  // ดึง Token มาดู
  static String? getToken() {
    return _prefs?.getString('user_token');
  }

  // ลบ Token (ตอน Logout)
  static Future<bool> removeToken() async {
    return await _prefs?.remove('user_token') ?? false;
  }

}