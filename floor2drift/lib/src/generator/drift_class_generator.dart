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
  bool getImport(LibraryReader library) {
    for (final annotatedElement in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (inputOption.canAnalyze(annotatedElement.element.name ?? "") == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  /// Returns Dart Code String, Set of Imports and the result of the builder
  (GeneratedSource, S) generateForAnnotatedElement(
    ClassElement element,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  );
}
