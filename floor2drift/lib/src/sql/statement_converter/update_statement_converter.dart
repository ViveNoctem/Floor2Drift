part of 'statement_converter.dart';

class UpdateStatementConverter extends StatementConverter<UpdateStatement> {
  final SqlHelper sqlHelper;

  const UpdateStatementConverter({this.sqlHelper = const SqlHelper()});

  @override
  ValueResponse<(String, String)> parse(UpdateStatement statement, MethodElement method, TableSelector tableSelector) {
    final tableFrom = statement.table;

    final lowerCaseTableName = "${tableFrom.tableName[0].toLowerCase()}${tableFrom.tableName.substring(1)}s";

    // in baseDao use "table" selector
    // in normal dao use lowerCastableName
    // TODO if multiple tables are used in one dao, the tableSelector needs to be determined by the return type
    final tableGetter = switch (tableSelector) {
      TableSelectorBaseDao() => "updates: {${tableSelector.table}},",
      TableSelectorDao() => "updates: {$lowerCaseTableName},",
    };

    final tableName = "${lowerCaseTableName[0].toUpperCase()}${lowerCaseTableName.substring(1)}";
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
}
