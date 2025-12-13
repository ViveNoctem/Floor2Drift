part of 'expression_converter.dart';

///  {@macro ExpressionConverter}
class IsExpressionConverter extends ExpressionConverter<IsExpression> {
  final ExpressionConverterUtil _expressionConverterUtil;

  ///  {@macro ExpressionConverter}
  const IsExpressionConverter({ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil()})
      : _expressionConverterUtil = expressionConverterUtil;

  @override
  ValueResponse<(String, EExpressionType)> parse(
    IsExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // IsNull and IsNotNull is parsed as IsExpression
    // but needs specific handling
    if (expression.right is NullLiteral) {
      return _expressionConverterUtil.parseExpression(
        IsNullExpression(expression.left, expression.negated),
        element,
        asExpression: asExpression,
        parameters: parameters,
        selector: selector,
      );
    }

    final leftResult = _expressionConverterUtil.parseExpression(
      expression.left,
      element,
      asExpression: asExpression,
      parameters: parameters,
      selector: selector,
    );

    switch (leftResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return leftResult.wrap();
    }

    final rightResult = _expressionConverterUtil.parseExpression(
      expression.right,
      element,
      asExpression: asExpression,
      parameters: parameters,
      selector: selector,
    );

    switch (rightResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return rightResult.wrap();
    }

    if (asExpression) {
      return ValueResponse.value((
        "${leftResult.data.$1}.is${expression.negated ? "Not" : ""}Exp(${rightResult.data.$1})",
        EExpressionType.unkown,
      ));
    }

    return ValueResponse.value((
      "${leftResult.data.$1}.is${expression.negated ? "Not" : ""}Value(${rightResult.data.$1})",
      EExpressionType.unkown,
    ));
  }
}
