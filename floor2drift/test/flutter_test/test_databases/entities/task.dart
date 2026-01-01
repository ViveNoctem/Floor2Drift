import 'package:drift/drift.dart';
import 'package:floor_annotation/floor_annotation.dart';

import '../../additional_classes/annotation.dart';
import '../support_classes/enums.dart';
import '../support_classes/interfaces.dart';
import '../type_converters/type_converters.dart';
import '../type_converters/type_converters_drift.dart' as drift;
import 'base_class.dart';
import 'task_drift.dart';

@Entity(tableName: "UserTest")
class TestUser implements Insertable<TestUser> {
  @primaryKey
  final int id;

  final String name;

  final String password;

  @TypeConverters([DateTimeConverter])
  @ColumnInfo(name: "creation_date")
  final DateTime createdAt;

  const TestUser({required this.name, required this.password, required this.id, required this.createdAt});

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return TestUsers.toColumns(nullToAbsent, this);
  }

  @override
  bool operator ==(Object other) {
    if (other is! TestUser) {
      return false;
    }

    return identical(this, other) ||
        runtimeType == other.runtimeType && id == other.id && name == other.name && password == other.password;
  }
}

/// Documentation for TestTask entity
@Entity(tableName: "taskTest")
@TypeConverters([IntListConverter])
class TestTask extends BaseClass<TestTask> implements InterfaceThree, InterfaceFour {
  // some message
  final String message;

  /// Documentation for isRead
  final bool? isRead;

  /// Multi
  ///
  /// Line
  /// doc comment for
  /// timestamp
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

  TestTask({
    super.id,
    this.isRead,
    this.message = "default",
    required this.timestamp,
    required this.status,
    this.type = TaskType.story,
    this.integers,
    // DO NOT REMOVE redundant initializer. generator should not include null initialization
    // ignore: avoid_init_to_null
    this.attachment = null,
    // this.tempText = "tempText",
    required this.customDouble,
    super.renamedString,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {
      ...super.toColumns(nullToAbsent),
      ...TestTasks.toColumns(nullToAbsent, this),
    };
  }

  copyWithMessage(String message) {
    return TestTask(
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
