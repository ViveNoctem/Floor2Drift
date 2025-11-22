import 'package:drift/drift.dart';
import 'package:initial_project/floor/user.dart';

@UseRowClass(ExampleUser)
class ExampleUsers extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get userName => text()();
  TextColumn get password => text()();
}
