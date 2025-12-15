import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template BaseEntityGenerator}
/// Converts a base entity class to the equivalent drift code
/// {@endtemplate}
class BaseEntityGenerator extends DriftClassGenerator<ConvertBaseEntity, ClassState> {
  final ClassHelper _classHelper;
  final TypeConverterGenerator? _typeConverterGenerator;

  /// {@macro BaseEntityGenerator}
  BaseEntityGenerator({
    required TypeConverterGenerator? typeConverterGenerator,
    ClassHelper classHelper = const ClassHelper(),
    required super.inputOption,
  })  : _classHelper = classHelper,
        _typeConverterGenerator = typeConverterGenerator;

  @override
  bool getImport(LibraryReader library, DatabaseState dbState, bool ignoreTypeConverterUsedCheck) {
    for (final _ in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (DriftClassGenerator.isInDatabaseState(library, dbState) == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  @override
  (GeneratedSource, ClassState) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
    GeneratedSource currentSource,
  ) {
    var result = "";

    final valueResult = _classHelper.parseEntitiyFields(classElement, dbState);

    switch (valueResult) {
      case ValueError<(String, ClassState)>():
        throw InvalidGenerationSource(valueResult.error, element: valueResult.element);
      case ValueData<(String, ClassState)>():
    }

    final (fieldsCode, classState) = valueResult.data;

    result += const BaseHelper().getDocumentationForElement(classElement);

    final mixinName = "${classElement.name}${ClassHelper.mixinSuffix}";

    const BaseHelper().addToDriftClassesMap(classElement, mixinName, outputOption, dbState.driftClasses);

    result += _classHelper.getMixinHeader(mixinName);
    result += fieldsCode;
    result += _classHelper.closeClass();

    final imports = {"import 'package:drift/drift.dart';"};

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);
    for (final typeConverter in classState.usedTypeConverters) {
      final libraryReader = LibraryReader(typeConverter.classElement.library);

      final willChange = _typeConverterGenerator?.getImport(libraryReader, dbState, true);
      var importString = const BaseHelper().getImport(typeConverter.classElement.librarySource.uri, targetFilePath);

      if (importString == null) {
        continue;
      }

      if (willChange == true) {
        importString = outputOption.rewriteExistingImport(importString);
      }

      imports.add(importString);
    }

    currentSource = _classHelper.removeUnwantedImports(currentSource);

    final generatedSource = currentSource + GeneratedSource(code: result, imports: imports);

    return (generatedSource, classState);
  }
}
