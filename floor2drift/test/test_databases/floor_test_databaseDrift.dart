import 'package:drift/drift.dart';

import 'enums.dart';
import 'floor_task_daoDrift.dart';
import 'task.dart';
import 'taskDrift.dart';
import 'type_convertersDrift.dart';

part 'floor_test_databaseDrift.g.dart';

@DriftDatabase(tables: [Tasks], daos: [TaskDao])
class FloorTestDatabase extends _$FloorTestDatabase {
  FloorTestDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
