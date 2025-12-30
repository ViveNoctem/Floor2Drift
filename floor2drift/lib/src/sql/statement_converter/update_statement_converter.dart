part of 'statement_converter.dart';

/// {@macro StatementConverter}
class UpdateStatementConverter extends StatementConverter<UpdateStatement> {
  final SqlHelper _sqlHelper;

  /// {@macro StatementConverter}
  const UpdateStatementConverter({SqlHelper sqlHelper = const SqlHelper()}) : _sqlHelper = sqlHelper;

  @override
  ValueResponse<String> _parse(
    UpdateStatement statement,
    Element method,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
    DatabaseState dbState,
    TypeSpecification? returnValue,
    bool isView,
  ) {
    final tableFrom = statement.table;

    // for (final state in dbState.entityClassStates) {
    //   if (state.sqlTablename.toLowerCase() != tableFrom.tableName.toLowerCase()) {
    //     continue;
    //   }
    //
    //   tableSelector.currentClassState = state;
    // }

    tableSelector = _sqlHelper.configureTableSelector(tableSelector, dbState, [tableFrom.tableName]);

    final tableGetter = "updates: {${tableSelector.selector}},";
    final query = statement.span?.text;

    var variables = "[";

    // match : and the word after, to find all variable names in the query
    final matches = RegExp((":\\w+")).allMatches(query!);
    for (final match in matches) {
      final parameterName = match.input.substring(match.start + 1, match.end);

      for (final parameter in parameters) {
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

    return ValueResponse.value(result);
  }

  @override
  ValueResponse<List<String>> _parseUsedTable(
    UpdateStatement statement,
    MethodElement method,
    TableSelector tableSelector,
  ) {
    // TODO what to do in baseDao?
    return ValueResponse.value([ReCase(statement.table.tableName).pascalCase]);
  }
}
