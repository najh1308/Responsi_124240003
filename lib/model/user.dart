import 'package:hive/hive.dart';

class User extends HiveObject {
  final String username; 
  final String password;
  final String fullName; 

  User({
    required this.username,
    required this.password,
    required this.fullName,
  });

  User copyWith({String? password, String? fullName}) => User(
        username: username,
        password: password ?? this.password,
        fullName: fullName ?? this.fullName,
      );
}

class UserAdapter extends TypeAdapter<User> {

  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      username: fields[0] as String,
      password: fields[1] as String,
      fullName: (fields[2] as String?) ?? '',
    );
  }

  // Menulis object User -> disk. Format: jumlah field, lalu (nomor, nilai) berulang
  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(3) // jumlah field
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.fullName);
  }
}
