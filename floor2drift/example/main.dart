// For more information on using floor2drift, please see https://github.com/ViveNoctem/Floor2Drift#getting-started
import 'package:floor2drift/src/base_classes/floor_2_drift_generator.dart';
import 'package:glob/glob.dart';

void main(List<String> arguments) async {
  final generator = Floor2DriftGenerator(
    dbPath: "../test_databases/floor_test_database.dart",
    rootPath: "../",
    classNameFilter: Glob("*task*", caseSensitive: false),
  );

  generator.start();
}
