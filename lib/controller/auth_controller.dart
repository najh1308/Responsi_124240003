import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../routes/app_routes.dart';
import '../service/auth_service.dart';
import 'wishlist_controller.dart';

class AuthController extends GetxController {
  AuthController(this._prefs);

  final SharedPreferences _prefs;
  final AuthService _service = AuthService();

  late final RxBool isLoggedIn =
      RxBool(_prefs.getBool(AppConfig.sessionKey) ?? false);
  late final RxString username =
      RxString(_prefs.getString(AppConfig.sessionUserKey) ?? '');

  Future<String?> login(String inputUsername, String inputPassword) async {
    final u = inputUsername.trim();
    if (u.isEmpty || inputPassword.isEmpty) {
      return 'Username dan password wajib diisi.';
    }

    final user = _service.find(u);
    if (user == null || user.password != inputPassword) {
      return 'Username atau password salah.';
    }

    await _prefs.setBool(AppConfig.sessionKey, true);
    await _prefs.setString(AppConfig.sessionUserKey, user.username);
    isLoggedIn.value = true;
    username.value = user.username;
    return null;
  }

  Future<void> logout() async {
    await _prefs.setBool(AppConfig.sessionKey, false);
    await _prefs.remove(AppConfig.sessionUserKey);
    isLoggedIn.value = false;
    username.value = '';
    Get.find<WishlistController>().clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
