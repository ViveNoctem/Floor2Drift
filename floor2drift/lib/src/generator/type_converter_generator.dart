import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/build_runner/annotation_generator.dart';
import 'package:floor2drift/src/build_runner/database_state.dart';
import 'package:floor2drift/src/build_runner/output_option.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

// TODO generic is omitted because dao is private
// TODO override typeChecker
class TypeConverterGenerator extends AnnotationGenerator<Null, Null> {
  final String classNameSuffix;

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(TypeConverter);

  TypeConverterGenerator({required this.classNameSuffix, required super.inputOption});

  // TODO potential Problem
  // TODO A class needs both a not converted Type Converter and a converted TypeConverter
  // TOOD both imports are needed but only the converted import is added.
  // TODO probably a small edgde case? all TypeConverters should be converted anyways
  @override
  FutureOr<bool> getImport(LibraryReader library) {
    for (final classElement in library.classes) {
      if (typeChecker.isSuperOf(classElement) == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  @override
  (String, Set<String>, Null) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) {
    // TODO how to make sure it isn't an drift TypeConverter?
    if (classElement.supertype?.element.name != "TypeConverter") {
      throw InvalidGenerationSourceError(
        '`@ConvertTypeConverter` can only be used on classes inheriting Floor TypeConverters.',
        element: classElement,
      );
    }

    var result = "";

    final fromType = (classElement.supertype!).typeArguments[0].getDisplayString(withNullability: true);
    final toType = (classElement.supertype!).typeArguments[1].getDisplayString(withNullability: true);

    result += "class ${classElement.name}$classNameSuffix extends TypeConverter<$fromType, $toType> { \n";

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
        return ("", const {}, null);
      }

      node.body.toSource();

      if (method.name == "decode") {
        result += "@override\n$fromType fromSql($toType ${method.parameters[0].name})\n${node.body.toSource()}\n";
      } else {
        result += "@override\n$toType toSql($fromType ${method.parameters[0].name})\n${node.body.toSource()}\n";
      }
    }

    result += "}\n";

    return (result, const {}, null);
  }
}
