import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/dao_helper.dart';
import 'package:floor2drift/src/helper/sql_helper.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/sql/statement_converter/statement_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

part 'delete_method_converter.dart';
part 'insert_method_converter.dart';
part 'query_method_converter.dart';
part 'update_method_converter.dart';
part 'transaction_method_converter.dart';

/// {@template DaoMethodConverter}
/// base class for all methods that are contained in a floor [dao]
/// {@endtemplate}
abstract class DaoMethodConverter {
  /// {@macro DaoMethodConverter}
  const DaoMethodConverter();

  /// Parses a [MethodElement] and
  /// calls the right [DaoMethodConverter]
  static ValueResponse<String> parseMethod(MethodElement method, TableSelector tableSelector, DatabaseState dbState) {
    const queryChecker = TypeChecker.fromRuntime(Query);
    var annotation = queryChecker.firstAnnotationOfExact(method);
    if (annotation != null) {
      return const QueryMethodConverter()._parse(method, annotation, tableSelector, dbState);
    }

    final deleteChecker = TypeChecker.fromRuntime(delete.runtimeType);
    annotation = deleteChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const DeleteMethodConverter()._parse(method, annotation, tableSelector, dbState);
    }

    const insertChecker = TypeChecker.fromRuntime(Insert);
    annotation = insertChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const InsertMethodConverter()._parse(method, annotation, tableSelector, dbState);
    }

    const updateChecker = TypeChecker.fromRuntime(Update);
    annotation = updateChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const UpdateMethodConverter()._parse(method, annotation, tableSelector, dbState);
    }

    final transactionChecker = TypeChecker.fromRuntime(transaction.runtimeType);
    annotation = transactionChecker.firstAnnotationOfExact(method);

    if (annotation != null) {
      return const TransactionMethodConverter()._parse(method, annotation, tableSelector, dbState);
    }

    return ValueResponse.value("");
  }

  // is unused because all calls are directly on the inheriting classes
  // ignore: unused_element
  ValueResponse<String> _parse(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  );

  /// returns which table is used in the given [MethodElement]
  ///
  /// The return value is the name of the corresponding floor entity class.
  /// Not the actual sql table name
  static ValueResponse<List<String>> parseMethodUsedTable(
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

    return ValueResponse.value(const []);
  }

  /// This methods is required to set the currentClassState of the tableSelector
  ValueResponse<List<String>> parseUsedTable(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  );

  /// returns the drift tablename for the given [parameter]
  ///
  /// TODO can probably be removed and replaces with tableSelector.currentClassState
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

  /// returns the drift tablename for the [parameter] return type
  ///
  /// TODO can probably be removed and replaces with tableSelector.currentClassState
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

  /// returns the standard method header for the given [method]
  @protected
  ValueResponse<String> getMethodHeader(MethodElement method) {
    final methodName = method.getDisplayString();

    return ValueResponse.value("$methodName async {");
  }
}
