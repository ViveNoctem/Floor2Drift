import 'dart:typed_data';

import 'package:floor/floor.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:initial_project/floor/base_class.dart';

import '../enums.dart';
import '../type_converters.dart';

@Entity()
@TypeConverters([IntListConverter])
class ExampleTask extends ExampleBaseClass<ExampleTask> {
  final String message;

  // TODO add as a migration?
  // final bool? isHighlighted;

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
}
