import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/input_option.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/generator/base_entity_generator.dart';
import 'package:floor2drift/src/generator/dao_generator.dart';
import 'package:floor2drift/src/generator/database_generator.dart';
import 'package:floor2drift/src/generator/entity_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:source_gen/source_gen.dart';

import '../generator/class_generator.dart';

abstract class ProcessingOptionBase {
  late final List<AnnotationGenerator> generators;
  final OutputOptionBase outputOption;

  final DatabaseGenerator databaseGenerator;

  final BaseDaoGenerator? baseDaoGenerator;
  final DaoGenerator? daoGenerator;
  final BaseEntityGenerator? baseEntityGenerator;
  final EntityGenerator? entityGenerator;
  final TypeConverterGenerator? typeConverterGenerator;

  ProcessingOptionBase({
    required this.databaseGenerator,
    required this.outputOption,
    required this.baseDaoGenerator,
    required this.daoGenerator,
    required this.baseEntityGenerator,
    required this.entityGenerator,
    required this.typeConverterGenerator,
  }) {
    // TODO replace with null-aware elements if possible
    generators = [
      if (baseDaoGenerator != null) baseDaoGenerator!,
      if (daoGenerator != null) daoGenerator!,
      if (baseEntityGenerator != null) baseEntityGenerator!,
      if (entityGenerator != null) entityGenerator!,
      if (typeConverterGenerator != null) typeConverterGenerator!,
      databaseGenerator,
    ];
  }

  Future<DatabaseState?> processDatabaseGenerator(AnalysisContext context, String path, InputOptionBase inputOption);

  Future<(GeneratedSource, List<S>)> processClassElement<T, S>(
    ClassElement classElement,
    DatabaseState dbState,
    AnnotationGenerator<T, S> generator,
  );
}

class ProcessingOptions extends ProcessingOptionBase {
  ProcessingOptions({
    required super.databaseGenerator,
    required super.outputOption,
    required super.baseDaoGenerator,
    required super.daoGenerator,
    required super.baseEntityGenerator,
    required super.entityGenerator,
    required super.typeConverterGenerator,
  });

  @override
  Future<DatabaseState?> processDatabaseGenerator(
    AnalysisContext context,
    String path,
    InputOptionBase inputOption,
  ) async {
    AnalysisSession session = context.currentSession;

    var resolved = await session.getResolvedUnit(path);

    if (resolved is! ResolvedUnitResult) {
      print("Couldn't resolve unit");
      return null;
    }

    final reader = LibraryReader(resolved.libraryElement);
    return databaseGenerator.generateDatabaseState(reader, inputOption);
  }

  @override
  Future<(GeneratedSource, List<S>)> processClassElement<T, S>(
    ClassElement classElement,
    DatabaseState dbState,
    AnnotationGenerator<T, S> generator,
  ) async {
    var generatedSource = GeneratedSource.empty();
    final generatorResult = <S>[];

    final libraryImports = classElement.library.definingCompilationUnit.libraryImports;

    for (final library in libraryImports) {
      var importString = library.uri;

      if (importString is! DirectiveUriWithLibrary) {
        print("Uri is not DirectiveUriWithLibrary");
        continue;
      }

      // ignore dart:core import
      if (importString.relativeUriString == "dart:core") {
        continue;
      }

      // ignore floor import
      if (importString.relativeUriString == "package:floor/floor.dart") {
        continue;
      }

      // TODO way to remove imports should be added to the generator itself
      // floor_annotations import doesn't work with Dao and BaseDao
      if (importString.relativeUriString == 'package:floor_annotation/floor_annotation.dart' &&
          (generator is DaoGenerator || generator is BaseDaoGenerator)) {
        continue;
      }

      final reader2 = LibraryReader(importString.library);

      var changed = false;

      for (final generator in generators) {
        if (generator.getImport(reader2)) {
          changed = true;
          break;
        }
      }

      final newImportString = outputOption.rewriteImport((changed, importString));
      generatedSource = generatedSource.copyWith(imports: {...generatedSource.imports, newImportString});
    }

    final (generatedSourceResult, result) = await generator.generateClass(classElement, outputOption, dbState);

    generatedSource += generatedSourceResult;

    generatorResult.add(result);

    if (generatedSource.isNotEmpty) {
      return (generatedSource, generatorResult);
    } else {
      return (GeneratedSource.empty(), <S>[]);
    }
  }
}
