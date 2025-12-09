part of 'statement_converter.dart';

class UpdateStatementConverter extends StatementConverter<UpdateStatement> {
  final SqlHelper sqlHelper;

  const UpdateStatementConverter({this.sqlHelper = const SqlHelper()});

  @override
  ValueResponse<(String, String)> parse(
    UpdateStatement statement,
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    final tableFrom = statement.table;

    tableSelector.currentClassState = dbState.renameMap[dbState.tableEntityMap[tableFrom.tableName.toLowerCase()]];

    final lowerCaseTableName = "${ReCase(tableFrom.tableName).camelCase}s";

    tableSelector = sqlHelper.configureTableSelector(tableSelector, dbState, tableFrom.tableName);

    final tableGetter = "updates: {${tableSelector.selector}},";

    final tableName = ReCase(lowerCaseTableName).pascalCase;
    final query = statement.span?.text;

    var variables = "[";

    // match : and the word after, to find all variable names in the query
    final matches = RegExp((":\\w+")).allMatches(query!);
    for (final match in matches) {
      final parameterName = match.input.substring(match.start + 1, match.end);

      for (final parameter in method.parameters) {
        if (parameter.name != parameterName) {
          continue;
        }

        variables += "Variable(${parameter.name}),";
        break;
      }

      // TODO potentially didn't found parameter
    }

    variables += "]";

    var result = "return (customUpdate(\"$query\", variables: $variables, $tableGetter updateKind: UpdateKind.update)";

    // close bracket before the update
    result += ");";

    return ValueResponse.value((result, tableName));
  }

  @override
  ValueResponse<String> parseUsedTable(UpdateStatement statement, MethodElement method, TableSelector tableSelector) {
    // TODO what to do in baseDao?

    return ValueResponse.value(ReCase(statement.table.tableName).pascalCase);
  }
}
