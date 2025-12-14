import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:path/path.dart' as path;

/// Helper class to provide general methods
class BaseHelper {
  /// Helper class to provide general methods
  const BaseHelper();

  /// parses the [interfaceType] and returns the [TypeSpecification] for this type
  TypeSpecification getTypeSpecification(DartType interfaceType) {
    if (interfaceType is! InterfaceType) {
      return const TypeSpecification(EType.unknown, EType.unknown, true);
    }

    final mainType = EType.getByDartType(interfaceType);

    if (interfaceType.typeArguments.isEmpty || mainType == EType.unknown) {
      return TypeSpecification(mainType, EType.unknown, interfaceType.nullabilitySuffix == NullabilitySuffix.question);
    }

    final typeArgumentDartType = interfaceType.typeArguments.first;

    final typeArgumentType = EType.getByDartType(typeArgumentDartType);

    if (typeArgumentType != EType.unknown && typeArgumentDartType is InterfaceType) {
      final secondTypeArgument = typeArgumentDartType.typeArguments.firstOrNull;

      if (secondTypeArgument == null) {
        return TypeSpecification(
          mainType,
          typeArgumentType,
          typeArgumentDartType.nullabilitySuffix == NullabilitySuffix.question,
        );
      }

      return TypeSpecification(
        mainType,
        typeArgumentType,
        secondTypeArgument.nullabilitySuffix == NullabilitySuffix.question,
      );
    }

    return TypeSpecification(
      mainType,
      typeArgumentType,
      typeArgumentDartType.nullabilitySuffix == NullabilitySuffix.question,
    );
  }

  /// returns an import directive to import [toImportUri] in [importInFilePath]
  String? getImport(Uri toImportUri, String importInFilePath) {
    final libraryUri = toImportUri;

    if (libraryUri.hasScheme == false) {
      return null;
    }

    // If the analyzer knows the package of the library it generates the correct package import
    if (libraryUri.isScheme("package")) {
      return "import '$libraryUri';";
    }

    if (libraryUri.isScheme("file") == false) {
      return null;
    }

    final targetPath = libraryUri.toFilePath();
    final sourcePath = importInFilePath.substring(0, importInFilePath.lastIndexOf(Platform.pathSeparator));
    //  If the analyzer couldn't determine the package for example in test file the path is provided.
    final relativePath = path.relative(targetPath, from: sourcePath);
    return "import '$relativePath';";
  }

  /// adds the path [classElement] will be written to to [driftClasses]
  void addToDriftClassesMap(
    ClassElement classElement,
    String newClassName,
    OutputOptionBase outputOption,
    Map<String, String> driftClasses,
  ) {
    final uri = classElement.librarySource.uri;

    if (uri.isScheme("package")) {
      final newpath = outputOption.getFileName(uri.toString());

      driftClasses[newClassName] = newpath;
    } else {
      final newpath = outputOption.getFileName("file:${classElement.librarySource.uri.toFilePath()}");
      driftClasses[newClassName] = newpath;
    }
  }

  /// returns the doc comment for the [element]
  String getDocumentationForElement(Element element) {
    if (element.documentationComment == null) {
      return "";
    }

    return "${element.documentationComment}\n";
  }

  /// iterates through [dbState] to search for the [className]
  ///
  /// return null if no state was found
  ClassState? getClassState(DatabaseState dbState, String className) {
    for (final state in dbState.entityClassStates) {
      if (state.className.toLowerCase() != className.toLowerCase()) {
        continue;
      }

      return state;
    }

    return null;
  }

  /// returns an import statement to import [classState] in [targetFilePath]
  ///
  /// also see [getImport]
  String? getClassImport(String targetFilePath, ClassState? classState) {
    final classUri = classState?.classType.element?.librarySource?.uri;

    if (classUri == null) {
      return null;
    }

    final classImport = const BaseHelper().getImport(classUri, targetFilePath);

    return classImport;
  }

  // TODO if more platform dependent code is needed change to use platform package
  /// returns Platform.lineTerminator
  ///
  /// as an abstraction that can be mocked
  String getPlatformLineTerminator() {
    return Platform.lineTerminator;
  }
}
