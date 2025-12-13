import 'package:sqlparser/sqlparser.dart';

class MockLiteral<T> extends Literal<T> {
  @override
  final T value;

  MockLiteral(this.value);

  @override
  R accept<A, R>(AstVisitor<A, R> visitor, A arg) {
    throw UnimplementedError();
  }
}
