import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template AnnotationHelper}
/// Helper class to provide general methods for handling annotations
/// {@endtemplate}
class AnnotationHelper {
  /// {@macro AnnotationHelper}
  const AnnotationHelper();

  /// return the [Entity] annotation from [classElement]
  ///
  /// returns null if the annotation couldn't be found
  @Deprecated("can probably be repalced with AnnotationConverter")
  AnnotatedElement? getEntityAnnotation(ClassElement classElement) {
    const entityAnnotationChecker = TypeChecker.fromRuntime(Entity);

    final annotation = entityAnnotationChecker.firstAnnotationOfExact(classElement);

    if (annotation == null) {
      return null;
    }

    return AnnotatedElement(ConstantReader(annotation), classElement);
  }

  /// returns the tableName of a [Entity] entityAnnotation
  ///
  /// if [entityAnnotation] is not a [Entity] or no tableName is given returns an empty string
  @Deprecated("can probably be repalced with AnnotationConverter")
  String getEntityAnnotationTableName(AnnotatedElement entityAnnotation) {
    final tableNameReader = entityAnnotation.annotation.read("tableName");

    if (tableNameReader.isString == false) {
      // tableName not used
      return "";
    }

    return tableNameReader.stringValue;
  }
}
