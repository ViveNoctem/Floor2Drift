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
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/entity_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:floor2drift/src/generator/view_generator.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template ProcessingOptionBase}
/// All options for the [Floor2DriftGenerator] on how to process the floor database
/// {@endtemplate}
abstract class ProcessingOptionBase {
  /// contains all generators that will be used
  late final List<DriftClassGenerator> generators;

  /// The Output options that will be used
  final OutputOptionBase outputOption;

  /// The [DatabaseGenerator] used while converting
  final DatabaseGenerator databaseGenerator;

  /// The generator for base dao classes
  ///
  /// is null if base dao classes are not generated
  final BaseDaoGenerator? baseDaoGenerator;

  /// The generator for dao classes
  ///
  /// is null if dao classes are not generated
  final DaoGenerator? daoGenerator;

  /// The generator for base entity classes
  ///
  /// is null if base entity classes are not generated
  final BaseEntityGenerator? baseEntityGenerator;

  /// The generator for entitiy classes
  ///
  /// is null if entity classes are not generated
  final EntityGenerator? entityGenerator;

  /// The generator for type converters
  ///
  /// is null if type converters are not generated
  final TypeConverterGenerator? typeConverterGenerator;

  final ViewGenerator? viewGenerator;

  /// {@macro ProcessingOptionBase}
  ProcessingOptionBase({
    required this.databaseGenerator,
    required this.outputOption,
    required this.baseDaoGenerator,
    required this.daoGenerator,
    required this.baseEntityGenerator,
    required this.entityGenerator,
    required this.typeConverterGenerator,
    required this.viewGenerator,
  }) {
    // TODO replace with null-aware elements if possible
    generators = [
      if (baseDaoGenerator != null) baseDaoGenerator!,
      if (daoGenerator != null) daoGenerator!,
      if (baseEntityGenerator != null) baseEntityGenerator!,
      if (entityGenerator != null) entityGenerator!,
      if (typeConverterGenerator != null) typeConverterGenerator!,
      databaseGenerator,
      if (viewGenerator != null) viewGenerator!,
    ];
  }

  /// Generates the [DatabaseState] for the floor database
  ///
  /// throws [InvalidGenerationSource] exception if multiple [Database] classes are in one class
  Future<DatabaseState?> processDatabaseGenerator(AnalysisContext context, String path, InputOptionBase inputOption);

  /// processes a Class with the given [DriftClassGenerator]
  (GeneratedSource, List<S>) processClassElement<T, S>(
    ClassElement classElement,
    DatabaseState dbState,
    DriftClassGenerator<T, S> generator,
  );
}

/// {@macro ProcessingOptionBase}
class ProcessingOptions extends ProcessingOptionBase {
  /// {@macro ProcessingOptionBase}
  ProcessingOptions({
    required super.databaseGenerator,
    required super.outputOption,
    required super.baseDaoGenerator,
    required super.daoGenerator,
    required super.baseEntityGenerator,
    required super.entityGenerator,
    required super.typeConverterGenerator,
    required super.viewGenerator,
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
  (GeneratedSource, List<S>) processClassElement<T, S>(
    ClassElement classElement,
    DatabaseState dbState,
    DriftClassGenerator<T, S> generator,
  ) {
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

      final reader2 = LibraryReader(importString.library);

      var changed = false;

      for (final importGenerator in generators) {
        if (importGenerator.getImport(
          reader2,
          dbState,
          generator is EntityGenerator || generator is BaseEntityGenerator,
        )) {
          changed = true;
          break;
        }
      }

      final newImportString = outputOption.rewriteImport(changed, importString);
      generatedSource = generatedSource.copyWith(imports: {...generatedSource.imports, newImportString});
    }

    final (generatedSourceResult, result) = generator.generateForAnnotatedElement(
      classElement,
      outputOption,
      dbState,
      generatedSource,
    );

    generatorResult.add(result);

    if (generatedSourceResult.isNotEmpty) {
      return (generatedSourceResult, generatorResult);
    } else {
      return (GeneratedSource.empty(), <S>[]);
    }
  }
}
