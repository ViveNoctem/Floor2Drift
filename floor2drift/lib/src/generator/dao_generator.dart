import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/dao_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template DaoGenerator}
/// Converts a dao class to the equivalent drift code
///
/// generic is omitted because [dao] is a private class and [typeChecker] is overridden
/// {@endtemplate}
class DaoGenerator extends DriftClassGenerator<Null, Null> {
  final String _classNameSuffix;
  final DaoHelper _daoHelper;
  final bool _useRowClass;

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(dao.runtimeType);

  /// {@macro DaoGenerator}
  const DaoGenerator({
    String classNameSuffix = "",
    DaoHelper daoHelper = const DaoHelper(),
    required super.inputOption,
    required bool useRowClass,
  })  : _classNameSuffix = classNameSuffix,
        _useRowClass = useRowClass,
        _daoHelper = daoHelper;

  @override
  (GeneratedSource, Null) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState dbState,
    GeneratedSource currentSource,
  ) {
    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final newImports = <String>{};
    // always needs drift import
    newImports.add("import 'package:drift/drift.dart';");

    final tableSelector = TableSelectorDao(currentClassState: null);

    final usedTablesResponse = _daoHelper.getUsedTables(classElement, dbState, tableSelector);
    switch (usedTablesResponse) {
      case ValueError<Set<String>>():
        throw InvalidGenerationSource(usedTablesResponse.error, element: usedTablesResponse.element);
      case ValueData<Set<String>>():
    }

    final valueResponse = _daoHelper.generateClassBody(classElement, _classNameSuffix, tableSelector, dbState);

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
      final tableName = "\$$typeArgument${_classNameSuffix}sTable";
      final entityName = "$typeArgument$_classNameSuffix";
      mixinName = "$superTypeName${EntityHelper.mixinSuffix}";
      mixinClause = "$mixinName<$tableName, $entityName>";

      if (typeArgument != null) {
        final typeArgumentUri = typeArgument.element?.librarySource?.uri;

        if (typeArgumentUri != null) {
          final entityImport = const BaseHelper().getImport(typeArgumentUri, targetFilePath);

          if (entityImport != null) {
            newImports.add(entityImport);

            // with modular code generation the generated table class is not in the database.g.dart but in a .drift.dart file next to the entity
            if (outputOption.isModularCodeGeneration) {
              var modularImport = outputOption.rewriteExistingImport(entityImport);
              modularImport = modularImport.replaceAll(".dart", ".drift.dart");
              newImports.add(modularImport);
            }
          }
        }
      }

      final mixinClassUri = dbState.driftClasses[mixinName];

      if (mixinClassUri != null) {
        final tableImport = const BaseHelper().getImport(Uri.parse(mixinClassUri), targetFilePath);

        if (tableImport != null) {
          newImports.add(tableImport);
        }
      }
    }

    final databaseimport =
        const BaseHelper().getImport(dbState.databaseClass.element!.librarySource!.uri, targetFilePath);

    if (databaseimport != null) {
      newImports.add(outputOption.getFileName(databaseimport));
    }

    final tableClassNames = <String>{};

    for (final table in usedTablesResponse.data) {
      final driftClassUri = dbState.driftClasses["${table}s"];

      if (driftClassUri != null) {
        final tableImport = const BaseHelper().getImport(Uri.parse(driftClassUri), targetFilePath);

        if (tableImport != null) {
          newImports.add(tableImport);
        }
      }

      final classState = _getClassState(dbState, table);

      if (classState != null) {
        tableClassNames.add(classState.className);
      }

      final entityImport = _getEntityImport(targetFilePath, classState);

      if (entityImport != null) {
        newImports.add(entityImport);
      }
    }

    final implementsClause = const BaseHelper().getImplementsClause(classElement);

    final header = _generateClassHeader(
      tableClassNames,
      "${classElement.name}$_classNameSuffix",
      dbState.databaseClass.element!.name!,
      mixinClause,
      outputOption.isModularCodeGeneration,
      implementsClause,
    );

    final documentation = const BaseHelper().getDocumentationForElement(classElement);
    var result = "$documentation$header${valueResponse.data}\n}\n";

    // output option needed to resolve the part directive because the file could be renamed
    var fileName = outputOption.getFileName(classElement.source.shortName);
    final parts = <String>{};

    if (outputOption.isModularCodeGeneration) {
      fileName = fileName.replaceAll(".dart", ".drift.dart");
      final importDirective = "import '$fileName';";
      newImports.add(importDirective);
    } else {
      fileName = fileName.replaceAll(".dart", ".g.dart");
      final partDirective = "part '$fileName';";
      parts.add(partDirective);
    }

    currentSource = const DaoHelper().removeUnwantedImports(currentSource);

    final generatedSource = currentSource + GeneratedSource(code: result, imports: newImports, parts: parts);

    return (generatedSource, null);
  }

  String _generateClassHeader(
    Set<String> tables,
    String className,
    String databaseName,
    String mixinClause,
    bool isModularGeneration,
    String implementsClause,
  ) {
    final tableList = tables.map((s) => "${s}s");

    if (tableList.isEmpty) {
      print("Couldn't determine tables for $className");
    }

    final tableString = tableList.isEmpty ? "" : tableList.reduce((value, element) => "$value, $element");
    final private = isModularGeneration ? "" : "_";
    return '''@DriftAccessor(tables: [$tableString])
  class $className extends DatabaseAccessor<$databaseName> with ${mixinClause.isNotEmpty ? "$mixinClause, " : ""}$private\$${className}Mixin $implementsClause{
  $className(super.db);''';
  }

  ClassState? _getClassState(DatabaseState dbState, String tableName) {
    for (final state in dbState.entityClassStates) {
      if (state.className.toLowerCase() != tableName.toLowerCase()) {
        continue;
      }

      return state;
    }

    return null;
  }

  String? _getEntityImport(String targetFilePath, ClassState? classState) {
    if (_useRowClass == false) {
      return null;
    }

    final floorEntityUri = classState?.classType.element?.librarySource?.uri;

    if (floorEntityUri == null) {
      return null;
    }

    final floorEntityImport = const BaseHelper().getImport(floorEntityUri, targetFilePath);

    return floorEntityImport;
  }
}
