/*import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final storage = FlutterSecureStorage();

  Future<void> saveTokens(String access, String refresh) async {
    await storage.write(key: "access", value: access);
    await storage.write(key: "refresh", value: refresh);
  }

  Future<String?> get accessToken async => storage.read(key: 'access');
  Future<String?> get refreshToken async => storage.read(key: "refresh");

  Future<void> clear() async {
    await storage.delete(key: "access");
    await storage.delete(key: "refresh");
  }
}*/
