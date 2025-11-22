import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/build_runner/database_state.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/value_response.dart';

part 'ignore_annotation_converter.dart';
part 'primary_key_annotation_converter.dart';
part 'type_converters_annotation_converter.dart';

sealed class AnnotationConverter<T extends AnnotationType> {
  ValueResponse<T> parse(ElementAnnotation annotation);

  static ValueResponse<AnnotationType> parseAnnotation(ElementAnnotation annotation) {
    // TODO maybe need to try and check the library of the annotation if multiple libraries have similar annotations
    return switch (annotation.element?.displayName) {
      "PrimaryKey" || "primaryKey" => PrimaryKeyAnnotationConverter().parse(annotation),
      "TypeConverters" => TypeConvertersAnnotationConverter().parse(annotation),
      "ignore" => IgnoreAnnotationConverter().parse(annotation),
      _ => ValueResponse.value(UnkownAnnotaion()),
    };
  }
}

sealed class AnnotationType {
  const AnnotationType();
}

class UnkownAnnotaion extends AnnotationType {}

class PrimaryKeyAnnotation extends AnnotationType {
  final bool value;

  const PrimaryKeyAnnotation(this.value);

  String get getStringValue {
    return value ? ".autoIncrement()" : "";
  }
}

class TypeConvertersAnnotation extends AnnotationType {
  final Map<DartType, TypeConverterClassElement> value;

  const TypeConvertersAnnotation(this.value);
}

class IgnoreAnnotation extends AnnotationType {
  const IgnoreAnnotation();
}
