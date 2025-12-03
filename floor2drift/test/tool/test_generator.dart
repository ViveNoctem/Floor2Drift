import 'package:floor2drift/src/base_classes/floor_2_drift_generator.dart';

void main(List<String> arguments) async {
  final rootDir = "../../";

  final dbLocation = "../flutter_test/test_databases/floor_test_database.dart";

  final generator = Floor2DriftGenerator(
    dbPath: dbLocation,
    rootPath: rootDir,
    // classNameFilter: Glob("*task*", caseSensitive: false),
  );

  generator.start();
}
