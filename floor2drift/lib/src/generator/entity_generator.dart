import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/helper/annotation_helper.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:recase/recase.dart';
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
  (GeneratedSource, MapEntry<String, (Set<ClassElement>, List<String>)>) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) {
    staticClassNameSuffix = classNameSuffix;
    var result = "";

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final import = BaseHelper.getImport(classElement.library.librarySource.uri, targetFilePath);

    final newImports = <String>{if (import != null) import};

    final data = classHelper.generateInheritanceFields(classElement, dbState);

    switch (data) {
      case ValueError():
        throw InvalidGenerationSource(data.error, element: data.element);
      case ValueData<(String, String, Set<ClassElement>, List<String>)>():
        break;
    }

    final floorTableName = _getFloorTableName(classElement);
    dbState.entityTableMap[classElement] = floorTableName;
    dbState.tableEntityMap[floorTableName.toLowerCase()] = classElement;

    final (fieldsString, mixinString, usedTypeConverters, convertedFields) = data.data;

    final className = classHelper.getClassName(classElement.name, staticClassNameSuffix);

    BaseHelper.addToDriftClassesMap(classElement, className, outputOption, dbState.driftClasses);

    result += classHelper.getClassHeader(classElement.name, mixinString, staticClassNameSuffix, useRowClass);
    result += _getTableName(tableName, classElement);
    result += fieldsString;
    result += classHelper.closeClass();

    final generatedSource = GeneratedSource(code: result, imports: newImports);

    return (generatedSource, MapEntry(ReCase(classElement.name).pascalCase, (usedTypeConverters, convertedFields)));
  }

  String _getTableName(ETableNameOption tableName, ClassElement classElement) {
    return switch (tableName) {
      ETableNameOption.driftScheme => "",
      ETableNameOption.floorScheme => _overideTablename(_getFloorTableName(classElement)),
      ETableNameOption.driftSchemeWithOverride => _overideTablename(_getDriftCustomTableName(classElement)),
    };
  }

  String _overideTablename(String newTableName) {
    if (newTableName.isEmpty) {
      return "";
    }

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
      return overrideTableName;
    }

    return classElement.name;
  }

  String _getDriftCustomTableName(ClassElement classElement) {
    final entityAnnotation = annotationHelper.getEntityAnnotation(classElement);

    if (entityAnnotation == null) {
      return "";
    }

    final overrideTableName = annotationHelper.getEntityAnnotationTableName(entityAnnotation);

    if (overrideTableName.isNotEmpty) {
      return overrideTableName;
    }

    // if not specified in Annotation use Drift scheme
    return "";
  }
}
