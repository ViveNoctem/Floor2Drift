import 'package:floor2drift/src/build_runner/build_runner.dart';
import 'package:glob/glob.dart';

void main(List<String> arguments) async {
  final rootDir = "../../";

  final dbLocation = "../flutter_test/test_databases/floor_test_database.dart";

  final buildRunner = BuildRunner(
    dbPath: dbLocation,
    rootPath: rootDir,
    classNameFilter: Glob("*task*", caseSensitive: false),
  );

  buildRunner.start();
}
