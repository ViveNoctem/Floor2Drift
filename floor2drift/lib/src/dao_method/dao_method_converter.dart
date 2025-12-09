import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/dao_method/delete_method_converter.dart';
import 'package:floor2drift/src/dao_method/insert_method_converter.dart';
import 'package:floor2drift/src/dao_method/query_method_converter.dart';
import 'package:floor2drift/src/dao_method/update_method_converter.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

abstract class DaoMethodConverter {
  const DaoMethodConverter();
  static ValueResponse<(String, String)> parseMethod(
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    const queryChecker = TypeChecker.fromRuntime(Query);
    var annotation = queryChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const QueryMethodConverter().parse(method, annotation, tableSelector, dbState);
    }

    final deleteChecker = TypeChecker.fromRuntime(delete.runtimeType);
    annotation = deleteChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const DeleteMethodConverter().parse(method, annotation, tableSelector, dbState);
    }

    const insertChecker = TypeChecker.fromRuntime(Insert);
    annotation = insertChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const InsertMethodConverter().parse(method, annotation, tableSelector, dbState);
    }

    const updateChecker = TypeChecker.fromRuntime(Update);
    annotation = updateChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const UpdateMethodConverter().parse(method, annotation, tableSelector, dbState);
    }

    return ValueResponse.value(("", ""));
  }

  ValueResponse<(String, String)> parse(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  );

  static ValueResponse<String> parseMethodUsedTable(
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    final result = _convertUsedTable(method, tableSelector, dbState);

    switch (result) {
      case ValueError<String>():
        return result.wrap();
      case ValueData<String>():
    }

    if (result.data.isEmpty) {
      return result;
    }

    final tableClassName = dbState.tableEntityMap[result.data.toLowerCase()]?.name;

    if (tableClassName == null) {
      return result;
    }

    return ValueResponse.value(ReCase(tableClassName).pascalCase);
  }

  static ValueResponse<String> _convertUsedTable(
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    const queryChecker = TypeChecker.fromRuntime(Query);
    var annotation = queryChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const QueryMethodConverter().parseUsedTable(method, annotation, tableSelector, dbState);
    }

    final deleteChecker = TypeChecker.fromRuntime(delete.runtimeType);
    annotation = deleteChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const DeleteMethodConverter().parseUsedTable(method, annotation, tableSelector, dbState);
    }

    const insertChecker = TypeChecker.fromRuntime(Insert);
    annotation = insertChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const InsertMethodConverter().parseUsedTable(method, annotation, tableSelector, dbState);
    }

    const updateChecker = TypeChecker.fromRuntime(Update);
    annotation = updateChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const UpdateMethodConverter().parseUsedTable(method, annotation, tableSelector, dbState);
    }

    return ValueResponse.value("");
  }

  ValueResponse<String> parseUsedTable(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  );

  @protected
  ValueResponse<String> getDaoTablename(
    TableSelectorDao tableSelector,
    ParameterElement parameter,
    TypeSpecification parameterSpecification,
  ) {
    String? className;
    switch (parameterSpecification.type) {
      case EType.list:
        className = (parameter.type as InterfaceType).typeArguments.firstOrNull?.element?.name;
      case EType.unknown:
        className = parameter.type.element?.name;
        break;
      default:
        return ValueResponse.error("", parameter);
    }

    if (className == null) {
      return ValueResponse.error("couldn't determine name of parameter class", parameter);
    }

    final tablename = "${ReCase(className).camelCase}s";

    return ValueResponse.value(tablename);
  }

  @protected
  ValueResponse<String> getArgumentName(ParameterElement parameter) {
    return ValueResponse.value(parameter.name);
  }

  @protected
  ValueResponse<String> getMethodHeader(MethodElement method) {
    final methodName = method.getDisplayString();

    return ValueResponse.value("$methodName async {");
  }

  @protected
  ValueResponse<String> getTableName(
    TableSelector tableSelector,
    ParameterElement parameter,
    TypeSpecification parameterSpecification,
  ) {
    return switch (tableSelector) {
      TableSelectorBaseDao() => ValueResponse.value(tableSelector.table),
      TableSelectorDao() => getDaoTablename(tableSelector, parameter, parameterSpecification),
    };
  }
}
