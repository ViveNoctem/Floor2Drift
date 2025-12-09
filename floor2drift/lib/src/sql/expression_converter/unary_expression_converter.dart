part of 'expression_converter.dart';

class UnaryExpressionConverter extends ExpressionConverter<UnaryExpression> {
  final ExpressionConverterUtil expressionConverterUtil;

  const UnaryExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    UnaryExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final innerResult = expressionConverterUtil.parseExpression(
      expression.inner,
      element,
      parameters: parameters,
      selector: selector,
    );

    switch (innerResult) {
      case ValueError<(String, EExpressionType)>():
        return innerResult.wrap();
      case ValueData<(String, EExpressionType)>():
    }

    // only support bitwise negation (~) at the moment
    // TODO what else is a UnaryExpression
    if (expression.operator.type != TokenType.tilde) {
      return ValueResponse.error("TokenType ${expression.operator} is not supported in UnaryExpression)", element);
    }

    return ValueResponse.value(("~${innerResult.data.$1}", EExpressionType.unkown));
  }
}
