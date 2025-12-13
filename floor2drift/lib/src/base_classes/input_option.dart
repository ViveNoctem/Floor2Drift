import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:floor2drift/floor2drift.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

/// {@template InputOptionBase}
/// All options for the [Floor2DriftGenerator] which classes should be converted
/// {@endtemplate}
abstract class InputOptionBase {
  /// Root directory of the flutter project
  final FileSystemEntity root;

  /// File that contains the floor database
  final File dbFile;

  final PhysicalResourceProvider _provider;
  late final AnalysisContextCollection _analysisContextCollection;

  /// Should [TypeConverter] be converted
  final bool convertDbTypeConverters;

  /// Should [dao] classes be converted
  final bool convertDbDaos;

  /// Should [entity] classes be converted
  final bool convertDbEntities;

  /// [Glob] used to filter the names of classes, that should be converted
  final Glob glob;

  // final List<Migration> migrations;

  /// {@macro InputOptionBase}
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

  /// Iterates through all available [AnalysisContext]s and return the normalized db path and the context
  Iterable<(String, AnalysisContext)> getDatabaseFile();

  /// does the give [elementName] fulfill the [glob] and should be converted by the generator
  bool canAnalyze(String elementName);
}

/// {@macro InputOptionBase}
class InputOptions extends InputOptionBase {
  /// {@macro InputOptionBase}
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
  Iterable<(String, AnalysisContext)> getDatabaseFile() sync* {
    for (final context in _analysisContextCollection.contexts) {
      final normalizedPath = path.normalize(dbFile.absolute.path);

      if (context.contextRoot.isAnalyzed(normalizedPath) == false) {
        continue;
      }

      yield (normalizedPath, context);
    }
  }
}
