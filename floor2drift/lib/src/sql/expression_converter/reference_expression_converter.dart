part of 'expression_converter.dart';

///  {@macro ExpressionConverter}
class ReferenceExpressionConverter extends ExpressionConverter<Reference> {
  ///  {@macro ExpressionConverter}
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

    ClassState? currentClassState = _getCurrentClassState(selector, expression);

    if (currentClassState == null) {
      return ValueResponse.error("Couldn't determine class state for $expression", element);
    }

    if (selector is TableSelectorDao) {
      selector.selector = currentClassState.driftTableGetter;
    }

    FieldState? currentFieldState;

    for (final fieldState in currentClassState.allFieldStates) {
      if (fieldState.sqlColumnName.toLowerCase() == lowerCaseColumnName) {
        currentFieldState = fieldState;
        break;
      }
    }

    if (currentFieldState == null) {
      return ValueResponse.error("Couldn't determine class field for $expression", element);
    }

    selector.currentFieldState = currentFieldState;

    if (expression.entityName != null) {
      return ValueResponse.value((
        "${selector.useSelector ? selector.selector : selector.functionSelector}.${currentFieldState.fieldName}",
        EExpressionType.reference,
      ));
    }

    return ValueResponse.value((
      "${asExpression ? "${selector.useSelector ? selector.selector : selector.functionSelector}." : ""}${currentFieldState.fieldName}",
      EExpressionType.reference,
    ));
  }

  ClassState? _getCurrentClassState(TableSelector tableSelector, Reference expression) {
    ClassState? currentClassState;

    // TODO check that this aborts if a classState cannot be found
    if (tableSelector.currentClassStates.length == 1) {
      currentClassState = tableSelector.currentClassStates[0];
    } else {
      // views with joins have multiple active classStates
      // TODO iterate thorugh all classStates and find currrentClassState on expression.entitiyName first
      // TODO if nothing found. Try to find it with the fieldName

      if (expression.entityName != null) {
        for (final classState in tableSelector.currentClassStates) {
          if (classState.sqlTablename != expression.entityName) {
            continue;
          }

          currentClassState = classState;
          break;
        }
      }

      if (currentClassState == null) {
        outerLoop:
        for (final classState in tableSelector.currentClassStates) {
          for (final fieldState in classState.allFieldStates) {
            if (fieldState.sqlColumnName != expression.columnName) {
              continue;
            }

            currentClassState = classState;
            break outerLoop;
          }
        }
      }
    }

    if (currentClassState == null) {
      return null;
    }

    switch (tableSelector) {
      case TableSelectorBaseDao():
        // TODO selector is set in configureTableSelector;
        return currentClassState;
      case TableSelectorDao():
        final selectorName = currentClassState.className;
        tableSelector.selector = "${ReCase(selectorName).camelCase}s";
        return currentClassState;
    }
  }
}
