import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RecaptchaV2Page extends StatefulWidget {
  final String siteKey;
  final void Function(String token) onTokenReceived;

  const RecaptchaV2Page({
    super.key,
    required this.siteKey,
    required this.onTokenReceived,
  });

  @override
  State<RecaptchaV2Page> createState() => _RecaptchaV2PageState();
}

class _RecaptchaV2PageState extends State<RecaptchaV2Page> {
  bool _done = false;

  String get _html => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script src="https://www.google.com/recaptcha/api.js" async defer></script>
  <style>
    body {
      margin: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      background: #ffffff;
    }
  </style>
</head>
<body>
  <div class="g-recaptcha"
    data-sitekey="${widget.siteKey}"
    data-callback="onSuccess"
    data-expired-callback="onExpired">
  </div>
  <script>
    function onSuccess(token) {
      window.flutter_inappwebview.callHandler('RecaptchaToken', token);
    }
    function onExpired() {
      window.flutter_inappwebview.callHandler('RecaptchaExpired');
    }
  </script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ยืนยันตัวตน'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: InAppWebView(
        // ✅ ไม่มี initialData ที่นี่
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
        ),
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
            handlerName: 'RecaptchaToken',
            callback: (args) {
              if (!_done && args.isNotEmpty) {
                _done = true;
                final token = args[0].toString();
                widget.onTokenReceived(token);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          );

          controller.addJavaScriptHandler(
            handlerName: 'RecaptchaExpired',
            callback: (_) => _done = false,
          );

          // ✅ loadData พร้อม baseUrl ที่ตรงกับ domain ใน console
          controller.loadData(
            data: _html,
            mimeType: 'text/html',
            encoding: 'utf-8',
            baseUrl: WebUri('https://localhost'),
          );
        },
      ),
    );
  }
}
