import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/build_runner/database_state.dart';
import 'package:floor2drift/src/build_runner/input_option.dart';
import 'package:floor2drift/src/build_runner/output_option.dart';
import 'package:source_gen/source_gen.dart';

abstract class AnnotationGenerator<T, S> {
  final bool throwOnUnresolved;

  final InputOptionBase inputOption;

  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  const AnnotationGenerator({required this.inputOption, this.throwOnUnresolved = true});

  FutureOr<(String, Set<String>, S)> generateClass(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) async {
    final (value, imports, result) = generateForAnnotatedElement(classElement, outputOption, dbState);

    return ("$value\n\n", imports, result);
  }

  /// returns if the generator would generate code for the given library
  FutureOr<bool> getImport(LibraryReader library) {
    for (final annotatedElement in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (inputOption.canAnalyze(annotatedElement.element.name ?? "") == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  /// Returns Dart Code String, Set of Imports and the result of the builder
  (String, Set<String>, S) generateForAnnotatedElement(
    ClassElement element,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  );
}
