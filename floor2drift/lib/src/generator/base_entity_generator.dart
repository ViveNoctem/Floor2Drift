import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/entity/annotation_converter/classState.dart';
import 'package:floor2drift/src/generator/class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:source_gen/source_gen.dart';

class BaseEntityGenerator extends AnnotationGenerator<ConvertBaseEntity, ClassState> {
  final ClassHelper classHelper;
  final TypeConverterGenerator? typeConverterGenerator;

  BaseEntityGenerator({
    required this.typeConverterGenerator,
    this.classHelper = const ClassHelper(),
    required super.inputOption,
  });

  @override
  bool getImport(LibraryReader library) {
    for (final _ in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      return true;
    }

    return false;
  }

  @override
  (GeneratedSource, ClassState) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) {
    var result = "";

    final valueResult = classHelper.generateInheritanceFields(classElement, dbState);

    switch (valueResult) {
      case ValueError<(String, ClassState)>():
        throw InvalidGenerationSource(valueResult.error, element: valueResult.element);
      case ValueData<(String, ClassState)>():
    }

    final (fieldsCode, classState) = valueResult.data;

    result += BaseHelper.getDocumentationForElement(classElement);

    final mixinName = "${classElement.name}${ClassHelper.mixinSuffix}";

    BaseHelper.addToDriftClassesMap(classElement, mixinName, outputOption, dbState.driftClasses);

    result += classHelper.getMixinHeader(mixinName);
    result += fieldsCode;
    result += classHelper.closeClass();

    final imports = {"import 'package:drift/drift.dart';"};

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);
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

      imports.add(importString);
    }

    final generatedSource = GeneratedSource(code: result, imports: imports);

    return (generatedSource, classState);
  }
}
