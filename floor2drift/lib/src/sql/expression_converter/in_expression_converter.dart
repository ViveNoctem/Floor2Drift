part of 'expression_converter.dart';

class InExpressionConverter extends ExpressionConverter<InExpression> {
  final ExpressionConverterUtil expressionConverterUtil;

  const InExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    InExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // TODO check if asExpression always true is correct
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

    return ValueResponse.value((
      "${leftResult.data.$1}.is${expression.not ? "Not" : ""}In(${insideResult.data.$1})",
      EExpressionType.unkown,
    ));
  }
}
