part of 'annotation_converter.dart';

/// {@template ColumnInfoAnnotationConverter}
/// Converts a [DatabaseView] annotation to the [DatabaseViewAnnotation] data class
/// {@endtemplate}
class DatabaseViewAnnotationConverter extends AnnotationConverter<DatabaseView, DatabaseViewAnnotation> {
  /// {@macro ColumnInfoAnnotationConverter}
  const DatabaseViewAnnotationConverter();

  @override
  ValueResponse<DatabaseViewAnnotation> parse(ElementAnnotation annotation) {
    final constantValue = annotation.computeConstantValue();

    if (constantValue == null) {
      return ValueResponse.error("Couldn't compute constant value for annotation", annotation.element);
    }

    final viewName = constantValue.getField("viewName")?.toStringValue();
    final query = constantValue.getField("query")?.toStringValue();

    if (query == null) {
      return ValueResponse.error("Couldn't find query for databaseView", annotation.element);
    }

    return ValueResponse.value(DatabaseViewAnnotation(query, viewName));
  }
}
