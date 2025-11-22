part of 'annotation_converter.dart';

class IgnoreAnnotationConverter extends AnnotationConverter<IgnoreAnnotation> {
  @override
  ValueResponse<IgnoreAnnotation> parse(ElementAnnotation annotation) {
    return ValueResponse.value(const IgnoreAnnotation());
  }
}
