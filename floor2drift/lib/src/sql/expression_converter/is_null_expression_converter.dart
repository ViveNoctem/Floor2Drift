part of 'expression_converter.dart';

///  {@macro ExpressionConverter}
class IsNullExpressionConverter extends ExpressionConverter<IsNullExpression> {
  final ExpressionConverterUtil _expressionConverterUtil;

  ///  {@macro ExpressionConverter}
  const IsNullExpressionConverter({ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil()})
      : _expressionConverterUtil = expressionConverterUtil;

  @override
  ValueResponse<(String, EExpressionType)> parse(
    IsNullExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // NULL IS NULL evaluates to TRUE
    // NULL IS NOT NULL evaluates to FALSE
    if (expression.operand is NullLiteral) {
      return _expressionConverterUtil.parseExpression(
        BooleanLiteral(expression.negated == false),
        element,
        parameters: parameters,
        selector: selector,
        asExpression: asExpression,
      );
    }

    final result = _expressionConverterUtil.parseExpression(
      expression.operand,
      element,
      asExpression: asExpression,
      parameters: parameters,
      selector: selector,
    );

    switch (result) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return result.wrap();
    }

    return ValueResponse.value((
      "${result.data.$1}.is${expression.negated ? "Not" : ""}Null()",
      EExpressionType.unkown,
    ));
  }
}
