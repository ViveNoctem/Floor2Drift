part of 'annotation_converter.dart';

class EntityAnnotationConverter extends AnnotationConverter<Entity, EntityAnnotation> {
  const EntityAnnotationConverter();

  @override
  ValueResponse<EntityAnnotation> parse(ElementAnnotation annotation) {
    final tableName = annotation.computeConstantValue()?.getField("tableName")?.toStringValue();

    return ValueResponse.value(EntityAnnotation(tableName));
  }
}
