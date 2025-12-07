part of 'expression_converter.dart';

class ColonNamedVariableExpressionConverter extends ExpressionConverter<ColonNamedVariable> {
  final SqlHelper sqlHelper;
  const ColonNamedVariableExpressionConverter({this.sqlHelper = const SqlHelper()});

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
    final parameter = result.data;
    final isEnum = parameter.element is EnumElement;
    final isList = parameter.type.isDartCoreList;

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

      // TODO isNativeSqlType works for some use cases.
      // TODO For a correct solution the typeConverter to-/ from type is needed
      // TODO e.G. if a String to String converter is used the converter should always be used
      final converted = sqlHelper.checkTypeConverter(selector, name);

      if (converted.isNotEmpty && sqlHelper.isNativeSqlType(parameter.type) == false) {
        return ValueResponse.value(("Variable($converted)", EExpressionType.colonNamedVariable));
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
      // need different selectorName to not be shadowed from different selecotor
      final listSelector = "n";
      final converted = sqlHelper.checkTypeConverter(selector, listSelector);

      // TODO isNativeSqlType works for some use cases.
      // TODO For a correct solution the typeConverter to-/ from type is needed
      // TODO e.G. if a String to String converter is used the converter should always be used
      if (converted.isNotEmpty && sqlHelper.isNativeSqlType(parameter.type) == false) {
        // TODO is '!' needed?
        return ValueResponse.value(
            ("...$name.map(($listSelector) => $converted!)", EExpressionType.colonNamedVariable));
      }

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
