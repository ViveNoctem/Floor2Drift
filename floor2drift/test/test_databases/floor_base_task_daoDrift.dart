import 'package:drift/drift.dart';

import 'base_class.dart';
import 'base_classDrift.dart';
import 'floor_test_databaseDrift.dart';

mixin BaseDaoMixin<TC extends BaseClassMixin, T extends BaseClass<T>> on DatabaseAccessor<FloorTestDatabase> {
  TableInfo<TC, T> get table =>
      attachedDatabase.allTables.firstWhere((tbl) => tbl.runtimeType == TC) as TableInfo<TC, T>;

  Future<List<T>> getAll() {
    return (select(table)).get();
  }
}
