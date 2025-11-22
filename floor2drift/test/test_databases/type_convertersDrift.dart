import 'package:drift/drift.dart';
import 'enums.dart';

class DateTimeConverter extends TypeConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromSql(String databaseValue) {
    return DateTime.parse(databaseValue);
  }

  @override
  String toSql(DateTime value) {
    return value.toIso8601String();
  }
}

class TaskTypeConverter extends TypeConverter<TaskType?, String?> {
  const TaskTypeConverter();

  @override
  TaskType? fromSql(String? databaseValue) {
    return databaseValue == null ? null : TaskType.values.byName(databaseValue);
  }

  @override
  String? toSql(TaskType? value) {
    return value?.name;
  }
}

class IntListConverter extends TypeConverter<List<int>?, String> {
  const IntListConverter();

  @override
  List<int>? fromSql(String databaseValue) {
    return databaseValue.split(",").map((s) => int.parse(s)).toList();
  }

  @override
  String toSql(List<int>? value) {
    return value == null ? "" : value.join(",");
  }
}
