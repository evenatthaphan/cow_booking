import 'dart:js_util' as js_util;

Future<String?> getRecaptchaToken(String action) async {
  try {
    final token = await js_util
        .promiseToFuture(js_util.callMethod(js_util.globalThis, 'executeRecaptcha', [action]));
    return token as String;
  } catch (e) {
    print('reCAPTCHA error: $e');
    return null;
  }
}
