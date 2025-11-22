import 'package:floor/floor.dart';

@entity
class ExampleUser {
  @primaryKey
  final int? id;
  final String userName;
  final String password;

  const ExampleUser({
    required this.id,
    required this.userName,
    required this.password,
  });
}
