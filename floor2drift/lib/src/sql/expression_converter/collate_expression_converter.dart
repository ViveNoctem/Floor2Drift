part of 'expression_converter.dart';

class CollateExpressionConverter extends ExpressionConverter<CollateExpression> {
  final ExpressionConverterUtil expressionConverterUtil;

  const CollateExpressionConverter({this.expressionConverterUtil = const ExpressionConverterUtil()});

  @override
  ValueResponse<(String, EExpressionType)> parse(
    CollateExpression expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    final innerResult = expressionConverterUtil.parseExpression(
      expression.inner,
      element,
      parameters: parameters,
      selector: selector,
    );

    switch (innerResult) {
      case ValueError<(String, EExpressionType)>():
        return innerResult.wrap();
      case ValueData<(String, EExpressionType)>():
    }

    final collation = _getCollation(expression.collation);

    return ValueResponse.value(("${innerResult.data.$1}.collate($collation)", EExpressionType.unkown));
  }

  String _getCollation(String collation) {
    return switch (collation.toUpperCase()) {
      "NOCASE" => "Collate.noCase",
      "BINARY" => "Collate.binary",
      "RTRIM" => "Collate.rTrim",
      _ => "Collate($collation)",
    };
  }
}

/*
  Future<List<String>> collateMessage() {
    return (selectOnly(testTasks)
          ..addColumns([testTasks.message])
          ..orderBy([OrderingTerm(expression: testTasks.message.collate(Collate.noCase), mode: OrderingMode.desc)]))
        .map((s) => s.read(testTasks.message)!)
        .get();
  }
 */
