import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/build_runner/annotation_generator.dart';
import 'package:floor2drift/src/build_runner/database_state.dart';
import 'package:floor2drift/src/build_runner/output_option.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/dao_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

// TODO generic is omitted because dao is private
// TODO override typeChecker
class DaoGenerator extends AnnotationGenerator<Null, Null> {
  final String classNameSuffix;
  final DaoHelper daoHelper;
  final bool useRowClass;

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(dao.runtimeType);

  // TODO need to support multiple databases?
  DaoGenerator({
    this.classNameSuffix = "",
    this.daoHelper = const DaoHelper(),
    required super.inputOption,
    required this.useRowClass,
  });

  @override
  (String, Set<String>, Null) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
  ) {
    // TODO Add Imports
    // TODO Entity Import
    // TODO Drift Table Import
    // TODO Drift Base Mixin Import

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final newImports = <String>{};
    // always needs drift import
    newImports.add("import 'package:drift/drift.dart';");

    final valueResponse = daoHelper.generateClassBody(
      classElement,
      classNameSuffix,
      TableSelectorDao(["ExampleTask"], dbState.convertedFields),
      //TODO Add the used Tables in the current dao?
    );

    switch (valueResponse) {
      case ValueData<({String body, Set<String> usedTabled})>():
        break;

      case ValueError<({String body, Set<String> usedTabled})>():
        throw InvalidGenerationSource(valueResponse.error, element: valueResponse.element);
    }

    final superType = classElement.supertype;
    var mixinClause = "";
    var mixinName = "";

    // Ignore superType Object
    if (superType != null && superType.isDartCoreObject == false) {
      final typeArgument = superType.typeArguments.firstOrNull;
      final superTypeName = superType.element.name;
      final tableName = "\$$typeArgument${classNameSuffix}sTable";
      final entityName = "$typeArgument$classNameSuffix";
      mixinName = "$superTypeName${ClassHelper.mixinSuffix}";
      mixinClause = "$mixinName<$tableName, $entityName>";

      final entityClassUri = dbState.floorClasses[entityName];

      if (entityClassUri != null) {
        final tableImport = BaseHelper.getImport(entityClassUri.librarySource.uri, targetFilePath);

        if (tableImport != null) {
          newImports.add(tableImport);
        }
      }

      final mixinClassUri = dbState.driftClasses[mixinName];

      if (mixinClassUri != null) {
        final tableImport = BaseHelper.getImport(Uri.parse(mixinClassUri), targetFilePath);

        if (tableImport != null) {
          newImports.add(tableImport);
        }
      }
    }

    //TODO output option needed to resolve the part directive bc the file could be renamed

    var fileName = outputOption.getFileName(classElement.source.shortName);

    fileName = fileName.replaceAll(".dart", ".g.dart");

    final partDirective = "part '$fileName';";

    final databaseimport = BaseHelper.getImport(dbState.databaseClass.element!.librarySource!.uri, targetFilePath);

    if (databaseimport != null) {
      newImports.add(outputOption.getFileName(databaseimport));
    }

    for (final table in valueResponse.data.usedTabled) {
      final driftClassUri = dbState.driftClasses[table];

      if (driftClassUri != null) {
        final tableImport = BaseHelper.getImport(Uri.parse(driftClassUri), targetFilePath);

        if (tableImport != null) {
          newImports.add(tableImport);
        }
      }

      if (useRowClass) {
        final floorEntitiyUri = dbState.floorClasses[table.substring(0, table.length - 1)];

        if (floorEntitiyUri != null) {
          final floorEntityImport = BaseHelper.getImport(floorEntitiyUri.librarySource.uri, targetFilePath);

          if (floorEntityImport != null) {
            newImports.add(floorEntityImport);
          }
        }
      }
    }

    final header = _generateClassHeader(
      valueResponse.data.usedTabled,
      "${classElement.name}$classNameSuffix",
      dbState.databaseClass.element!.name!,
      mixinClause,
    );

    var result = "$partDirective\n\n$header\n\n${valueResponse.data.body}\n}\n";

    return (result, newImports, null);
  }

  String _generateClassHeader(Set<String> tables, String className, String databaseName, String mixinClause) {
    // TODO case insensitivity of sqlite might be a problem
    final tableString = tables.reduce((value, element) => "$value, $element");
    return '''@DriftAccessor(tables: [$tableString])
  class $className extends DatabaseAccessor<$databaseName> with ${mixinClause.isNotEmpty ? "$mixinClause, " : ""}_\$${className}Mixin {
  $className(super.db);''';
  }
}
