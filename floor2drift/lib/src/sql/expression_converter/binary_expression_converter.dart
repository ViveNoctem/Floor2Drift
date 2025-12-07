part of 'expression_converter.dart';

class BinaryExpressionConverter extends ExpressionConverter<BinaryExpression> {
  final ExpressionConverterUtil expressionConverterUtil;

  const BinaryExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    BinaryExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final result = _handleBinaryExpression(
      expression,
      element,
      asExpression: asExpression,
      parameters: parameters,
      selector: selector,
    );

    switch (result) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return result.wrap();
    }

    return ValueResponse.value((result.data, EExpressionType.unkown));
  }

  ValueResponse<String> _handleBinaryExpression(
    BinaryExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final result1 = expressionConverterUtil.parseExpression(
      expression.left,
      element,
      asExpression: true,
      parameters: parameters,
      selector: selector,
    );

    switch (result1) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return result1.wrap();
    }

    final (firstString, firstType) = result1.data;

    final result2 = expressionConverterUtil.parseExpression(
      expression.right,
      element,
      asExpression: asExpression,
      parameters: parameters,
      selector: selector,
    );

    switch (result2) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return result2.wrap();
    }

    final (secondString, secondType) = result2.data;

    final tokenResult = TokenConverter.parseToken(expression.operator.type, firstString, secondString, element);

    // ignore error for parseToken.
    // it only matches part of all tokens
    // if it finds something return the result
    switch (tokenResult) {
      case ValueData<String>():
        return tokenResult;
      case ValueError<String>():
        break;
    }

    // check tokens that need a table reference after
    /*var left = "";
    var right = "";
    if (firstType == EExpressionType.reference) {
      left = firstString;
      right = secondString;
    } else if (secondType == EExpressionType.reference) {
      // TODO find a way to support table reference as second argument
      // TODO fails in <, > expressions, because the operator has to switch to.
      return ValueResponse.error(
          "table reference must be the first argument in a binary expression",
          element);
      // left = secondString;
      // right = firstString;
    } else {
      return ValueResponse.error(
          "No reference type in BinaryExpression", element);
    }*/

    final left = firstString;
    final right = secondString;

    return TokenConverter.parseReferenceToken(
      expression.operator.type,
      left,
      right,
      element,
      asExpression: asExpression,
    );
  }
}
