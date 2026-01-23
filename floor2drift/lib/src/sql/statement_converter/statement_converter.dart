import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/sql_helper.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/sql/expression_converter/expression_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:recase/recase.dart';
import 'package:sqlparser/sqlparser.dart' hide Variable;

part 'delete_statement_converter.dart';
part 'select_statement_converter.dart';
part 'update_statement_converter.dart';

/// {@template StatementConverter}
/// Class for converting a specifict type of custom SQL statement to its drift counterpart}
/// {@endtemplate}
sealed class StatementConverter<S extends AstNode> {
  const StatementConverter();

  ValueResponse<String> _parse(
    S statement,
    Element method,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
    DatabaseState dbState,
    TypeSpecification returnValue,
    bool isView,
  );

  /// parses the give [statement] to the equivalent drift code
  static ValueResponse<String> parseStatement(
    AstNode statement,
    Element method,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
    DatabaseState dbState,
    TypeSpecification returnValue,
    bool isView,
  ) {
    final converter = _getStatementConverterForNode(statement, method);

    switch (converter) {
      case ValueError<StatementConverter<AstNode>>():
        return converter.wrap();
      case ValueData<StatementConverter<AstNode>>():
    }

    return converter.data._parse(statement, method, parameters, tableSelector, dbState, returnValue, isView);
  }

  ValueResponse<List<String>> _parseUsedTable(S statement, MethodElement method, TableSelector tableSelector);

  /// returns all tables used in [statement]
  static ValueResponse<List<String>> parseStatementUsedTable(
    AstNode statement,
    MethodElement method,
    TableSelector tableSelector,
  ) {
    final converter = _getStatementConverterForNode(statement, method);

    switch (converter) {
      case ValueError<StatementConverter<AstNode>>():
        return converter.wrap();
      case ValueData<StatementConverter<AstNode>>():
    }

    return converter.data._parseUsedTable(statement, method, tableSelector);
  }

  static ValueResponse<StatementConverter> _getStatementConverterForNode(AstNode node, Element element) {
    return switch (node) {
      SelectStatement() => ValueResponse.value(const SelectStatementConverter()),
      DeleteStatement() => ValueResponse.value(const DeleteStatementConverter()),
      UpdateStatement() => ValueResponse.value(const UpdateStatementConverter()),
      // TODO InsertStatement() =>
      _ => ValueResponse.error("SQL Node Type is not supported: $node", element),
    };
  }
}
