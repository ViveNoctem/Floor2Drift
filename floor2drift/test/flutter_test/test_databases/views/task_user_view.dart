import 'dart:typed_data';

import 'package:floor_annotation/floor_annotation.dart';

import '../support_classes/enums.dart';
import '../type_converters/type_converters.dart';

@TypeConverters([IntListConverter])
@DatabaseView(
  'SELECT '
  'UserTest.name, '
  'UserTest.password, '
  'UserTest.creation_date, '
  'taskTest.message, '
  'taskTest.isRead, '
  'taskTest.timestamp, '
  'taskTest.status, '
  'taskTest.type, '
  'taskTest.integers, '
  'taskTest.attachment, '
  'taskTest.cUsToMdOuBlE, '
  'taskTest.DifFeReNt_StRiNg '
  'FROM UserTest JOIN taskTest ON UserTest.id = taskTest.id',
)
class TaskUserView {
  // final int? id;

  final String? name;

  final String? password;

  @TypeConverters([DateTimeConverter])
  @ColumnInfo(name: "creation_date")
  final DateTime createdAt;

  // some message
  final String message;

  /// Documentation for isRead
  final bool? isRead;

  @TypeConverters([DateTimeConverter, TaskTypeConverter])
  final DateTime timestamp;

  final TaskStatus status;

  @TypeConverters([TaskTypeConverter])
  final TaskType? type;

  final List<int>? integers;

  final Uint8List? attachment;

  @ColumnInfo(name: "cUsToMdOuBlE")
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

  @ColumnInfo(name: "DifFeReNt_StRiNg")
  final String? renamedString;

  TaskUserView(
    // this.id,
    this.name,
    this.password,
    this.createdAt,
    this.message,
    this.isRead,
    this.timestamp,
    this.status,
    this.type,
    this.integers,
    this.attachment,
    this.customDouble,
    this.renamedString,
  );

  @override
  bool operator ==(Object other) {
    if (other is! TaskUserView) {
      return false;
    }
    // TODO integers and attachment is being ignored

    return name == other.name &&
        password == other.password &&
        createdAt == other.createdAt &&
        message == other.message &&
        isRead == other.isRead &&
        timestamp == other.timestamp &&
        status == other.status &&
        type == other.type &&
        // integers == other.integers &&
        // attachment == other.attachment &&
        customDouble == other.customDouble &&
        renamedString == other.renamedString;
  }
}
