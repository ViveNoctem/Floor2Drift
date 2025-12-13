part of 'statement_converter.dart';

/// {@macro StatementConverter}
class SelectStatementConverter extends StatementConverter<SelectStatement> {
  final SqlHelper _sqlHelper;
  final ExpressionConverterUtil _expressionConverterUtil;

  /// {@macro StatementConverter}
  const SelectStatementConverter({
    SqlHelper sqlHelper = const SqlHelper(),
    ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil(),
  })  : _expressionConverterUtil = expressionConverterUtil,
        _sqlHelper = sqlHelper;

  ValueResponse<String> _temp(
    SelectStatement statement,
    Element element,
    List<ParameterElement> parameters,
    TableSelector tableSelector, {
    required bool isSubQuery,
    required TypeSpecification? returnValue,
  }) {
    final column = statement.columns.firstOrNull;

    // use selectOnly instead of select, if an aggregate function is used
    // TODO Wont work with aggregate functions with filter clause because column.expression is AggregateFunctionInvocation
    // TODO disabled for baseDao. Doesn't work at the moment
    final bool useSelectOnly = column != null && column is! StarResultColumn && tableSelector is TableSelectorDao;

    String result;
    var selectOnlyFunctionResult = "";
    var originalSelector = tableSelector.functionSelector;
    if (useSelectOnly) {
      tableSelector.functionSelector = tableSelector.selector;
      if (column is ExpressionResultColumn) {
        final functionResult = _expressionConverterUtil.parseExpression(
          column.expression,
          element,
          parameters: parameters,
          selector: tableSelector,
        );

        switch (functionResult) {
          case ValueData<(String, EExpressionType)>():
            break;
          case ValueError<(String, EExpressionType)>():
            return functionResult.wrap();
        }
        selectOnlyFunctionResult = functionResult.data.$1;
        result =
            // "final \$1 = ${functionResult.data.$1};\n"
            "(selectOnly(${tableSelector.selector}${statement.distinct ? ", distinct: true" : ""})"
            // "..addColumns([\$1])";
            "..addColumns([$selectOnlyFunctionResult])";
      } else {
        return ValueResponse.error("asdasdasdsa", element);
      }
    } else {
      result = "(select(${tableSelector.selector}${statement.distinct ? ", distinct: true" : ""})";
    }

    final where = statement.where;
    if (where != null) {
      final whereResult = _sqlHelper.addWhereClause(where, element, parameters, useSelectOnly, tableSelector);

      switch (whereResult) {
        case ValueData<String>():
          break;
        case ValueError<String>():
          return whereResult.wrap();
      }

      result += whereResult.data;
    }

    final orderBy = statement.orderBy;
    if (orderBy != null && orderBy is OrderBy) {
      final orderByResult = _sqlHelper.addOrderByClause(orderBy, element, parameters, tableSelector, useSelectOnly);

      switch (orderByResult) {
        case ValueError<String>():
          return orderByResult.wrap();
        case ValueData<String>():
      }
      result += orderByResult.data;
    }

    // TODO GROUP BY

    // close bracket before the select
    result += ")";

    // reset the functionSelector to the correct one
    tableSelector.functionSelector = originalSelector;
    if (isSubQuery == false) {
      // if useSelectOnly == true addColumns is always used for the SELECT clause
      // TODO change _getSelectMap to support useSelectOnly
      if (useSelectOnly) {
        var read = ".read($selectOnlyFunctionResult)";

        // TODO should not be checking the column and expression type to find out if the column was converted
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
    return _temp(statement, element, parameters, tableSelector, isSubQuery: true, returnValue: null);
  }

  @override
  ValueResponse<String> _parse(
    SelectStatement statement,
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    final tableFrom = statement.from;

    if (tableFrom is! TableReference) {
      return ValueResponse.error("Only table select statements are supported // $statement", method);
    }

    tableSelector = _sqlHelper.configureTableSelector(tableSelector, dbState, tableFrom.tableName);

    final typeSpecification = BaseHelper.getTypeSpecification(method.returnType);

    final resultValue = _temp(
      statement,
      method,
      method.parameters,
      tableSelector,
      isSubQuery: false,
      returnValue: typeSpecification,
    );

    switch (resultValue) {
      case ValueError<String>():
        return resultValue.wrap();
      case ValueData<String>():
    }

    var result = "return ${resultValue.data}";

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
  ValueResponse<String> _parseUsedTable(SelectStatement statement, MethodElement method, TableSelector tableSelector) {
    final table = statement.table;

    if (table == null) {
      return ValueResponse.error("Couldn't determine table for select statement $statement", method);
    }

    if (table is! TableReference) {
      return ValueResponse.error("Only table references supported for select statements $statement", method);
    }

    return ValueResponse.value(ReCase(table.tableName).pascalCase);
  }
}
