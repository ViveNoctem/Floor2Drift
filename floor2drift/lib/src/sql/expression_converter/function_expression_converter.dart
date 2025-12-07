part of 'expression_converter.dart';

class FunctionExpressionConverter extends ExpressionConverter<FunctionExpression> {
  final ExpressionConverterUtil expressionConverterUtil;

  const FunctionExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    FunctionExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final aggregateTypeResult = _parseFunctionName(expression.name, element);

    switch (aggregateTypeResult) {
      case ValueData<EAggregateFunctions>():
        break;
      case ValueError<EAggregateFunctions>():
        return aggregateTypeResult.wrap();
    }

    final feld = expression.parameters;

    if (feld is StarFunctionParameter) {
      if (aggregateTypeResult.data != EAggregateFunctions.count) {
        return ValueResponse.error("star operator is only supported on COUNT aggregate function", element);
      }

      return ValueResponse.value(("countAll()", EExpressionType.unkown));
    }

    if (feld is ExprFunctionParameters) {
      var separator = "";

      if (aggregateTypeResult.data == EAggregateFunctions.groupConcat && feld.parameters.length >= 2) {
        // asExpression = false, drift only accepts String as separator
        final separatorResult = expressionConverterUtil.parseExpression(
          feld.parameters[1],
          element,
          asExpression: false,
          parameters: parameters,
          selector: selector,
        );

        switch (separatorResult) {
          case ValueData<(String, EExpressionType)>():
            break;
          case ValueError<(String, EExpressionType)>():
            return separatorResult.wrap();
        }

        separator = separatorResult.data.$1;
      }

      final dataResult = parseExpressionName(aggregateTypeResult.data, feld.distinct, element, separator);

      final inside = feld.parameters.firstOrNull;
      if (inside == null) {
        return ValueResponse.error("null expression inside FunctionExpression $expression", element);
      }

      // asExpression = false to get a reference without the selector
      final insideResult = expressionConverterUtil.parseExpression(
        inside,
        element,
        asExpression: true,
        parameters: parameters,
        selector: selector,
      );

      switch (insideResult) {
        case ValueData<(String, EExpressionType)>():
          break;
        case ValueError<(String, EExpressionType)>():
          return insideResult.wrap();
      }

      return ValueResponse.value(("${insideResult.data.$1}.$dataResult", EExpressionType.unkown));
    }

    return ValueResponse.error("doesnt support $feld in FunctionExpression $expression", element);
  }

  ValueResponse<EAggregateFunctions> _parseFunctionName(String name, Element element) {
    return switch (name.toUpperCase()) {
      "COUNT" => ValueResponse.value(EAggregateFunctions.count),
      "AVG" => ValueResponse.value(EAggregateFunctions.avg),
      "MIN" => ValueResponse.value(EAggregateFunctions.min),
      "MAX" => ValueResponse.value(EAggregateFunctions.max),
      "SUM" => ValueResponse.value(EAggregateFunctions.sum),
      "TOTAL" => ValueResponse.value(EAggregateFunctions.total),
      "GROUP_CONCAT" || "STRING_AGG" => ValueResponse.value(EAggregateFunctions.groupConcat),
      _ => ValueResponse.error("aggregate function $name is not supported", element),
    };
  }

  String parseExpressionName(EAggregateFunctions functionType, bool distinct, Element element, String separator) {
    return switch (functionType) {
      EAggregateFunctions.count => "count(${distinct ? "distinct: true" : ""})",
      EAggregateFunctions.avg => "avg()",
      EAggregateFunctions.min => "min()",
      EAggregateFunctions.max => "max()",
      EAggregateFunctions.sum => "sum()",
      EAggregateFunctions.total => "total()",
      EAggregateFunctions.groupConcat =>
        "groupConcat(${distinct ? "distinct: true" : ""}${separator.isNotEmpty ? "${distinct ? ", " : ""}separator: $separator" : ""})",
    };
  }
}
