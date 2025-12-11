import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/dao_method/dao_method_converter.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:recase/recase.dart';

class DaoHelper {
  const DaoHelper();

  ValueResponse<String> generateClassBody(
    ClassElement classElement,
    String classNameSuffix,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    var body = "";

    for (final method in classElement.methods) {
      final result = DaoMethodConverter.parseMethod(method, tableSelector, dbState);

      switch (result) {
        case ValueData<(String, String)>():
          break;
        case ValueError<(String, String)>():
          return result.wrap();
      }

      final (methodString, table) = result.data;

      if (methodString.isEmpty) {
        continue;
      }
      final documentation = BaseHelper.getDocumentationForElement(method);
      body += "$documentation$methodString\n\n";
    }

    if (body.isEmpty) {
      print("Couldn't find methods to convert in ${classElement.name}");
    }

    return ValueResponse.value(body);
  }

  ValueResponse<Set<String>> getUsedTables(
    ClassElement classElement,
    DatabaseState dbState,
    TableSelector tableSelector,
  ) {
    final result = <String>{};
    for (final method in classElement.methods) {
      final parseResult = DaoMethodConverter.parseMethodUsedTable(method, tableSelector, dbState);

      switch (parseResult) {
        case ValueError<String>():
          return parseResult.wrap();

        case ValueData<String>():
      }

      // skip if no table could be determined
      if (parseResult.data.isEmpty) {
        continue;
      }

      result.add(parseResult.data);
    }

    return ValueResponse.value(result);
  }

  ValueResponse<String> parseUsedTableAnnotation(
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

    final parameterType = BaseHelper.getTypeSpecification(type);
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

    tableSelector.currentClassState = dbState.entityClassStates.firstWhere((s) => s.classType.element == entityType);

    if (tableSelector.currentClassState == null) {
      return ValueResponse.error("Couldn't determine classState for $annotation", method);
    }

    final tableName = ReCase(tableSelector.currentClassState!.className).camelCase;

    return ValueResponse.value(tableName);
  }
}
