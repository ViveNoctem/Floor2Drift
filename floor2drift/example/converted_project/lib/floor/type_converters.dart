// need to import as floor to avoid namespace problem with TypeConverter
import 'package:floor/floor.dart';

import 'enums.dart';

class DateTimeConverter extends TypeConverter<DateTime, String> {
  @override
  DateTime decode(String databaseValue) {
    return DateTime.parse(databaseValue);
  }

  @override
  String encode(DateTime value) {
    return value.toIso8601String();
  }
}

class TaskTypeConverter extends TypeConverter<TaskType?, String?> {
  @override
  TaskType? decode(String? databaseValue) {
    return databaseValue == null ? null : TaskType.values.byName(databaseValue);
  }

  @override
  String? encode(TaskType? value) {
    return value?.name;
  }
}

class IntListConverter extends TypeConverter<List<int>?, String> {
  @override
  List<int> decode(String databaseValue) {
    return databaseValue.split(",").map((s) => int.parse(s)).toList();
  }

  @override
  String encode(List<int>? value) {
    return value == null ? "" : value.join(",");
  }
}
