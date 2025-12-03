import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

part 'column_info_annotation_converter.dart';
part 'ignore_annotation_converter.dart';
part 'primary_key_annotation_converter.dart';
part 'type_converters_annotation_converter.dart';

sealed class AnnotationConverter<S, T extends AnnotationType> {
  const AnnotationConverter();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(S);

  ValueResponse<T> parse(ElementAnnotation annotation);

  static ValueResponse<AnnotationType> parseAnnotation(ElementAnnotation annotation) {
    const primaryKeyConverter = PrimaryKeyAnnotationConverter();
    const typeConverterConverter = TypeConvertersAnnotationConverter();
    const ignoreConverter = IgnoreAnnotationConverter();
    const columnInfoConverter = ColumnInfoAnnotationConverter();

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

    return ValueResponse.value(const UnknownAnnotation());
  }
}
