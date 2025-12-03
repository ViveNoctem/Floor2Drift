import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/sql_helper.dart';
import 'package:floor2drift/src/sql/expression_converter/expression_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:recase/recase.dart';
import 'package:sqlparser/sqlparser.dart' hide Variable;

part 'delete_statement_converter.dart';
part 'select_statement_converter.dart';
part 'update_statement_converter.dart';

sealed class StatementConverter<S extends AstNode> {
  const StatementConverter();

  ValueResponse<(String, String)> parse(
    S statement,
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  );

  static ValueResponse<(String, String)> parseStatement(
    AstNode statement,
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    final converter = getStatementConverterForNode(statement, method);

    switch (converter) {
      case ValueError<StatementConverter<AstNode>>():
        return converter.wrap();
      case ValueData<StatementConverter<AstNode>>():
    }

    return converter.data.parse(statement, method, tableSelector, dbState);
  }

  ValueResponse<String> parseUsedTable(S statement, MethodElement method, TableSelector tableSelector);

  static ValueResponse<String> parseStatementUsedTable(
    AstNode statement,
    MethodElement method,
    TableSelector tableSelector,
  ) {
    final converter = getStatementConverterForNode(statement, method);

    switch (converter) {
      case ValueError<StatementConverter<AstNode>>():
        return converter.wrap();
      case ValueData<StatementConverter<AstNode>>():
    }

    return converter.data.parseUsedTable(statement, method, tableSelector);
  }

  static ValueResponse<StatementConverter> getStatementConverterForNode(AstNode node, Element element) {
    return switch (node) {
      SelectStatement() => ValueResponse.value(const SelectStatementConverter()),
      DeleteStatement() => ValueResponse.value(const DeleteStatementConverter()),
      UpdateStatement() => ValueResponse.value(const UpdateStatementConverter()),
      // TODO InsertStatement() =>
      _ => ValueResponse.error("SQL Node Type is not supported: $node", element),
    };
  }
}
