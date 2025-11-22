import 'package:drift/drift.dart';
import 'package:floor_annotation/floor_annotation.dart';

import '../additional_classes/annotation.dart';
import 'base_class.dart';
import 'enums.dart';
import 'type_converters.dart';
import 'type_convertersDrift.dart' as drift;

@entity
@TypeConverters([IntListConverter])
class Task extends BaseClass<Task> {
  final String message;

  final bool? isRead;

  @TestAnnotation()
  @TypeConverters([DateTimeConverter, TaskTypeConverter])
  final DateTime timestamp;

  @TestAnnotation()
  final TaskStatus status;

  @TypeConverters([TaskTypeConverter])
  final TaskType? type;

  final List<int>? integers;

  final Uint8List? attachment;

  // TODO ignored field is remove in drift
  // TODO could be added with @CustomRowClass
  // @ignore
  // final String tempText;

  final double customDouble;

  @ignore
  String setterGetterTest = "";

  // synthetic getter should be ignored
  String get getterIgnoreTest => setterGetterTest;

  // synthetic setter should be ignored
  set setterIgnoreTest(String value) => setterGetterTest = value;

  // getter and setter sets should be ignored also
  String get setterGetterSet => setterGetterTest;

  // getter and setter sets should be ignored also
  set setterGetterSet(String value) => setterGetterTest = value;

  Task({
    super.id,
    this.isRead,
    this.message = "default",
    required this.timestamp,
    required this.status,
    this.type,
    this.integers,
    this.attachment,
    // this.tempText = "tempText",
    required this.customDouble,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {
      ...super.toColumns(nullToAbsent),
      "isRead": Variable(isRead),
      "message": Variable(message),
      "timestamp": Variable(const drift.DateTimeConverter().toSql(timestamp)),
      "status": Variable(status.index),
      "type": Variable(const drift.TaskTypeConverter().toSql(type)),
      "integers": Variable(const drift.IntListConverter().toSql(integers)),
      "attachment": Variable(attachment),
      "customDouble": Variable(customDouble),
    };
  }

  copyWithMessage(String message) {
    return Task(
      id: id,
      status: status,
      timestamp: timestamp,
      customDouble: customDouble,
      integers: integers,
      isRead: isRead,
      message: message,
      attachment: attachment,
      type: type,
    );
  }
}
