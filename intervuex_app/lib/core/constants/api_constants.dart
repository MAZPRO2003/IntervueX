import 'package:flutter/foundation.dart';

class ApiConstants {
  // Toggle this to true when publishing/testing production Cloud Backend
  static const bool useCloudBackend = true;

  // Your live Render HTTPS URL
  static const String cloudProductionUrl = "https://intervuex-t9pu.onrender.com/api/v1";

  static String get baseUrl {
    if (useCloudBackend) {
      return cloudProductionUrl;
    }
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api/v1";
    }
    // Development fallback for physical device (via ADB reverse or Wi-Fi local IP)
    return "http://127.0.0.1:8000/api/v1";
  }

  static String get lanBaseUrl {
    return "http://192.168.31.176:8000/api/v1";
  }
}


