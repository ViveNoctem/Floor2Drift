import 'package:drift/drift.dart';
import 'package:initial_project/floor/base_classSuffix.dart';
import 'package:initial_project/floor/task/task.dart';

import '../enums.dart';
import '../type_convertersSuffix.dart';

@UseRowClass(ExampleTask)
class ExampleTasks extends Table with ExampleBaseClassMixin {
  TextColumn get message => text().clientDefault(() => "default")();
  IntColumn get userId => integer()();
  TextColumn get timestamp => text().map(const DateTimeConverter())();
  IntColumn get status => intEnum<TaskStatus>()();
  TextColumn get type => text().map(const TaskTypeConverter()).nullable()();
  BlobColumn get attachment => blob().nullable()();
}
