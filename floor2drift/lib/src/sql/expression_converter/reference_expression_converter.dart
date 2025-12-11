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
    final lowerCaseColumnName = expression.columnName.toLowerCase();

    FieldState? currentFieldState;

    if (selector.currentClassState == null) {
      return ValueResponse.error("Couldn't determine class state for $expression", element);
    }

    for (final fieldState in selector.currentClassState!.allFieldStates) {
      if (fieldState.sqlColumnName.toLowerCase() == lowerCaseColumnName) {
        currentFieldState = fieldState;
        break;
      }
    }

    if (currentFieldState == null) {
      return ValueResponse.error("Couldn't determine class field for $expression", element);
    }

    selector.currentFieldState = currentFieldState;

    return ValueResponse.value((
      "${asExpression ? "${selector.functionSelector}." : ""}${currentFieldState.fieldName}",
      EExpressionType.reference,
    ));
  }
}
