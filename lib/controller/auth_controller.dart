import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../model/user.dart';
import '../routes/app_routes.dart';
import '../service/auth_service.dart';
import 'favorite_controller.dart';

class AuthController extends GetxController {
  AuthController(this._prefs);

  final SharedPreferences _prefs;
  final AuthService _service = AuthService();

  late final RxBool isLoggedIn =
      RxBool(_prefs.getBool(AppConfig.sessionKey) ?? false);
  late final RxString username =
      RxString(_prefs.getString(AppConfig.sessionUserKey) ?? '');
  final RxString fullName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn.value) fullName.value = _service.find(username.value)?.fullName ?? '';
  }

  String get displayName =>
      fullName.value.isNotEmpty ? fullName.value : username.value;

  Future<String?> login(String inputUsername, String inputPassword) async {
    final u = inputUsername.trim();
    if (u.isEmpty || inputPassword.isEmpty) {
      return 'Username dan password wajib diisi.';
    }

    final user = _service.find(u); // cari akun di Hive
    if (user == null || user.password != inputPassword) {
      return 'Username atau password salah.';
    }

    await _prefs.setBool(AppConfig.sessionKey, true);
    await _prefs.setString(AppConfig.sessionUserKey, user.username);
    isLoggedIn.value = true;
    username.value = user.username;
    fullName.value = user.fullName;
    return null;
  }

}
