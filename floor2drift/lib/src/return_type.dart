import 'package:floor2drift/src/enum/enums.dart';

class TypeSpecification {
  final EType type;
  final EType firstTypeArgument;

  /// If the Type is nullable or not
  ///
  /// If the Type is a List, Future, Stream, Future<List> or Stream<List> the nullablility of the type argument is returned
  final bool nullable;

  /// ClassElement of the Return Type
  ///
  /// if [firstTypeArgument] is [EQuantity.list] it is the ClassElement of the List<T> type argument
  // @Deprecated("Not used at the moment")
  // final ClassElement? classElement;
  const TypeSpecification(
    this.type,
    this.firstTypeArgument,
    this.nullable,
    // this.classElement,
  );
}
