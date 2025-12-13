import 'package:floor2drift/src/enum/enums.dart';

/// {@template TypeSpecification}
/// data class that contains general information over the type and the first type argument of a dart type
/// {@endtemplate
class TypeSpecification {
  /// Type of the analyzed type
  final EType type;

  /// Type of the first typeargument if one exists
  final EType firstTypeArgument;

  /// If the Type is nullable or not
  ///
  /// If the Type is a [List], [Future], [Stream], [Future<List>] or [Stream<List>] the nullablility of the type argument is returned
  final bool nullable;

  /// {@macro TypeSpecification}
  const TypeSpecification(
    this.type,
    this.firstTypeArgument,
    this.nullable,
  );
}
