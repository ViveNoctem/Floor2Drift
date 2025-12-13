import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';

class MockInterfaceType extends InterfaceType {
  MockInterfaceType({
    required this.nullabilitySuffix,
    required this.isDartCoreList,
    required this.isDartAsyncFuture,
    required this.isDartAsyncStream,
    required this.typeArguments,
  });

  @override
  NullabilitySuffix nullabilitySuffix;

  @override
  bool isDartCoreList;

  @override
  bool isDartAsyncFuture;

  @override
  bool isDartAsyncStream;

  @override
  List<DartType> typeArguments;

  @override
  R accept<R>(TypeVisitor<R> visitor) {
    throw UnimplementedError();
  }

  @override
  R acceptWithArgument<R, A>(TypeVisitorWithArgument<R, A> visitor, A argument) {
    throw UnimplementedError();
  }

  @override
  List<PropertyAccessorElement> get accessors => throw UnimplementedError();

  @override
  InstantiatedTypeAliasElement? get alias => throw UnimplementedError();

  @override
  List<InterfaceType> get allSupertypes => throw UnimplementedError();

  @override
  InterfaceType? asInstanceOf(InterfaceElement element) {
    throw UnimplementedError();
  }

  @override
  InterfaceType? asInstanceOf2(InterfaceElement2 element) {
    throw UnimplementedError();
  }

  @override
  List<ConstructorElement> get constructors => throw UnimplementedError();

  @override
  List<ConstructorElement2> get constructors2 => throw UnimplementedError();

  @override
  InterfaceElement get element => throw UnimplementedError();

  @override
  InterfaceElement get element2 => throw UnimplementedError();

  @override
  InterfaceElement2 get element3 => throw UnimplementedError();

  @override
  DartType get extensionTypeErasure => throw UnimplementedError();

  @override
  String getDisplayString({bool withNullability = true}) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? getGetter(String name) {
    throw UnimplementedError();
  }

  @override
  MethodElement? getMethod(String name) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? getSetter(String name) {
    throw UnimplementedError();
  }

  @override
  List<GetterElement> get getters => throw UnimplementedError();

  @override
  List<InterfaceType> get interfaces => throw UnimplementedError();

  @override
  bool get isBottom => throw UnimplementedError();

  @override
  bool get isDartAsyncFutureOr => throw UnimplementedError();

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
  ConstructorElement? lookUpConstructor(String? name, LibraryElement library) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpGetter2(
    String name,
    LibraryElement library, {
    bool concrete = false,
    bool inherited = false,
    bool recoveryStatic = false,
  }) {
    throw UnimplementedError();
  }

  @override
  MethodElement? lookUpMethod2(
    String name,
    LibraryElement library, {
    bool concrete = false,
    bool inherited = false,
    bool recoveryStatic = false,
  }) {
    throw UnimplementedError();
  }

  @override
  PropertyAccessorElement? lookUpSetter2(
    String name,
    LibraryElement library, {
    bool concrete = false,
    bool inherited = false,
    bool recoveryStatic = false,
  }) {
    throw UnimplementedError();
  }

  @override
  List<MethodElement> get methods => throw UnimplementedError();

  @override
  List<MethodElement2> get methods2 => throw UnimplementedError();

  @override
  List<InterfaceType> get mixins => throw UnimplementedError();

  @override
  String? get name => throw UnimplementedError();

  @override
  DartType resolveToBound(DartType objectType) {
    throw UnimplementedError();
  }

  @override
  List<SetterElement> get setters => throw UnimplementedError();

  @override
  InterfaceType? get superclass => throw UnimplementedError();

  @override
  List<InterfaceType> get superclassConstraints => throw UnimplementedError();
}
