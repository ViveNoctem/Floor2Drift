part of 'statement_converter.dart';

/// {@macro StatementConverter}
class SelectStatementConverter extends StatementConverter<SelectStatement> {
  final SqlHelper _sqlHelper;
  final ExpressionConverterUtil _expressionConverterUtil;

  /// {@macro StatementConverter}
  const SelectStatementConverter({
    SqlHelper sqlHelper = const SqlHelper(),
    ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil(),
  }) : _expressionConverterUtil = expressionConverterUtil,
       _sqlHelper = sqlHelper;

  ValueResponse<String> _parseQueryInternal(
    SelectStatement statement,
    Element element,
    List<ParameterElement> parameters,
    TableSelector tableSelector, {
    required bool isSubQuery,
    required TypeSpecification? returnValue,
    required bool isView,
  }) {
    final column = statement.columns.firstOrNull;

    // use selectOnly instead of select, if an aggregate function is used
    // TODO Wont work with aggregate functions with filter clause because column.expression is AggregateFunctionInvocation
    final bool useSelectOnly = statement.columns.length > 1 || column != null && column is! StarResultColumn;

    var originalSelector = tableSelector.functionSelector;

    final fromResult = _sqlHelper.addFromClause(statement.from, element, tableSelector, parameters, isView);

    switch (fromResult) {
      case ValueError<String>():
        tableSelector.functionSelector = originalSelector;
        return fromResult.wrap();
      case ValueData<String>():
    }

    final fromCode = fromResult.data;

    if (useSelectOnly) {
      tableSelector.useSelector = true;
      if (tableSelector is TableSelectorBaseDao) {
        tableSelector.selector = "${tableSelector.selector}.asDslTable";
      }
    }

    final selectResult = _sqlHelper.addSelectClause(
      statement,
      element,
      parameters,
      tableSelector,
      statement.columns,
      useSelectOnly,
      isView,
    );
    switch (selectResult) {
      case ValueError<(String, String)>():
        tableSelector.useSelector = false;
        tableSelector.functionSelector = originalSelector;
        return selectResult.wrap();
      case ValueData<(String, String)>():
    }

    var (result, selectOnlyFunctionResult) = selectResult.data;

    // from and join has to come before where in view
    if (isView) {
      result += fromCode;
    }

    final where = statement.where;
    if (where != null) {
      final whereResult = _sqlHelper.addWhereClause(where, element, parameters, useSelectOnly, tableSelector);

      switch (whereResult) {
        case ValueData<String>():
          break;
        case ValueError<String>():
          tableSelector.useSelector = false;
          tableSelector.functionSelector = originalSelector;
          return whereResult.wrap();
      }

      result += whereResult.data;
    }

    final orderBy = statement.orderBy;
    if (orderBy != null && orderBy is OrderBy) {
      final orderByResult = _sqlHelper.addOrderByClause(orderBy, element, parameters, tableSelector, useSelectOnly);

      switch (orderByResult) {
        case ValueError<String>():
          tableSelector.useSelector = false;
          tableSelector.functionSelector = originalSelector;
          return orderByResult.wrap();
        case ValueData<String>():
      }
      result += orderByResult.data;
    }

    tableSelector.useSelector = false;

    // TODO GROUP BY

    // close bracket before the select
    // from and join comes after where in normale select statements
    if (isView == false) {
      result += ")";
      result += fromCode;
    }

    // reset the functionSelector to the correct one
    tableSelector.functionSelector = originalSelector;
    if (isSubQuery == false && isView == false) {
      // if useSelectOnly == true addColumns is always used for the SELECT clause
      // TODO change _getSelectMap to support useSelectOnly
      if (useSelectOnly) {
        var read = ".read($selectOnlyFunctionResult)";

        // TODO should not be checking the column and expression type to find out if the column was converted

        // TODO read can only be used if only one column is used with selectOnly. In View this is not needed. Therefore column can be used
        if (column is ExpressionResultColumn) {
          final expression = column.expression;

          if (expression is Reference) {
            final converted = tableSelector.currentFieldState?.isConverted == true;

            if (converted && (element is! MethodElement || _sqlHelper.isNativeSqlType(element.returnType) == false)) {
              read = ".readWithConverter($selectOnlyFunctionResult)";
            }
          }
        }

        // need null assertion if returnValue is not nullable
        if (returnValue != null && returnValue.nullable == false) {
          read += "!";
        }

        result += ".map((${tableSelector.functionSelector}) => ${tableSelector.functionSelector}$read)";
      } else {
        result += _getSelectMap(
          statement.columns,
          parameters,
          element,
          tableSelector, //useSelectOnly ? tableSelector.selector : SqlHelper.selectorName,
        );
      }
    }

    return ValueResponse.value(result);
  }

  /// doen't need to return tablename. floor only supports one table in a query. The subquery has to use the same table
  ValueResponse<String> parseSubQuery(
    SelectStatement statement,
    Element element,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
  ) {
    return _parseQueryInternal(
      statement,
      element,
      parameters,
      tableSelector,
      isSubQuery: true,
      returnValue: null,
      isView: false,
    );
  }

  @override
  ValueResponse<String> _parse(
    SelectStatement statement,
    Element method,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
    DatabaseState dbState,
    TypeSpecification returnValue,
    bool isView,
  ) {
    final tableFrom = statement.from;

    final tablesResult = _sqlHelper.getTablesForFromClause(tableFrom, method);

    switch (tablesResult) {
      case ValueError<List<String>>():
        return tablesResult.wrap();
      case ValueData<List<String>>():
    }

    tableSelector = _sqlHelper.configureTableSelector(tableSelector, dbState, tablesResult.data);

    final typeSpecification = returnValue;

    final resultValue = _parseQueryInternal(
      statement,
      method,
      parameters,
      tableSelector,
      isSubQuery: false,
      returnValue: typeSpecification,
      isView: isView,
    );

    switch (resultValue) {
      case ValueError<String>():
        return resultValue.wrap();
      case ValueData<String>():
    }

    final returnCode = isView ? "" : "return ";

    var result = "$returnCode${resultValue.data}";

    result += _sqlHelper.getGetter(typeSpecification);
    result += ";";

    return ValueResponse.value(result);
  }

  String _getSelectMap(
    List<ResultColumn> columns,
    List<ParameterElement> parameters,
    Element element,
    TableSelector tableSelector,
  ) {
    final column = columns.firstOrNull;

    // no need to map StarResultColumn
    // ExpressionResultColumn seems to be the only type of ResultColumn at the moment we have to map
    if (column == null || column is! ExpressionResultColumn) {
      return "";
    }

    final result = _expressionConverterUtil.parseExpression(
      column.expression,
      element,
      parameters: parameters,
      selector: tableSelector,
    );

    switch (result) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        print(result.error);
        return "";
    }

    // alway use selector name and not tableName because it is an object selector not a table selector
    return ".map((${tableSelector.functionSelector}) => ${result.data.$1})";
  }

  @override
  ValueResponse<List<String>> _parseUsedTable(
    SelectStatement statement,
    MethodElement method,
    TableSelector tableSelector,
  ) {
    final table = statement.table;

    if (table == null) {
      return ValueResponse.error("Couldn't determine table for select statement $statement", method);
    }

    final tableNameResult = _sqlHelper.getTablesForFromClause(statement.from, method);

    switch (tableNameResult) {
      case ValueError<List<String>>():
        return tableNameResult.wrap();
      case ValueData<List<String>>():
    }

    return ValueResponse.value(tableNameResult.data.map((s) => ReCase(s).pascalCase).toList());
  }
}
