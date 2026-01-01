part of 'annotation_converter.dart';

/// {@template TypeConvertersAnnotationConverter}
/// Converts a [TypeConverters] annotation to the [TypeConvertersAnnotation] data class
/// {@endtemplate}
class TypeConvertersAnnotationConverter extends AnnotationConverter<TypeConverters, TypeConvertersAnnotation> {
  /// {@macro TypeConvertersAnnotationConverter}
  const TypeConvertersAnnotationConverter();

  @override
  ValueResponse<TypeConvertersAnnotation> parse(ElementAnnotation annotation) {
    final value = annotation.computeConstantValue()?.getField("value");
    final listValue = value?.toListValue();

    if (listValue == null) {
      return ValueResponse.error("value field of typeConverters annotation is null", annotation.element);
    }

    Map<DartType, TypeConverterState> resultMap = {};

    for (final dartObject in listValue) {
      final classElement = dartObject.toTypeValue()?.element?.toClassElement;

      if (classElement == null) {
        return ValueResponse.error("TypeConverter $dartObject element is null", annotation.element);
      }

      final supertype = classElement.supertype;

      if (supertype == null) {
        return ValueResponse.error("TypeConverter $dartObject has no superType", annotation.element);
      }

      if (supertype.element.name != "TypeConverter") {
        return ValueResponse.error("TypeConverter $dartObject doesn't extend TypeConverter", annotation.element);
      }

      final typeArgument = supertype.typeArguments;

      if (typeArgument.length != 2) {
        return ValueResponse.error("TypeConverter $dartObject doesn't have 2 type arguments", annotation.element);
      }

      final convertFrom = typeArgument[0];
      final convertTo = typeArgument[1];

      final classType = dartObject.toTypeValue()!;

      resultMap.putIfAbsent(
        convertFrom,
        () => TypeConverterState(classType.element!.toClassElement, convertFrom, convertTo),
      );
    }

    return ValueResponse.value(TypeConvertersAnnotation(resultMap));
  }
}
