part of 'expression_converter.dart';

class ReferenceExpressionConverter extends ExpressionConverter<Reference> {
  const ReferenceExpressionConverter();

  @override
  ValueResponse<(String, EExpressionType)> parse(
    Reference expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // TODO Test how to use that for type converter
    // className Renames are always lowerCase because sqlite is case insensitive
    var fieldName = selector.currentClassState?.renames[expression.columnName.toLowerCase()];
    fieldName ??= expression.columnName;
    selector.currentFieldName = fieldName;
    return ValueResponse.value((
      "${asExpression ? "${selector.functionSelector}." : ""}$fieldName",
      EExpressionType.reference,
    ));
  }
}
