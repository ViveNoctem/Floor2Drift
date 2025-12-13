part of 'expression_converter.dart';

///  {@macro ExpressionConverter}
class ParenthesesExpressionConverter extends ExpressionConverter<Parentheses> {
  final ExpressionConverterUtil _expressionConverterUtil;

  ///  {@macro ExpressionConverter}
  const ParenthesesExpressionConverter(
      {ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil()})
      : _expressionConverterUtil = expressionConverterUtil;

  @override
  ValueResponse<(String, EExpressionType)> parse(
    Parentheses expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final result = _expressionConverterUtil.parseExpression(
      expression.expression,
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

    return ValueResponse.value(("(${result.data.$1})", EExpressionType.unkown));
  }
}
