part of 'statement_converter.dart';

/// {@macro StatementConverter}
class DeleteStatementConverter extends StatementConverter<DeleteStatement> {
  final SqlHelper _sqlHelper;

  /// {@macro StatementConverter}
  const DeleteStatementConverter({SqlHelper sqlHelper = const SqlHelper()}) : _sqlHelper = sqlHelper;

  @override
  ValueResponse<String> _parse(
    DeleteStatement statement,
    Element method,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
    DatabaseState dbState,
    TypeSpecification? returnValue,
    bool isView,
  ) {
    final tableFrom = statement.from;

    // for (final state in dbState.entityClassStates) {
    //   if (state.sqlTablename.toLowerCase() != tableFrom.tableName.toLowerCase()) {
    //     continue;
    //   }
    //
    //   tableSelector.currentClassState = state;
    //   break;
    // }

    tableSelector = _sqlHelper.configureTableSelector(tableSelector, dbState, [tableFrom.tableName]);

    var result = "return (delete(${tableSelector.selector})";

    final where = statement.where;

    if (where != null) {
      final whereResult = _sqlHelper.addWhereClause(
        where,
        method,
        parameters,
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

    return ValueResponse.value(result);
  }

  @override
  ValueResponse<List<String>> _parseUsedTable(
    DeleteStatement statement,
    MethodElement method,
    TableSelector tableSelector,
  ) {
    // TODO what to do in baseDao?
    return ValueResponse.value([ReCase(statement.table.tableName).pascalCase]);
  }
}
