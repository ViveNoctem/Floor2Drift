import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/generator/class_generator.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class BaseEntityGenerator
    extends AnnotationGenerator<ConvertBaseEntity, MapEntry<String, (Set<ClassElement>, List<String>)>> {
  final ClassHelper classHelper;

  BaseEntityGenerator({this.classHelper = const ClassHelper(), required super.inputOption});

  @override
  FutureOr<bool> getImport(LibraryReader library) {
    for (final _ in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      return true;
    }

    return false;
  }

  @override
  (String, Set<String>, MapEntry<String, (Set<ClassElement>, List<String>)>) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) {
    var result = "";

    final valueResult = classHelper.generateInheritanceFields(classElement, dbState);

    switch (valueResult) {
      case ValueError<(String, String, Set<ClassElement>, List<String>)>():
        throw InvalidGenerationSource(valueResult.error, element: valueResult.element);
      case ValueData<(String, String, Set<ClassElement>, List<String>)>():
        break;
    }

    final (fieldsString, mixinString, usedTypeConverters, convertedFields) = valueResult.data;

    final mixinName = "${classElement.name}${ClassHelper.mixinSuffix}";

    BaseHelper.addToDriftClassesMap(classElement, mixinName, outputOption, dbState.driftClasses);

    result += classHelper.getMixinHeader(mixinName);
    result += fieldsString;
    result += classHelper.closeClass();

    return (result, const {}, MapEntry(ReCase(classElement.name).pascalCase, (usedTypeConverters, convertedFields)));
  }
}
