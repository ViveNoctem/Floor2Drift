import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/input_option.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:source_gen/source_gen.dart';

abstract class AnnotationGenerator<T, S> {
  final bool throwOnUnresolved;

  final InputOptionBase inputOption;

  TypeChecker get typeChecker => TypeChecker.fromRuntime(T);

  const AnnotationGenerator({required this.inputOption, this.throwOnUnresolved = true});

  FutureOr<(GeneratedSource, S)> generateClass(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) async {
    final result = generateForAnnotatedElement(classElement, outputOption, dbState);

    return result;
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
  (GeneratedSource, S) generateForAnnotatedElement(
    ClassElement element,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  );
}
