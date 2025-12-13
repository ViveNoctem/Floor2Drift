part of 'expression_converter.dart';

///  {@macro ExpressionConverter}
class SubQueryExpressionConverter extends ExpressionConverter<SubQuery> {
  ///  {@macro ExpressionConverter}
  const SubQueryExpressionConverter();

  @override
  ValueResponse<(String, EExpressionType)> parse(
    SubQuery subQuery,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final select = subQuery.select;

    if (select is! SelectStatement) {
      return ValueResponse.error("Only select statement is supported in subquery", element);
    }

    final resultValue = const SelectStatementConverter().parseSubQuery(select, element, parameters, selector);

    switch (resultValue) {
      case ValueError<String>():
        return resultValue.wrap();
      case ValueData<String>():
    }

    return ValueResponse.value((resultValue.data, EExpressionType.unkown));
  }
}
