import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../model/user.dart';

class LocalDb {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());

    final users = await Hive.openBox<User>(AppConfig.usersBox);
    await Hive.openBox<String>(AppConfig.wishlistBox);

    final key = AppConfig.defaultUsername.toLowerCase();
    if (!users.containsKey(key)) {
      await users.put(
        key,
        User(
          username: AppConfig.defaultUsername,
          password: AppConfig.defaultPassword,
        ),
      );
    }
  }
}
