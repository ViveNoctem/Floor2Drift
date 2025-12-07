part of 'expression_converter.dart';

class InExpressionConverter extends ExpressionConverter<InExpression> {
  final ExpressionConverterUtil expressionConverterUtil;
  final SqlHelper sqlHelper;

  const InExpressionConverter(
      {this.expressionConverterUtil = const ExpressionConverterUtil(), this.sqlHelper = const SqlHelper()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    InExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final leftResult = expressionConverterUtil.parseExpression(
      expression.left,
      element,
      asExpression: true,
      parameters: parameters,
      selector: selector,
    );

    switch (leftResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return leftResult.wrap();
    }

    // Tuple, Subquery, Variable (ColonName, Numbered)
    // inside is always as Value not Expression because its easier with List of Values
    final insideResult = expressionConverterUtil.parseExpression(
      expression.inside,
      element,
      asExpression: false,
      parameters: parameters,
      selector: selector,
    );

    switch (insideResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return insideResult.wrap();
    }

    final not = expression.not ? "Not" : "";
    final query = expression.inside is SubQuery ? "Query" : "";
    final isIn = ".is${not}In$query";

    return ValueResponse.value(("${leftResult.data.$1}$isIn(${insideResult.data.$1})", EExpressionType.unkown));
  }
}
