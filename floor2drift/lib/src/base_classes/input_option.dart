import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

abstract class InputOptionBase {
  final FileSystemEntity root;

  final File dbFile;

  final PhysicalResourceProvider _provider;
  late final AnalysisContextCollection _analysisContextCollection;

  final bool convertDbTypeConverters;
  final bool convertDbDaos;
  final bool convertDbEntities;

  final Glob glob;

  // final List<Migration> migrations;

  InputOptionBase({
    required this.root,
    required this.convertDbTypeConverters,
    required this.convertDbDaos,
    required this.convertDbEntities,
    required this.dbFile,
    required this.glob,
    // this.migrations = const [],
  }) : _provider = PhysicalResourceProvider(stateLocation: root.absolute.path) {
    _analysisContextCollection = AnalysisContextCollection(
      includedPaths: [_provider.pathContext.normalize(root.absolute.path)],
    );
  }

  Iterable<(String, AnalysisContext)> getFiles();

  bool canAnalyze(String elementName);
}

class InputOptions extends InputOptionBase {
  InputOptions({
    required super.glob,
    required super.root,
    required super.convertDbTypeConverters,
    required super.convertDbDaos,
    required super.convertDbEntities,
    required super.dbFile,
    // super.migrations,
  });

  @override
  bool canAnalyze(String elementName) {
    return glob.matches(elementName);
  }

  @override
  Iterable<(String, AnalysisContext)> getFiles() sync* {
    for (final context in _analysisContextCollection.contexts) {
      final normalizedPath = path.normalize(dbFile.absolute.path);

      if (context.contextRoot.isAnalyzed(normalizedPath) == false) {
        continue;
      }

      yield (normalizedPath, context);
    }
  }
}
