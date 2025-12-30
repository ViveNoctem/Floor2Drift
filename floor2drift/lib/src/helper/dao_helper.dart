import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/dao_method/dao_method_converter.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:recase/recase.dart';

/// {@template DaoHelper}
/// Helper class to provide general methods for handling in dao classes
/// {@endtemplate}
class DaoHelper {
  /// {@macro BaseHelper}
  final BaseHelper baseHelper;

  /// {@macro DaoHelper}
  const DaoHelper({this.baseHelper = const BaseHelper()});

  /// return the dart code for the class body [classElement] in a dao
  ValueResponse<String> generateClassBody(
    ClassElement classElement,
    String classNameSuffix,
    TableSelector tableSelector,
    DatabaseState dbState,
    bool isBase,
  ) {
    var body = "";

    for (final method in classElement.methods) {
      if (isBase) {
        tableSelector = TableSelectorBaseDao(
          BaseDaoGenerator.tableSelector,
          currentClassStates: tableSelector.currentClassStates,
        );
      } else {
        tableSelector = TableSelectorDao(currentClassStates: []);
      }

      final result = DaoMethodConverter.parseMethod(method, tableSelector, dbState);

      switch (result) {
        case ValueData<String>():
          break;
        case ValueError<String>():
          result.printError();
          continue;
      }
      final methodString = result.data;
      if (methodString.isEmpty) {
        final methodCode = baseHelper.getMethodCode(method);

        if (methodCode.isEmpty) {
          continue;
        }

        body += "$methodCode\n\n";
        continue;
      }

      final documentation = const BaseHelper().getDocumentationForElement(method);
      body += "$documentation$methodString\n\n";
    }

    if (body.isEmpty) {
      print("Couldn't find methods to convert in ${classElement.name}");
    }

    return ValueResponse.value(body);
  }

  /// returns the entity names of all tables used in [classElement]
  ValueResponse<Set<String>> getUsedTables(
    ClassElement classElement,
    DatabaseState dbState,
    TableSelector tableSelector,
  ) {
    final result = <String>{};
    for (final method in classElement.methods) {
      final parseResult = DaoMethodConverter.parseMethodUsedTable(method, tableSelector, dbState);

      switch (parseResult) {
        case ValueError<List<String>>():
          parseResult.printError();
          continue;
        case ValueData<List<String>>():
      }

      // skip if no table could be determined
      if (parseResult.data.isEmpty) {
        continue;
      }

      result.addAll(parseResult.data);
    }

    return ValueResponse.value(result);
  }

  /// returns the entity name used in [method]
  ///
  /// specifically for use in [delete] [insert] [update] methods, because the return type need to be analyzed instead of an actual sql query
  ValueResponse<List<String>> parseUsedTableAnnotation(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    final parameter = method.parameters.firstOrNull;

    if (parameter == null) {
      return ValueResponse.error("parameter is null", method);
    }

    final type = parameter.type;

    final parameterType = const BaseHelper().getTypeSpecification(type);
    Element? entityType;
    switch (parameterType.type) {
      case EType.stream:
        return ValueResponse.error("parameter stream is not supported", method);
      case EType.future:
        return ValueResponse.error("parameter future is not supported", method);
      case EType.voidType:
        return ValueResponse.error("parameter is null", method);
      case EType.list:
        entityType = (parameter.type as ParameterizedType).typeArguments.first.element;
      case EType.unknown:
        entityType = type.element;
    }

    if (tableSelector is! TableSelectorDao) {
      return ValueResponse.error("expected to be called on real entity, but was called on base entity", method);
    }

    ClassState? foundState;

    for (final state in dbState.entityClassStates) {
      if (state.classType.element != entityType) {
        continue;
      }
      foundState = state;
      break;
    }

    if (foundState == null) {
      return ValueResponse.error("Couldn't determine classState for $annotation", method);
    }

    final tableName = ReCase(foundState.className).camelCase;

    return ValueResponse.value([tableName]);
  }

  /// delete or rewrites imports conflicting with the drift classes
  ///
  /// e.g. floor_annotation delete conflict with drift delete in query
  GeneratedSource removeUnwantedImports(GeneratedSource source) {
    final localImports = {...source.imports};

    // doubled because imports with ' and "
    localImports.remove("import 'package:floor_annotation/floor_annotation.dart';");
    localImports.remove('import "package:floor_annotation/floor_annotation.dart"');

    return source.copyWith(imports: localImports);
  }
}
