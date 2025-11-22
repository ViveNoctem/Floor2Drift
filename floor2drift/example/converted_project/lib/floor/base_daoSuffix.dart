import 'package:drift/drift.dart';
import 'package:initial_project/floor/base_class.dart';
import 'package:initial_project/floor/databaseSuffix.dart';

import 'base_classSuffix.dart';

mixin ExampleBaseDaoMixin<
  TC extends ExampleBaseClassMixin,
  T extends ExampleBaseClass<T>
>
    on DatabaseAccessor<ExampleDatabase> {
  TableInfo<TC, T> get table =>
      attachedDatabase.allTables.firstWhere((tbl) => tbl.runtimeType == TC)
          as TableInfo<TC, T>;

  Future<List<T>> getAll() {
    return (select(table)).get();
  }

  Future<List<int>> tempMany(List<T> temp) async {
    await table.insertAll(mode: InsertMode.replace, temp);
    return const [];
  }

  Future<int?> updateTaskBase(int userId, int userId2) {
    return (customUpdate(
      "UPDATE ExampleTask SET id = :userId WHERE id = :userId2",
      variables: [Variable(userId), Variable(userId2)],
      updates: {table},
      updateKind: UpdateKind.update,
    ));
  }
}
