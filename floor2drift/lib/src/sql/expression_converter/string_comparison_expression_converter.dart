part of 'expression_converter.dart';

class StringComparisonExpressionConverter extends ExpressionConverter<StringComparisonExpression> {
  final ExpressionConverterUtil expressionConverterUtil;

  const StringComparisonExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    StringComparisonExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final leftResult = expressionConverterUtil.parseExpression(
      expression.left,
      element,
      parameters: parameters,
      asExpression: true,
      selector: selector,
    );

    switch (leftResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return leftResult.wrap();
    }

    final rightResult = expressionConverterUtil.parseExpression(
      expression.right,
      element,
      parameters: parameters,
      asExpression: asExpression,
      selector: selector,
    );

    switch (rightResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return rightResult.wrap();
    }

    // TODO implement expression.escape
    return ValueResponse.value((
      "${leftResult.data.$1}.like${asExpression ? "Exp" : ""}(${rightResult.data.$1})",
      EExpressionType.unkown,
    ));
  }
}
