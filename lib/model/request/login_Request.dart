import 'dart:convert';

LoginRequest loginRequestGetFromJson(String str) =>
    LoginRequest.fromJson(json.decode(str));

String loginRequestGetToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  final String loginId;
  final String password;
  // ใช้สำหรับกำหนดปลายทาง login (ไม่ถูกส่งไปที่ backend)
  final LoginRole? role;

  LoginRequest({
    required this.loginId,
    required this.password,
    this.role,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        loginId: json['loginId'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => {
        'loginId': loginId,
        'password': password,
      };

  // สร้างสำเนาพร้อมแก้บางฟิลด์
  LoginRequest copyWith({
    String? loginId,
    String? password,
    LoginRole? role,
  }) {
    return LoginRequest(
      loginId: loginId ?? this.loginId,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  // ตรวจสอบความถูกต้องเบื้องต้นของข้อมูล
  bool get isValid => loginId.trim().isNotEmpty && password.trim().isNotEmpty;
}

// ประเภทผู้ใช้สำหรับเลือกเส้นทาง login
enum LoginRole { farmer, vet }

extension LoginRolePath on LoginRole {
  String get path {
    switch (this) {
      case LoginRole.farmer:
        return '/farmer/login';
      case LoginRole.vet:
        return '/vet/login';
    }
  }
}
