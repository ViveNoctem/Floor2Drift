import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template TypeConverterGenerator}
/// Converts a base dao class to the equivalent drift code
///
/// generic is omitted because [dao] is a private class and [typeChecker] is overridden
/// {@endtemplate}
class TypeConverterGenerator extends DriftClassGenerator<Null, Null> {
  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(TypeConverter);

  /// {@macro TypeConverterGenerator}
  TypeConverterGenerator({required super.inputOption});

  // TODO potential Problem
  // TODO A class needs both a not converted Type Converter and a converted TypeConverter
  // TODO both imports are needed but only the converted import is added.
  // TODO probably a small edgde case? all TypeConverters should be converted anyways
  @override
  bool getImport(LibraryReader library, DatabaseState dbState, bool ignoreTypeConverterUsedCheck) {
    for (final classElement in library.classes) {
      if (typeChecker.isSuperOf(classElement) == false) {
        continue;
      }

      // TODO skip check if type converter is actually converted in (base-) entity generator
      // TODO type converters are added in the entitiy generators. Therefore we can't know if they are being used or not.
      if (ignoreTypeConverterUsedCheck == false && DriftClassGenerator.isInDatabaseState(library, dbState) == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  @override
  (GeneratedSource, Null) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
    GeneratedSource currentSource,
  ) {
    if (typeChecker.isSuperOf(classElement) == false) {
      throw InvalidGenerationSourceError(
        'Cannot convert TypeConverter. It must inherit Floor TypeConverter.',
        element: classElement,
      );
    }

    var result = "";

    final fromType = (classElement.supertype!).typeArguments[0].getDisplayString(withNullability: true);
    final toType = (classElement.supertype!).typeArguments[1].getDisplayString(withNullability: true);

    result += const BaseHelper().getDocumentationForElement(classElement);

    result += "class ${classElement.name} extends TypeConverter<$fromType, $toType> { \n";

    // TODO add const constructor from Floor TypeConverter if one exists
    result += "const ${classElement.name}();\n\n";

    for (final method in classElement.methods) {
      // TODO just ignore every other methode at the moment
      // TODO other methods should just be added to the result class
      if (method.name != "decode" && method.name != "encode") {
        continue;
      }

      final node = method.getNode();

      if (node is! MethodDeclaration) {
        return (GeneratedSource.empty(), null);
      }

      result += const BaseHelper().getDocumentationForElement(method);

      if (method.name == "decode") {
        result += "@override\n$fromType fromSql($toType ${method.parameters[0].name})\n${node.body.toSource()}\n";
      } else {
        result += "@override\n$toType toSql($fromType ${method.parameters[0].name})\n${node.body.toSource()}\n";
      }
    }

    result += "}\n";
    final imports = const {"import 'package:drift/drift.dart';"};
    final generatedSource = currentSource + GeneratedSource(code: result, imports: imports);
    return (generatedSource, null);
  }
}
