import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/build_runner/database_state.dart';
import 'package:floor2drift/src/build_runner/input_option.dart';
import 'package:floor2drift/src/build_runner/output_option.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/generator/base_entity_generator.dart';
import 'package:floor2drift/src/generator/dao_generator.dart';
import 'package:floor2drift/src/generator/database_generator.dart';
import 'package:floor2drift/src/generator/entity_generator.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation_generator.dart';

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

  Future<(String, String, List<S>)> processClassElement<T, S>(
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

    // TODO now we must resolve all files twice.
    // TODO fixed if the keep the databaseOnly approach
    var resolved = await session.getResolvedUnit(path);

    if (resolved is! ResolvedUnitResult) {
      print("Couldn't resolve unit");
      return null;
    }

    final reader = LibraryReader(resolved.libraryElement);
    return databaseGenerator.generateDatabaseState(reader, inputOption);
  }

  @override
  Future<(String, String, List<S>)> processClassElement<T, S>(
    ClassElement classElement,
    DatabaseState dbState,
    AnnotationGenerator<T, S> generator,
  ) async {
    var values = <String>{};

    final imports = <String>{};
    final generatorResult = <S>[];

    final libraryImports = classElement.library.definingCompilationUnit.libraryImports;

    // TODO check if the libaryReader is needed an correct.
    final libraryReader = LibraryReader(classElement.library);

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

      if (importString.relativeUriString == "package:floor/floor.dart") {
        // TODO When to add drift import
        // TODO Removes the floor import and adds drift import
        imports.add("import 'package:drift/drift.dart';");
        continue;
      }

      // TODO floor_annotations doesn't work with Dao and BaseDao
      // TODO delete annotation overrides floor delete
      // TODO add something to remove imports in generator?
      if (importString.relativeUriString == 'package:floor_annotation/floor_annotation.dart' &&
          (generator is DaoGenerator || generator is BaseDaoGenerator)) {
        continue;
      }

      // TODO Add part directives?

      final reader2 = LibraryReader(importString.library);

      var changed = false;

      for (final generator in generators) {
        if (await generator.getImport(reader2)) {
          changed = true;
          break;
        }
      }

      // TODO currentFile always changed because we only use the generator on changed files
      final newImportString = outputOption.rewriteImport((changed, importString), (true, libraryReader));
      imports.add(newImportString);
    }

    final (text, newImports, result) = await generator.generateClass(classElement, outputOption, dbState);

    imports.addAll(newImports);
    values.add(text);
    generatorResult.add(result);

    var returnValue = values.join("\n\n");

    if (returnValue.trim().isNotEmpty) {
      return (imports.join("\n"), returnValue, generatorResult);
    } else {
      return ("", "", <S>[]);
    }
  }
}
