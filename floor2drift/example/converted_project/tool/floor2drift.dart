import 'package:floor2drift/floor2drift.dart';

void main(List<String> arguments) async {
  final dbLocation = "../lib/floor/database.dart";

  BuildRunner(dbPath: dbLocation).start();
}
