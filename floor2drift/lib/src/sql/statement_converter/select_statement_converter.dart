part of 'statement_converter.dart';

class SelectStatementConverter extends StatementConverter<SelectStatement> {
  final SqlHelper sqlHelper;
  final ExpressionConverterUtil expressionConverterUtil;

  const SelectStatementConverter({
    this.sqlHelper = const SqlHelper(),
    this.expressionConverterUtil = const ExpressionConverterUtil(),
  });

  @override
  ValueResponse<(String, String)> parse(
    SelectStatement statement,
    MethodElement method,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    final tableFrom = statement.from;

    if (tableFrom is! TableReference) {
      return ValueResponse.error("Only table select statements are supported // $statement", method);
    }

    final lowerCaseTableName = "${ReCase(tableFrom.tableName).camelCase}s";

    // in baseDao use "table" selector
    // in normal dao use lowerCastableName
    // TODO if multiple tables are used in one dao, the tableSelector needs to be determined by the return type

    final tableName = ReCase(lowerCaseTableName).pascalCase;

    switch (tableSelector) {
      case TableSelectorBaseDao():
        tableSelector.selector = tableSelector.table;
      // currentClassState is set when creating the TableSelectorBaseDao
      case TableSelectorDao():
        // copied from delete_statement_converter
        tableSelector.entityName = ReCase(tableFrom.tableName).pascalCase;
        tableSelector.selector = lowerCaseTableName;
        tableSelector.currentClassState =
            dbState.renameMap[dbState.tableEntityMap[tableName.substring(0, tableName.length - 1)]];
    }

    // TODO GROUP BY

    final column = statement.columns.firstOrNull;

    // use selectOnly instead of select, if an aggregate function is used
    // TODO Wont work with aggregate functions with filter clause because column.expression is AggregateFunctionInvocation
    final bool useSelectOnly =
        column != null && column is ExpressionResultColumn && column.expression is FunctionExpression;

    String result;
    if (useSelectOnly) {
      final functionResult = expressionConverterUtil.parseExpression(
        column.expression,
        method,
        parameters: method.parameters,
        selector: tableSelector,
      );

      switch (functionResult) {
        case ValueData<(String, EExpressionType)>():
          break;
        case ValueError<(String, EExpressionType)>():
          return functionResult.wrap();
      }

      result =
          "final \$1 = ${functionResult.data.$1};\n"
          "return (selectOnly(${tableSelector.selector}${statement.distinct ? ", distinct: true" : ""})"
          "..addColumns([\$1])";
    } else {
      result = "return (select(${tableSelector.selector}${statement.distinct ? ", distinct: true" : ""})";
    }

    final where = statement.where;
    if (where != null) {
      final whereResult = sqlHelper.addWhereClause(
        where,
        method,
        useSelectOnly,
        // TODO make it easier to get the right selector
        tableSelector, //useSelectOnly ? tableSelector.selector : SqlHelper.selectorName,
      );

      switch (whereResult) {
        case ValueData<String>():
          break;
        case ValueError<String>():
          return whereResult.wrap();
      }

      result += whereResult.data;
    }

    // TODO ORDER BY
    // TODO .orderby([OrderingTerm.asc(categories.id)])

    // close bracket before the select
    result += ")";

    final typeSpecification = BaseHelper.getTypeSpecification(method.returnType);

    // if useSelectOnly == true addColumns is always used for the SELECT clause
    // TODO change _getSelectMap to support useSelectOnly
    if (useSelectOnly) {
      result += ".map((${tableSelector.selector}) => ${tableSelector.selector}.read(\$1))";
    } else {
      result += _getSelectMap(
        statement.columns,
        method.parameters,
        method,
        tableSelector, //useSelectOnly ? tableSelector.selector : SqlHelper.selectorName,
      );
    }

    result += sqlHelper.getGetter(typeSpecification);
    result += ";";

    return ValueResponse.value((result, tableName));
  }

  String _getSelectMap(
    List<ResultColumn> columns,
    List<ParameterElement> parameters,
    Element element,
    TableSelector tableSelector,
  ) {
    // TODO make sure floor really only supports * or queries with 1 column only
    final column = columns.firstOrNull;

    // no need to map StarResultColumn
    // ExpressionResultColumn seems to be the only type of ResultColumn at the moment we have to map
    if (column == null || column is! ExpressionResultColumn) {
      return "";
    }

    final result = expressionConverterUtil.parseExpression(
      column.expression,
      element,
      parameters: parameters,
      selector: tableSelector,
    );

    // TODO handle Expression error
    switch (result) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        print(result.error);
        return "";
    }

    // alway use selector name and not tableName because it is an object selector not a table selector
    return ".map((${tableSelector.selector}) => ${result.data.$1})";
  }

  @override
  ValueResponse<String> parseUsedTable(SelectStatement statement, MethodElement method, TableSelector tableSelector) {
    // TODO what to do in baseDao?
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
