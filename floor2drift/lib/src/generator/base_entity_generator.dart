import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/build_runner/annotation_generator.dart';
import 'package:floor2drift/src/build_runner/database_state.dart';
import 'package:floor2drift/src/build_runner/output_option.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:source_gen/source_gen.dart';

class BaseEntityGenerator
    extends AnnotationGenerator<ConvertBaseEntity, MapEntry<String, (Set<ClassElement>, List<String>)>> {
  final ClassHelper classHelper;

  BaseEntityGenerator({this.classHelper = const ClassHelper(), required super.inputOption});

  // TODO baseEntity gets added because its a super class of an generated Class
  // TODO the canAnalyze doesn't work.
  // TODO Just always generate at the moment
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
    // TODO BaseEntityGenerator should probably be deactivated if useRowClass for the entityGenerator is true.
    var result = "";

    final valueResult = classHelper.generateInheritanceFields(classElement, dbState.typeConverterMap);

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

    return (result, const {}, MapEntry(classElement.name, (usedTypeConverters, convertedFields)));
  }
}
