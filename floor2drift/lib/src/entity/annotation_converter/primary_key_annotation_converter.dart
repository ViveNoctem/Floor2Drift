part of 'annotation_converter.dart';

/// {@template PrimaryKeyAnnotationConverter}
/// Converts a [PrimaryKey] annotation to the [PrimaryKeyAnnotation] data class
/// {@endtemplate}
class PrimaryKeyAnnotationConverter extends AnnotationConverter<PrimaryKey, PrimaryKeyAnnotation> {
  /// {@macro PrimaryKeyAnnotationConverter}
  const PrimaryKeyAnnotationConverter();

  @override
  ValueResponse<PrimaryKeyAnnotation> parse(ElementAnnotation annotation) {
    final autoGenerate = annotation.computeConstantValue()?.getField("autoGenerate");
    final boolValue = autoGenerate?.toBoolValue();

    if (boolValue == null) {
      return ValueResponse.error("autoGenerate field of primaryKey annotation is null", annotation.element);
    }

    return ValueResponse.value(PrimaryKeyAnnotation(boolValue));
  }
}
