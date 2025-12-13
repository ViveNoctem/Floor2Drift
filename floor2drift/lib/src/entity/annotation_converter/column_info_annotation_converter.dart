part of 'annotation_converter.dart';

/// {@template ColumnInfoAnnotationConverter}
/// Converts a [ColumnInfo] annotation to the [ColumnInfoAnnotation] data class
/// {@endtemplate}
class ColumnInfoAnnotationConverter extends AnnotationConverter<ColumnInfo, ColumnInfoAnnotation> {
  /// {@macro ColumnInfoAnnotationConverter}
  const ColumnInfoAnnotationConverter();

  @override
  ValueResponse<ColumnInfoAnnotation> parse(ElementAnnotation annotation) {
    final name = annotation.computeConstantValue()?.getField("name");
    final stringValue = name?.toStringValue();

    return ValueResponse.value(ColumnInfoAnnotation(stringValue));
  }
}
