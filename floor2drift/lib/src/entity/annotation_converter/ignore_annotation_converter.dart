part of 'annotation_converter.dart';

class IgnoreAnnotationConverter extends AnnotationConverter<dynamic, IgnoreAnnotation> {
  const IgnoreAnnotationConverter();

  @override
  TypeChecker get typeChecker => TypeChecker.fromRuntime(ignore.runtimeType);

  @override
  ValueResponse<IgnoreAnnotation> parse(ElementAnnotation annotation) {
    return ValueResponse.value(const IgnoreAnnotation());
  }
}
