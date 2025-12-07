part of 'expression_converter.dart';

class LiteralExpressionConverter extends ExpressionConverter<Literal> {
  const LiteralExpressionConverter();

  @override
  ValueResponse<(String, EExpressionType)> parse(
    Literal<dynamic> expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    return switch (expression) {
      NullLiteral() || NumericLiteral() || BooleanLiteral() => ValueResponse.value((
        asExpression ? "Variable(${expression.value.toString()})" : expression.value.toString(),
        EExpressionType.unkown,
      )),
      StringLiteral() => ValueResponse.value((
        asExpression ? "Variable(\"${expression.value.toString()}\")" : "\"${expression.value.toString()}\"",
        EExpressionType.unkown,
      )),
      // Special case for TimeConstantLiteral `value` throws `UnimplementedError()` an `toString()` uses `value`
      // TODO implement TimeConstantLiteral
      TimeConstantLiteral() => ValueResponse.error("TimeConstantLiteral() is not supported", element),
      _ => ValueResponse.error("Literal $expression is not supported", element),
    };
  }
}
