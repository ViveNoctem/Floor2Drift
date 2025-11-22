part of 'expression_converter.dart';

class ParenthesesExpressionConverter extends ExpressionConverter<Parentheses> {
  final ExpressionConverterUtil expressionConverterUtil;

  const ParenthesesExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    Parentheses expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final result = expressionConverterUtil.parseExpression(
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
