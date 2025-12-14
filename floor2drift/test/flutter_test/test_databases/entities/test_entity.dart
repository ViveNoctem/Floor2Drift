import 'package:floor/floor.dart';
// DO NOT REMOVE. Needed to test if Table class is hidden
// ignore: unused_import needed to test if table is being hidden
import "package:flutter/cupertino.dart";
// ignore: unused_import needed to test if table is being hidden
import 'package:flutter/material.dart';

import '../support_classes/enums.dart';
import 'test_base_entity_two.dart';

@Entity(tableName: "entityEntity")
// TODO uncomment if not used classes are being ignored in import rewriting
// @TypeConverters([NotUsedTypeConverter])
class TestEntity extends TestBaseEntityTwo {
  @primaryKey
  final int id;
  final UserStatus status;
  final String stringConverted;

  const TestEntity({required this.id, this.status = UserStatus.active, this.stringConverted = "default value"});
}
