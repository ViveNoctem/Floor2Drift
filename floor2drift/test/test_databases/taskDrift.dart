import 'package:drift/drift.dart';

import 'base_classDrift.dart';
import 'enums.dart';
import 'task.dart';
import 'type_convertersDrift.dart';

@UseRowClass(Task)
class Tasks extends Table with BaseClassMixin {
  @override
  String? get tableName => "Task";
  TextColumn get message => text().clientDefault(() => "default")();
  BoolColumn get isRead => boolean().nullable()();
  TextColumn get timestamp => text().map(const DateTimeConverter())();
  IntColumn get status => intEnum<TaskStatus>()();
  TextColumn get type => text().map(const TaskTypeConverter()).nullable()();
  TextColumn get integers => text().map(const IntListConverter())();
  BlobColumn get attachment => blob().nullable()();
  RealColumn get customDouble => real()();
}
