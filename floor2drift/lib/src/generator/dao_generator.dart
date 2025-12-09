import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/class_generator.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/dao_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

// TODO generic is omitted because dao is private
class DaoGenerator extends AnnotationGenerator<Null, Null> {
  final String classNameSuffix;
  final DaoHelper daoHelper;
  final bool useRowClass;

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(dao.runtimeType);

  const DaoGenerator({
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
    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final newImports = <String>{};
    // always needs drift import
    newImports.add("import 'package:drift/drift.dart';");

    final tableSelector = TableSelectorDao(dbState.convertedFields, currentClassState: null);

    final usedTablesResponse = daoHelper.getUsedTables(classElement, dbState, tableSelector);

    switch (usedTablesResponse) {
      case ValueError<Set<String>>():
        throw InvalidGenerationSource(usedTablesResponse.error, element: usedTablesResponse.element);
      case ValueData<Set<String>>():
    }

    final valueResponse = daoHelper.generateClassBody(classElement, classNameSuffix, tableSelector, dbState);

    switch (valueResponse) {
      case ValueData<String>():
        break;

      case ValueError<String>():
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

    // output option needed to resolve the part directive because the file could be renamed
    final fileName = outputOption.getFileName(classElement.source.shortName).replaceAll(".dart", ".g.dart");

    final partDirective = "part '$fileName';";

    final databaseimport = BaseHelper.getImport(dbState.databaseClass.element!.librarySource!.uri, targetFilePath);

    if (databaseimport != null) {
      newImports.add(outputOption.getFileName(databaseimport));
    }

    for (final table in usedTablesResponse.data) {
      final driftClassUri = dbState.driftClasses["${table}s"];

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
      usedTablesResponse.data,
      "${classElement.name}$classNameSuffix",
      dbState.databaseClass.element!.name!,
      mixinClause,
    );

    final documentation = BaseHelper.getDocumentationForElement(classElement);

    var result = "$partDirective\n\n$documentation$header\n\n${valueResponse.data}\n}\n";

    return (result, newImports, null);
  }

  String _generateClassHeader(Set<String> tables, String className, String databaseName, String mixinClause) {
    // TODO case insensitivity of sqlite might be a problem
    final tableList = tables.map((s) => "${s}s");

    if (tableList.isEmpty) {
      print("Couldn't determine tables for $className");
    }

    final tableString = tableList.isEmpty ? "" : tableList.reduce((value, element) => "$value, $element");
    return '''@DriftAccessor(tables: [$tableString])
  class $className extends DatabaseAccessor<$databaseName> with ${mixinClause.isNotEmpty ? "$mixinClause, " : ""}_\$${className}Mixin {
  $className(super.db);''';
  }
}
