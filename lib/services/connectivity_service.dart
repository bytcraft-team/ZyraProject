import 'package:connectivity_plus/connectivity_plus.dart';

/// خدمة للتحقق من حالة الإنترنت
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// التحقق من وجود اتصال إنترنت نشط
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();

      // التحقق من أن الاتصال موجود (WiFi أو Mobile)
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi)) {
        return true;
      }
      return false;
    } catch (e) {
      print('خطأ في التحقق من الإنترنت: $e');
      return false;
    }
  }

  /// الاستماع إلى تغييرات الإنترنت
  Stream<bool> connectionStatusStream() {
    return _connectivity.onConnectivityChanged.map((result) {
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi);
    });
  }
}
