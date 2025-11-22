import 'package:drift/drift.dart';
import 'package:floor/floor.dart';

@entity
class ExampleUser implements Insertable<ExampleUser> {
  @primaryKey
  final int? id;
  final String userName;
  final String password;

  const ExampleUser({
    required this.id,
    required this.userName,
    required this.password,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {
      "id": Variable(id),
      "userName": Variable(userName),
      "password": Variable(password),
    };
  }
}
