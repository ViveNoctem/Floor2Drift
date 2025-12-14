import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:floor2drift/src/helper/annotation_helper.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template EntityGenerator}
/// Converts a entity class to the equivalent drift code
/// {@endtemplate}
class EntityGenerator extends DriftClassGenerator<Entity, ClassState> {
  final bool _useRowClass;

  final ETableNameOption _tableName;

  final ClassHelper _classHelper;

  final AnnotationHelper _annotationHelper;

  final TypeConverterGenerator? _typeConverterGenerator;

  /// {@macro EntityGenerator}
  EntityGenerator({
    required TypeConverterGenerator? typeConverterGenerator,
    required bool useRowClass,
    ClassHelper classHelper = const ClassHelper(),
    AnnotationHelper annotationHelper = const AnnotationHelper(),
    required super.inputOption,
    required ETableNameOption tableName,
  })  : _tableName = tableName,
        _useRowClass = useRowClass,
        _classHelper = classHelper,
        _typeConverterGenerator = typeConverterGenerator,
        _annotationHelper = annotationHelper;

  @override
  (GeneratedSource, ClassState) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
    GeneratedSource currentSource,
  ) {
    var result = "";

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final import = const BaseHelper().getImport(classElement.library.librarySource.uri, targetFilePath);

    final newImports = <String>{if (import != null) import};

    // alway add drift import
    newImports.add("import 'package:drift/drift.dart';");

    final data = _classHelper.parseEntitiyFields(classElement, dbState);

    switch (data) {
      case ValueError():
        throw InvalidGenerationSource(data.error, element: data.element);
      case ValueData<(String, ClassState)>():
    }

    final (fieldsCode, classState) = data.data;

    // add mixin/base entity imports
    for (final mixin in classState.superClasses) {
      var importString = const BaseHelper().getImport(mixin.librarySource.uri, targetFilePath);

      if (importString == null) {
        continue;
      }

      importString = outputOption.rewriteExistingImport(importString);
      newImports.add(importString);
    }

    // add typeConverter imports
    for (final typeConverter in classState.usedTypeConverters) {
      final libraryReader = LibraryReader(typeConverter.classElement.library);

      final willChange = _typeConverterGenerator?.getImport(libraryReader);
      var importString = const BaseHelper().getImport(typeConverter.classElement.librarySource.uri, targetFilePath);

      if (importString == null) {
        continue;
      }

      if (willChange == true) {
        importString = outputOption.rewriteExistingImport(importString);
      }

      newImports.add(importString);
    }

    final className = "${classElement.name}s";

    const BaseHelper().addToDriftClassesMap(classElement, className, outputOption, dbState.driftClasses);

    result += _classHelper.getClassHeader(classElement.name, classState.superClasses, _useRowClass);
    result += _getTableName(_tableName, classElement);
    result += fieldsCode;
    result += _classHelper.closeClass();

    currentSource = _classHelper.removeUnwantedImports(currentSource);

    final generatedSource = currentSource + GeneratedSource(code: result, imports: newImports);

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
    final entityAnnotation = _annotationHelper.getEntityAnnotation(classElement);

    if (entityAnnotation == null) {
      return "";
    }

    final overrideTableName = _annotationHelper.getEntityAnnotationTableName(entityAnnotation);

    if (overrideTableName.isNotEmpty) {
      return overrideTableName;
    }

    return classElement.name;
  }

  String _getDriftCustomTableName(ClassElement classElement) {
    final entityAnnotation = _annotationHelper.getEntityAnnotation(classElement);

    if (entityAnnotation == null) {
      return "";
    }

    final overrideTableName = _annotationHelper.getEntityAnnotationTableName(entityAnnotation);

    if (overrideTableName.isNotEmpty) {
      return overrideTableName;
    }

    // if not specified in Annotation use Drift scheme
    return "";
  }
}
