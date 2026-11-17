class AppConfig {
  static const String appTitle = 'ShoppingHub';

  // ▶ UBAH: host API sesuai soal. Contoh lain: 'rickandmortyapi.com'
  // (jangan pakai https:// di depan, karena kita pakai Uri.https)
  static const String apiHost = 'dummyjson.com';

  static const int pageSize = 10;

  static const String defaultUsername = 'responsi';
  static const String defaultPassword = 'responsi123';
  static const String defaultFullName = 'responsi';

  static const String sessionKey = 'loginData'; 
  static const String sessionUserKey = 'username'; 
  static const String usersBox = 'users';
  static const String cartsBox = 'carts'; 

  static String favoritesKey(String username) =>
      'favorites_${username.toLowerCase()}';
}
