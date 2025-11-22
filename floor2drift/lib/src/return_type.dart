import 'package:floor2drift/src/enum/enums.dart';

class TypeSpecification {
  final EType type;
  final EType firstTypeArgument;

  /// Only works for [firstTypeArgument] == [EQuantity.single]
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
