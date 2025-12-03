part of 'annotation_converter.dart';

class ColumnInfoAnnotationConverter extends AnnotationConverter<ColumnInfo, ColumnInfoAnnotation> {
  const ColumnInfoAnnotationConverter();

  @override
  ValueResponse<ColumnInfoAnnotation> parse(ElementAnnotation annotation) {
    final name = annotation.computeConstantValue()?.getField("name");
    final stringValue = name?.toStringValue();

    return ValueResponse.value(ColumnInfoAnnotation(stringValue));
  }
}
