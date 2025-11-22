import 'package:floor/floor.dart';
import 'package:initial_project/floor/user.dart';

@dao
abstract class ExampleUserDao<T> {
  @Query("SELECT * FROM ExampleUser WHERE userName = :userName")
  Future<ExampleUser?> getByUsername(String userName);

  @insert
  Future<void> insertUser(ExampleUser user);
}
