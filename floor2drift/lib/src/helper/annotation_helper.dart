import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

class AnnotationHelper {
  const AnnotationHelper();
  AnnotatedElement? getEntityAnnotation(ClassElement classElement) {
    const entityAnnotationChecker = TypeChecker.fromRuntime(Entity);

    final annotation = entityAnnotationChecker.firstAnnotationOfExact(classElement);

    if (annotation == null) {
      return null;
    }

    return AnnotatedElement(ConstantReader(annotation), classElement);
  }

  String getEntityAnnotationTableName(AnnotatedElement entityAnnotation) {
    final tableNameReader = entityAnnotation.annotation.read("tableName");

    if (tableNameReader.isString == false) {
      // tableName not used
      return "";
    }

    return tableNameReader.stringValue;
  }
}
