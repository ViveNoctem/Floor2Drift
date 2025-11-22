part of 'expression_converter.dart';

class ReferenceExpressionConverter extends ExpressionConverter<Reference> {
  @override
  ValueResponse<(String, EExpressionType)> parse(
    Reference expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // TODO Test how to use that for type converter
    selector.currentFieldName = expression.columnName;
    return ValueResponse.value((
      "${asExpression ? "$selector." : ""}${expression.columnName}",
      EExpressionType.reference,
    ));
  }
}
