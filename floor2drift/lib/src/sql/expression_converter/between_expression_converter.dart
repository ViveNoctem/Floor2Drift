part of 'expression_converter.dart';

class BetweenExpressionConverter extends ExpressionConverter<BetweenExpression> {
  final ExpressionConverterUtil expressionConverterUtil;

  const BetweenExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    BetweenExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // always as expression to make it possible to call .isBetween
    final checkResult = expressionConverterUtil.parseExpression(
      expression.check,
      element,
      asExpression: true,
      parameters: parameters,
      selector: selector,
    );

    switch (checkResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return checkResult.wrap();
    }

    final lowerResult = expressionConverterUtil.parseExpression(
      expression.lower,
      element,
      asExpression: asExpression,
      parameters: parameters,
      selector: selector,
    );

    switch (lowerResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return lowerResult.wrap();
    }

    final upperResult = expressionConverterUtil.parseExpression(
      expression.upper,
      element,
      asExpression: asExpression,
      parameters: parameters,
      selector: selector,
    );

    switch (upperResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return upperResult.wrap();
    }
    //not: false
    return ValueResponse.value((
      "${checkResult.data.$1}.isBetween${asExpression ? "" : "Values"}(${lowerResult.data.$1}, ${upperResult.data.$1}${expression.not ? ", not: true" : ""})",
      EExpressionType.unkown,
    ));
  }
}
