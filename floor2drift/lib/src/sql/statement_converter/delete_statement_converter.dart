part of 'statement_converter.dart';

class DeleteStatementConverter extends StatementConverter<DeleteStatement> {
  final SqlHelper sqlHelper;

  const DeleteStatementConverter({this.sqlHelper = const SqlHelper()});

  @override
  ValueResponse<(String, String)> parse(DeleteStatement statement, MethodElement method, TableSelector tableSelector) {
    final tableFrom = statement.from;

    final lowerCaseTableName = "${tableFrom.tableName[0].toLowerCase()}${tableFrom.tableName.substring(1)}s";

    // in baseDao use "table" selector
    // in normal dao use lowerCastableName
    // TODO if multiple tables are used in one dao, the tableSelector needs to be determined by the return type
    switch (tableSelector) {
      case TableSelectorBaseDao():
        tableSelector.selector = tableSelector.table;
      case TableSelectorDao():
        // TODO entityName is being set here and in base_dao_generator  and select_statement cconverter copied this too
        tableSelector.entityName = tableFrom.tableName;
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
}
