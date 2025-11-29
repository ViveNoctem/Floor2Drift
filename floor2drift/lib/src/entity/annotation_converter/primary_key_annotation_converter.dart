part of 'annotation_converter.dart';

// TODO if autoGenerate == false maybe override Set<Column<Object>>? get primaryKey => super.primaryKey; to set primary key
class PrimaryKeyAnnotationConverter extends AnnotationConverter<PrimaryKey, PrimaryKeyAnnotation> {
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
