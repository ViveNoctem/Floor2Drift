import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/entity/annotation_converter/classState.dart';

sealed class AnnotationType {
  const AnnotationType();
}

class UnknownAnnotation extends AnnotationType {
  const UnknownAnnotation();
}

class PrimaryKeyAnnotation extends AnnotationType {
  final bool value;

  const PrimaryKeyAnnotation(this.value);

  String get getStringValue {
    return value ? ".autoIncrement()" : "";
  }
}

class TypeConvertersAnnotation extends AnnotationType {
  final Map<Element, TypeConverterState> value;

  const TypeConvertersAnnotation(this.value);
}

class IgnoreAnnotation extends AnnotationType {
  const IgnoreAnnotation();
}

class ColumnInfoAnnotation extends AnnotationType {
  final String? name;

  const ColumnInfoAnnotation(this.name);

  String getDriftNamed() {
    return name != null ? ".named(\"$name\")" : "";
  }
}

class EntityAnnotation extends AnnotationType {
  final String? tableName;

  const EntityAnnotation(this.tableName);
}
