import 'package:drift/drift.dart';

mixin ExampleBaseClassMixin on Table {
  IntColumn get id => integer().nullable().autoIncrement()();
}
