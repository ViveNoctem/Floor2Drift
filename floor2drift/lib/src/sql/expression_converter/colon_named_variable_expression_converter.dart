part of 'expression_converter.dart';

class ColonNamedVariableExpressionConverter extends ExpressionConverter<ColonNamedVariable> {
  @override
  ValueResponse<(String, EExpressionType)> parse(
    ColonNamedVariable expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // strip the semicolon
    final name = expression.name.substring(1);

    final result = _findParameter(name, parameters, element);

    switch (result) {
      case ValueData<ParameterElement>():
        break;
      case ValueError<ParameterElement>():
        return result.wrap();
    }
    final isEnum = result.data.type.element is EnumElement;
    // TODO find better way to handle in (:ids) expression
    // TODO isList is only used when asExpression is false
    final isList = result.data.type.element?.name == "List";

    // TODO List of enums isn't supported in FLOOR
    /*var isListEnum = false;

    if (isList) {
      final dataType = data.type;

      if (dataType is InterfaceType) {
        isListEnum = dataType.typeArguments.firstOrNull?.element is EnumElement;
      }
    }*/

    // TODO add build option to save Enums as String or in in DB
    // TODO currently only int is implemented

    if (asExpression) {
      if (isList) {
        return ValueResponse.error("List not supported in ColonNamedVariable as Expression", element);
      }

      if (selector.convertedFields[selector.entityName] != null) {
        for (final entry in selector.convertedFields[selector.entityName]!) {
          if (selector.currentFieldName != entry) {
            continue;
          }

          final typeConverterString = "${selector.selector}.${selector.currentFieldName}.converter.toSql($name)";
          return ValueResponse.value(("Variable($typeConverterString)", EExpressionType.colonNamedVariable));
        }
      }

      return ValueResponse.value(("Variable($name${isEnum ? ".index" : ""})", EExpressionType.colonNamedVariable));
    }

    // TODO List of enums isn't supported in FLOOR
    /*if (isListEnum) {
      return ValueResponse.value(
        (
          "...$name.map((${SqlHelper.selectorName}) => ${SqlHelper.selectorName}.index)",
          EExpressionType.colonNamedVariable
        ),
      );
    }*/

    if (isList) {
      return ValueResponse.value(("...$name", EExpressionType.colonNamedVariable));
    }

    if (isEnum) {
      return ValueResponse.value(("$name.index", EExpressionType.colonNamedVariable));
    }

    return ValueResponse.value((name, EExpressionType.colonNamedVariable));
  }

  ValueResponse<ParameterElement> _findParameter(String name, List<ParameterElement> parameters, Element element) {
    for (final parameter in parameters) {
      if (parameter.name == name) {
        return ValueResponse.value(parameter);
      }
    }

    return ValueResponse.error("Parameter $name not found in method parameters", element);
  }
}
