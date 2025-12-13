part of 'expression_converter.dart';

///  {@macro ExpressionConverter}
class TupleExpressionConverter extends ExpressionConverter<Tuple> {
  final ExpressionConverterUtil _expressionConverterUtil;

  ///  {@macro ExpressionConverter}
  const TupleExpressionConverter({ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil()})
      : _expressionConverterUtil = expressionConverterUtil;

  @override
  ValueResponse<(String, EExpressionType)> parse(
    Tuple expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    List<String> tupleValues = [];

    for (final childExpression in expression.expressions) {
      final result = _expressionConverterUtil.parseExpression(
        childExpression,
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

      tupleValues.add(result.data.$1);
    }

    final tupleString = tupleValues.reduce((value, element) => "$value, $element");
    return ValueResponse.value(("[$tupleString]", EExpressionType.unkown));
  }
}
