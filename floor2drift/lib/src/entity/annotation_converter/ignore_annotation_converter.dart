part of 'annotation_converter.dart';

/// {@template IgnoreAnnotationConverter}
/// Converts a [ignore] annotation to the [IgnoreAnnotation] data class
/// {@endtemplate}
class IgnoreAnnotationConverter extends AnnotationConverter<dynamic, IgnoreAnnotation> {
  /// {@macro IgnoreAnnotationConverter}
  const IgnoreAnnotationConverter();

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(ignore.runtimeType);

  @override
  ValueResponse<IgnoreAnnotation> parse(ElementAnnotation annotation) {
    return ValueResponse.value(const IgnoreAnnotation());
  }
}
