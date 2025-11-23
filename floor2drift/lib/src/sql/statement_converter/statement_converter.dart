import 'package:analyzer/dart/element/element.dart';
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

  ValueResponse<(String, String)> parse(S statement, MethodElement method, TableSelector tableSelector);

  static ValueResponse<(String, String)> parseStatement(
    AstNode statement,
    MethodElement method,
    TableSelector tableSelector,
  ) {
    return switch (statement) {
      SelectStatement() => const SelectStatementConverter().parse(statement, method, tableSelector),
      DeleteStatement() => const DeleteStatementConverter().parse(statement, method, tableSelector),
      UpdateStatement() => const UpdateStatementConverter().parse(statement, method, tableSelector),
      // TODO InsertStatement() =>
      _ => ValueResponse.error("SQL Node Type is not supported: $statement", method),
    };
  }
}
