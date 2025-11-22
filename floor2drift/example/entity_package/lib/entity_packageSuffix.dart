import 'package:drift/drift.dart';
import 'package:entity_package/entity_package.dart';

@UseRowClass(ExampleUser2)
class ExampleUser2s extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get userName => text()();
  TextColumn get password => text()();
}
