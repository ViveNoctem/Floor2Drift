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

    tableSelector.currentClassState = dbState.renameMap[dbState.tableEntityMap[tableFrom.tableName]];

    final lowerCaseTableName = "${ReCase(tableFrom.tableName).camelCase}s";

    // in baseDao use "table" selector
    // in normal dao use lowerCastableName
    // TODO if multiple tables are used in one dao, the tableSelector needs to be determined by the return type
    switch (tableSelector) {
      case TableSelectorBaseDao():
        tableSelector.selector = tableSelector.table;
      case TableSelectorDao():
        // TODO entityName is being set here and in base_dao_generator  and select_statement converter copied this too
        tableSelector.entityName = ReCase(tableFrom.tableName).pascalCase;
        tableSelector.selector = lowerCaseTableName;
    }

    final tableName = "${lowerCaseTableName[0].toUpperCase()}${lowerCaseTableName.substring(1)}";

    var result = "return (delete(${tableSelector.selector})";

    final where = statement.where;

    if (where != null) {
      final whereResult = sqlHelper.addWhereClause(
        where,
        method,
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
