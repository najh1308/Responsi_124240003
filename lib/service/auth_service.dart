import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../model/user.dart';

class AuthService {
  Box<User> get _box => Hive.box<User>(AppConfig.usersBox);

  User? find(String username) => _box.get(username.toLowerCase());

  bool exists(String username) => _box.containsKey(username.toLowerCase());

}
