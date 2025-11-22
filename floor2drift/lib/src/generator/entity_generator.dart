import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/build_runner/annotation_generator.dart';
import 'package:floor2drift/src/build_runner/database_state.dart';
import 'package:floor2drift/src/build_runner/output_option.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/annotation_helper.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

class EntityGenerator extends AnnotationGenerator<Entity, MapEntry<String, (Set<ClassElement>, List<String>)>> {
  static List<String> generatedMixins = List.empty(growable: true);

  static String staticClassNameSuffix = "";
  final String classNameSuffix;
  final bool useRowClass;
  final ETableNameOption tableName;
  final ClassHelper classHelper;
  final AnnotationHelper annotationHelper;

  EntityGenerator({
    required this.classNameSuffix,
    required this.useRowClass,
    this.classHelper = const ClassHelper(),
    this.annotationHelper = const AnnotationHelper(),
    required super.inputOption,
    required this.tableName,
  });

  @override
  (String, Set<String>, MapEntry<String, (Set<ClassElement>, List<String>)>) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) {
    staticClassNameSuffix = classNameSuffix;
    var result = "";

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final import = BaseHelper.getImport(classElement.library.librarySource.uri, targetFilePath);

    final newImports = <String>{if (import != null) import};

    final data = classHelper.generateInheritanceFields(classElement, dbState.typeConverterMap);

    switch (data) {
      case ValueError():
        throw InvalidGenerationSource(data.error, element: data.element);
      case ValueData<(String, String, Set<ClassElement>, List<String>)>():
        break;
    }

    final (fieldsString, mixinString, usedTypeConverters, convertedFields) = data.data;

    final className = classHelper.getClassName(classElement.name, staticClassNameSuffix);

    BaseHelper.addToDriftClassesMap(classElement, className, outputOption, dbState.driftClasses);

    result += classHelper.getClassHeader(classElement.name, mixinString, staticClassNameSuffix, useRowClass);
    result += _getTableName(tableName, classElement);
    result += fieldsString;
    result += classHelper.closeClass();
    // TODO Test name
    return (result, newImports, MapEntry(classElement.name, (usedTypeConverters, convertedFields)));
  }

  String _getTableName(ETableNameOption tableName, ClassElement classElement) {
    return switch (tableName) {
      ETableNameOption.driftScheme => "",
      ETableNameOption.floorScheme => _getFloorTableName(classElement),
      ETableNameOption.driftSchemeWithOverride => _getDriftCustomTableName(classElement),
    };
  }

  String _overideTablename(String newTableName) {
    return """
    @override
    String? get tableName => "$newTableName";
    """;
  }

  String _getFloorTableName(ClassElement classElement) {
    final entityAnnotation = annotationHelper.getEntityAnnotation(classElement);

    if (entityAnnotation == null) {
      return "";
    }

    final overrideTableName = annotationHelper.getEntityAnnotationTableName(entityAnnotation);

    if (overrideTableName.isNotEmpty) {
      return _overideTablename(overrideTableName);
    }

    return _overideTablename(classElement.name);
  }

  String _getDriftCustomTableName(ClassElement classElement) {
    final entityAnnotation = annotationHelper.getEntityAnnotation(classElement);

    if (entityAnnotation == null) {
      return "";
    }

    final overrideTableName = annotationHelper.getEntityAnnotationTableName(entityAnnotation);

    if (overrideTableName.isNotEmpty) {
      return _overideTablename(overrideTableName);
    }

    // if not specified in Annotation use Drift scheme
    return "";
  }
}
