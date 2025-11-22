import 'package:sqlparser/sqlparser.dart';

class MockFunctionParameters extends FunctionParameters {
  @override
  R accept<A, R>(AstVisitor<A, R> visitor, A arg) {
    // TODO: implement accept
    throw UnimplementedError();
  }

  @override
  // TODO: implement childNodes
  Iterable<AstNode> get childNodes => throw UnimplementedError();

  @override
  void transformChildren<A>(Transformer<A> transformer, A arg) {
    // TODO: implement transformChildren
  }
}
