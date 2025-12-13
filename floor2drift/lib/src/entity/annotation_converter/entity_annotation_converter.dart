part of 'annotation_converter.dart';

/// {@template EntityAnnotationConverter}
/// Converts a [Entity] annotation to the [EntityAnnotation] data class
/// {@endtemplate}
class EntityAnnotationConverter extends AnnotationConverter<Entity, EntityAnnotation> {
  /// {@macro EntityAnnotationConverter}
  const EntityAnnotationConverter();

  @override
  ValueResponse<EntityAnnotation> parse(ElementAnnotation annotation) {
    final tableName = annotation.computeConstantValue()?.getField("tableName")?.toStringValue();

    return ValueResponse.value(EntityAnnotation(tableName));
  }
}
