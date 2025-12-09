part of 'statement_converter.dart';

class DeleteStatementConverter extends StatementConverter<DeleteStatement> {
  final SqlHelper sqlHelper;

  const DeleteStatementConverter({this.sqlHelper = const SqlHelper()});

  @override
  ValueResponse<(String, String)> parse(
    DeleteStatement statement,
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    final tableFrom = statement.from;

    tableSelector.currentClassState = dbState.renameMap[dbState.tableEntityMap[tableFrom.tableName.toLowerCase()]];

    final lowerCaseTableName = "${ReCase(tableFrom.tableName).camelCase}s";

    tableSelector = sqlHelper.configureTableSelector(tableSelector, dbState, tableFrom.tableName);

    final tableName = "${lowerCaseTableName[0].toUpperCase()}${lowerCaseTableName.substring(1)}";

    var result = "return (delete(${tableSelector.selector})";

    final where = statement.where;

    if (where != null) {
      final whereResult = sqlHelper.addWhereClause(
        where,
        method,
        method.parameters,
        false,
        tableSelector, //SqlHelper.selectorName,
      );

      switch (whereResult) {
        case ValueData<String>():
          break;
        case ValueError<String>():
          return whereResult.wrap();
      }

      result += whereResult.data;
    }

    // close bracket before the delete
    result += ")";

    // the method to execute the delete statement is always .go()
    result += ".go();";

    return ValueResponse.value((result, tableName));
  }

  @override
  ValueResponse<String> parseUsedTable(DeleteStatement statement, MethodElement method, TableSelector tableSelector) {
    // TODO what to do in baseDao?
    return ValueResponse.value(ReCase(statement.table.tableName).pascalCase);
  }
}
