import 'package:drift/drift.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:initial_project/floor/base_class.dart';

import '../enums.dart';
import '../type_converters.dart';
import '../type_convertersDrift.dart' as drift;

@Entity()
@TypeConverters([IntListConverter])
class ExampleTask extends ExampleBaseClass<ExampleTask> {
  final String message;

  final int userId;

  @TypeConverters([DateTimeConverter])
  final DateTime timestamp;

  final TaskStatus status;

  final TaskType? type;

  final Uint8List? attachment;

  ExampleTask({
    super.id,
    required this.userId,
    this.message = "default",
    required this.timestamp,
    required this.status,
    this.type,
    this.attachment,
  });

  ExampleTask.open({
    super.id,
    required this.userId,
    required this.message,
    DateTime? timeStamp,
    this.status = TaskStatus.open,
    this.type,
    this.attachment,
  }) : timestamp = timeStamp ?? DateTime.now();

  ExampleTask copyWith({
    String? message,
    int? userId,
    DateTime? timestamp,
    TaskStatus? status,
    TaskType? type,
    Uint8List? attachment,
  }) {
    return ExampleTask(
      id: id,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      attachment: attachment ?? this.attachment,
    );
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {
      ...super.toColumns(nullToAbsent),
      "message": Variable(message),
      "userId": Variable(userId),
      "timestamp": Variable(const drift.DateTimeConverter().toSql(timestamp)),
      "status": Variable(status.index),
      "type": Variable(type?.index),
      "attachment": Variable(attachment),
    };
  }
}
