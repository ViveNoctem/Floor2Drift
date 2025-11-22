import 'package:drift/drift.dart';
import 'package:initial_project/floor/databaseSuffix.dart';
import 'package:initial_project/floor/user.dart';
import 'package:initial_project/floor/userSuffix.dart';

part 'user_daoSuffix.g.dart';

@DriftAccessor(tables: [ExampleUsers])
class ExampleUserDao extends DatabaseAccessor<ExampleDatabase>
    with _$ExampleUserDaoMixin {
  ExampleUserDao(super.db);

  Future<ExampleUser?> getByUsername(String userName) {
    return (select(exampleUsers)..where(
          (exampleUsers) => exampleUsers.userName.equalsExp(Variable(userName)),
        ))
        .getSingle();
  }

  Future<void> insertUser(ExampleUser user) async {
    await exampleUsers.insertOne(user);
  }
}
