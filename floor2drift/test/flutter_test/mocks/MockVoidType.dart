import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';

class MockVoidType extends VoidType {
  @override
  R accept<R>(TypeVisitor<R> visitor) {
    throw UnimplementedError();
  }

  @override
  R acceptWithArgument<R, A>(TypeVisitorWithArgument<R, A> visitor, A argument) {
    throw UnimplementedError();
  }

  @override
  InstantiatedTypeAliasElement? get alias => throw UnimplementedError();

  @override
  InterfaceType? asInstanceOf(InterfaceElement element) {
    throw UnimplementedError();
  }

  @override
  InterfaceType? asInstanceOf2(InterfaceElement2 element) {
    throw UnimplementedError();
  }

  @override
  Null get element => throw UnimplementedError();

  @override
  Null get element2 => throw UnimplementedError();

  @override
  Element2? get element3 => throw UnimplementedError();

  @override
  DartType get extensionTypeErasure => throw UnimplementedError();

  @override
  String getDisplayString({bool withNullability = true}) {
    throw UnimplementedError();
  }

  @override
  bool get isBottom => throw UnimplementedError();

  @override
  bool get isDartAsyncFuture => throw UnimplementedError();

  @override
  bool get isDartAsyncFutureOr => throw UnimplementedError();

  @override
  bool get isDartAsyncStream => throw UnimplementedError();

  @override
  bool get isDartCoreBool => throw UnimplementedError();

  @override
  bool get isDartCoreDouble => throw UnimplementedError();

  @override
  bool get isDartCoreEnum => throw UnimplementedError();

  @override
  bool get isDartCoreFunction => throw UnimplementedError();

  @override
  bool get isDartCoreInt => throw UnimplementedError();

  @override
  bool get isDartCoreIterable => throw UnimplementedError();

  @override
  bool get isDartCoreList => throw UnimplementedError();

  @override
  bool get isDartCoreMap => throw UnimplementedError();

  @override
  bool get isDartCoreNull => throw UnimplementedError();

  @override
  bool get isDartCoreNum => throw UnimplementedError();

  @override
  bool get isDartCoreObject => throw UnimplementedError();

  @override
  bool get isDartCoreRecord => throw UnimplementedError();

  @override
  bool get isDartCoreSet => throw UnimplementedError();

  @override
  bool get isDartCoreString => throw UnimplementedError();

  @override
  bool get isDartCoreSymbol => throw UnimplementedError();

  @override
  bool get isDartCoreType => throw UnimplementedError();

  @override
  bool get isDynamic => throw UnimplementedError();

  @override
  bool isStructurallyEqualTo(dynamic other) {
    throw UnimplementedError();
  }

  @override
  bool get isVoid => throw UnimplementedError();

  @override
  String? get name => throw UnimplementedError();

  @override
  NullabilitySuffix get nullabilitySuffix => throw UnimplementedError();

  @override
  DartType resolveToBound(DartType objectType) {
    throw UnimplementedError();
  }
}
