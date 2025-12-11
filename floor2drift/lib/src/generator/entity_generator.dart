import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/entity/annotation_converter/classState.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:floor2drift/src/helper/annotation_helper.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

class EntityGenerator extends AnnotationGenerator<Entity, ClassState> {
  static List<String> generatedMixins = List.empty(growable: true);

  static String staticClassNameSuffix = "";
  final String classNameSuffix;
  final bool useRowClass;
  final ETableNameOption tableName;
  final ClassHelper classHelper;
  final AnnotationHelper annotationHelper;
  final TypeConverterGenerator? typeConverterGenerator;

  EntityGenerator({
    required this.typeConverterGenerator,
    required this.classNameSuffix,
    required this.useRowClass,
    this.classHelper = const ClassHelper(),
    this.annotationHelper = const AnnotationHelper(),
    required super.inputOption,
    required this.tableName,
  });

  @override
  (GeneratedSource, ClassState) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) {
    staticClassNameSuffix = classNameSuffix;
    var result = "";

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final import = BaseHelper.getImport(classElement.library.librarySource.uri, targetFilePath);

    final newImports = <String>{if (import != null) import};

    // alway add drift import
    newImports.add("import 'package:drift/drift.dart';");

    final data = classHelper.generateInheritanceFields(classElement, dbState);

    switch (data) {
      case ValueError():
        throw InvalidGenerationSource(data.error, element: data.element);
      case ValueData<(String, ClassState)>():
    }

    final (fieldsCode, classState) = data.data;

    final className = classHelper.getClassName(classElement.name, staticClassNameSuffix);

    // add mixin/base entity imports
    for (final mixin in classState.superClasses) {
      var importString = BaseHelper.getImport(mixin.librarySource.uri, targetFilePath);

      if (importString == null) {
        continue;
      }

      importString = outputOption.rewriteExistingImport(importString);
      newImports.add(importString);
    }

    // add typeConverter imports
    for (final typeConverter in classState.usedTypeConverters) {
      final libraryReader = LibraryReader(typeConverter.classElement.library);

      final willChange = typeConverterGenerator?.getImport(libraryReader);
      var importString = BaseHelper.getImport(typeConverter.classElement.librarySource.uri, targetFilePath);

      if (importString == null) {
        continue;
      }

      if (willChange == true) {
        importString = outputOption.rewriteExistingImport(importString);
      }

      newImports.add(importString);
    }

    BaseHelper.addToDriftClassesMap(classElement, className, outputOption, dbState.driftClasses);

    result +=
        classHelper.getClassHeader(classElement.name, classState.superClasses, staticClassNameSuffix, useRowClass);
    result += _getTableName(tableName, classElement);
    result += fieldsCode;
    result += classHelper.closeClass();

    final generatedSource = GeneratedSource(code: result, imports: newImports);

    return (generatedSource, classState);
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
