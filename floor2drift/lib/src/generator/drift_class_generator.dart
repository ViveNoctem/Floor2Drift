import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/input_option.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:source_gen/source_gen.dart';

/// {@template DriftClassGenerator}
/// Class to convert a specific type of Class to the drift equivalent
/// {@endtemplate}
abstract class DriftClassGenerator<T, S> {
  /// shoud the typeChecker throw an exception on an unresolved class
  final bool throwOnUnresolved;

  /// InputOptions
  final InputOptionBase inputOption;

  /// TypeChecker for the annotation of current class type
  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  /// {@macro DriftClassGenerator}
  const DriftClassGenerator({required this.inputOption, this.throwOnUnresolved = true});

  /// returns if the generator would generate code for the given library
  ///
  /// [ignoreTypeConverterUsedCheck] should be set if this method is called inside a (base-)entity
  bool getImport(LibraryReader library, DatabaseState dbState, bool ignoreTypeConverterUsedCheck) {
    for (final annotatedElement in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (inputOption.canAnalyze(annotatedElement.element.name ?? "") == false) {
        continue;
      }

      if (DriftClassGenerator.isInDatabaseState(library, dbState) == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  /// looks through [dbState] and return if [library] is contained in the database being converted
  static bool isInDatabaseState(LibraryReader library, DatabaseState dbState) {
    final dbLibrary = dbState.databaseClass.element?.library;

    if (dbLibrary != null && dbLibrary == library.element) {
      return true;
    }

    for (final state in dbState.entityClassStates) {
      final classLibrary = state.classType.element?.library;

      for (final typeConverter in state.usedTypeConverters) {
        if (typeConverter.classElement.library == library.element) {
          return true;
        }
      }

      if (state.superStates != null) {
        for (final superClass in state.superStates!) {
          if (superClass.classType.element?.library == library.element) {
            return true;
          }
        }
      }
      if (classLibrary == null) {
        continue;
      }

      if (classLibrary == library.element) {
        return true;
      }
    }

    // TODO should be removed if possible.
    // TODO in (base-)entity generator dbState is not filled
    // TODO dao classes are not in the dbState
    for (final floorClass in dbState.floorClasses.values) {
      if (floorClass.library == library.element) {
        return true;
      }
    }

    return false;
  }

  /// Returns Dart Code String, Set of Imports and the result of the builder
  (GeneratedSource, S) generateForAnnotatedElement(
    ClassElement element,
    OutputOptionBase outputOption,
    DatabaseState dbState,
    GeneratedSource currentSource,
  );
}
