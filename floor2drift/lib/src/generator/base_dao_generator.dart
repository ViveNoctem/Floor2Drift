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
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template BaseDaoGenerator}
/// Converts a base dao class to the equivalent drift code
/// {@endtemplate}
class BaseDaoGenerator extends DriftClassGenerator<ConvertBaseDao, Null> {
  final DaoHelper _daoHelper;

  /// name of the table file in base dao classes
  static String tableSelector = "table";

  /// {@macro BaseDaoGenerator}
  const BaseDaoGenerator({DaoHelper daoHelper = const DaoHelper(), required super.inputOption})
      : _daoHelper = daoHelper;

  @override
  bool getImport(LibraryReader library) {
    for (final _ in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
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
    // analysing generic
    final typeDeclaration = classElement.typeParameters.firstOrNull?.declaration;
    final baseEntityDeclaration = typeDeclaration?.toString();
    final genericName = typeDeclaration?.name;
    final baseEntityElement = typeDeclaration?.bound?.element;
    final baseEntityName = baseEntityElement?.name;

    ClassState? classState;

    for (final state in dbState.entityClassStates) {
      if (state.classType.element != baseEntityElement) {
        continue;
      }
      classState = state;
      break;
    }

    final valueResponse = _daoHelper.generateClassBody(
      classElement,
      // do not use classNameSuffix. The Type Name should always be a generic type
      "",
      TableSelectorBaseDao(
        tableSelector,
        currentClassState: classState,
      ),
      dbState,
    );

    final newImports = <String>{};
    newImports.add("import 'package:drift/drift.dart';");

    switch (valueResponse) {
      case ValueData<String>():
        break;

      case ValueError<String>():
        throw InvalidGenerationSource(valueResponse.error, element: valueResponse.element);
    }

    if (baseEntityDeclaration == null ||
        baseEntityDeclaration.isEmpty ||
        genericName == null ||
        genericName.isEmpty ||
        baseEntityName == null ||
        baseEntityName.isEmpty) {
      throw InvalidGenerationSource("Type parameter for base entity is expected", element: classElement);
    }

    final className = "${classElement.name}${ClassHelper.mixinSuffix}";

    const BaseHelper().addToDriftClassesMap(classElement, className, outputOption, dbState.driftClasses);

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    final tableImport = const BaseHelper().getClassImport(targetFilePath, classState);
    if (tableImport != null) {
      newImports.add(tableImport);
    }

    final header = _generateMixinHeader(
      className,
      dbState.databaseClass.element!.name!,
      "$baseEntityName${ClassHelper.mixinSuffix}",
      genericName,
      baseEntityDeclaration,
    );

    final databaseimport =
        const BaseHelper().getImport(dbState.databaseClass.element!.librarySource!.uri, targetFilePath);

    if (databaseimport != null) {
      newImports.add(outputOption.getFileName(databaseimport));
    }

    final documentation = const BaseHelper().getDocumentationForElement(classElement);

    var result = "$documentation$header\n\n${valueResponse.data}\n}\n";

    currentSource = const DaoHelper().removeUnwantedImports(currentSource);

    final generatedSource = currentSource + GeneratedSource(code: result, imports: newImports);

    return (generatedSource, null);
  }

  String _generateMixinHeader(
    String className,
    String databaseName,
    String mixinName,
    String genericName,
    String baseEntityDeclataration,
  ) {
    // TODO change TC to be different, if D has the name TC
    // TODO case insensitivity of sqlite might be a problem
    return '''mixin $className<TC extends $mixinName, $baseEntityDeclataration> on DatabaseAccessor<$databaseName> {
    TableInfo<TC, $genericName> get $tableSelector => attachedDatabase.allTables.firstWhere((tbl) =>  tbl.runtimeType == TC) as TableInfo<TC, $genericName>;''';
  }
}
