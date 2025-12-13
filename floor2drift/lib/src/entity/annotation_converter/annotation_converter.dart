import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/entity/annotation_converter/annotations.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

part 'column_info_annotation_converter.dart';
part 'entity_annotation_converter.dart';
part 'ignore_annotation_converter.dart';
part 'primary_key_annotation_converter.dart';
part 'type_converters_annotation_converter.dart';

/// Base class for all Converter classes, that parses differen kinds of annotations used by floor
sealed class AnnotationConverter<S, T extends AnnotationType> {
  const AnnotationConverter();

  /// typeChecker to check if a given element has the annotation this class is used for
  TypeChecker get typeChecker => TypeChecker.fromRuntime(S);

  /// Parses the [annotation] and returns the [AnnotationType] data class for the annotation
  ///
  /// type of the annotation must be checked with [typeChecker] before calling this method
  ValueResponse<T> parse(ElementAnnotation annotation);

  /// Parses the Annotation and return the [AnnotationType] data class
  ///
  /// dispatches the annotation to the real implementations of [AnnotationConverter]
  static ValueResponse<AnnotationType> parseAnnotation(ElementAnnotation annotation) {
    const primaryKeyConverter = PrimaryKeyAnnotationConverter();
    const typeConverterConverter = TypeConvertersAnnotationConverter();
    const ignoreConverter = IgnoreAnnotationConverter();
    const columnInfoConverter = ColumnInfoAnnotationConverter();
    const entityConverter = EntityAnnotationConverter();

    final annotationElement = annotation.element;

    if (annotationElement == null) {
      print("Couldn't determine element for annotation $annotation");
      return ValueResponse.value(UnknownAnnotation());
    }

    final classElement = switch (annotationElement) {
      ConstructorElement() => annotationElement.returnType,
      FunctionTypedElement() => annotationElement.returnType,
      _ => null,
    };

    if (classElement == null) {
      print("Couldn't determine class for annotation $annotation");
      return ValueResponse.value(UnknownAnnotation());
    }

    if (primaryKeyConverter.typeChecker.isExactlyType(classElement)) {
      return primaryKeyConverter.parse(annotation);
    }

    if (typeConverterConverter.typeChecker.isExactlyType(classElement)) {
      return typeConverterConverter.parse(annotation);
    }

    if (ignoreConverter.typeChecker.isExactlyType(classElement)) {
      return ignoreConverter.parse(annotation);
    }

    if (columnInfoConverter.typeChecker.isExactlyType(classElement)) {
      return columnInfoConverter.parse(annotation);
    }

    if (entityConverter.typeChecker.isExactlyType(classElement)) {
      return entityConverter.parse(annotation);
    }

    return ValueResponse.value(const UnknownAnnotation());
  }
}
