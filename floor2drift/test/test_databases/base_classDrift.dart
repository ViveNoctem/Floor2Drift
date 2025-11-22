import 'package:drift/drift.dart';

mixin BaseClassMixin on Table {
  IntColumn get id => integer().nullable().autoIncrement()();
}
