part of 'dao_method_converter.dart';

/// {@template TransactionMethodConverter}
/// Generates dart code for floor methods annotated with [transaction]
/// {@endtemplate}
class TransactionMethodConverter extends DaoMethodConverter {
  /// {@macro TransactionMethodConverter}
  const TransactionMethodConverter();

  @override
  ValueResponse<String> _parse(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    // header doesn't include async and '{' token as that is part of the method body
    final astNode = method.getNode();
    if (astNode is! MethodDeclaration) {
      return ValueError("Couldn't determine MethodDeclaration AST node", method);
    }

    final nodeBody = astNode.body;
    final keyword = nodeBody.keyword ?? "";
    final star = nodeBody.star ?? "";
    final header = "${method.getDisplayString(multiline: true)} $keyword $star {\n";

    var oldBody = method.source.contents.data.substring(nodeBody.offset, nodeBody.end);

    // remove bracket and sync/async keyword
    final firstBracketIndex = oldBody.indexOf("{");
    oldBody = oldBody.substring(firstBracketIndex + 1);

    // remove closing bracket
    final lastBracketIndex = oldBody.lastIndexOf("}");
    oldBody = oldBody.substring(0, lastBracketIndex);

    final body = """return transaction(() async {
    $oldBody
    });
    }
    """;
    return ValueResponse.value("$header$body");
  }

  @override
  ValueResponse<String> parseUsedTable(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    return ValueResponse.value("");
  }
}
