part of 'expression_converter.dart';

///  {@macro ExpressionConverter}
class InExpressionConverter extends ExpressionConverter<InExpression> {
  final ExpressionConverterUtil _expressionConverterUtil;

  ///  {@macro ExpressionConverter}
  const InExpressionConverter(
      {ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil(),
      SqlHelper sqlHelper = const SqlHelper()})
        : _expressionConverterUtil = expressionConverterUtil;

  @override
  ValueResponse<(String, EExpressionType)> parse(
    InExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final leftResult = _expressionConverterUtil.parseExpression(
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
    final insideResult = _expressionConverterUtil.parseExpression(
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
