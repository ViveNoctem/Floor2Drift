import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor_annotation/floor_annotation.dart';

/// Base class for all floor annotations that need to be parsed
///
/// some floor classes are private therefore all data classes must be create again for this library
sealed class AnnotationType {
  const AnnotationType();
}

/// {@template UnknownAnnotation}
/// Catch all class for all annotations, that are not yet implemented or arent interessing
/// {@endtemplate
class UnknownAnnotation extends AnnotationType {
  /// {@macro UnknownAnnotation}
  const UnknownAnnotation();
}

/// {@template PrimaryKeyAnnotation}
/// Data class for the floor [primaryKey] annotations
/// {@endtemplate}
class PrimaryKeyAnnotation extends AnnotationType {
  /// Is this primary key AUTO INCREMENT
  final bool autoGenerate;

  /// {@macro PrimaryKeyAnnotation}
  const PrimaryKeyAnnotation(this.autoGenerate);

  /// returns the dart code for this annotations
  String get getStringValue {
    return autoGenerate ? ".autoIncrement()" : "";
  }
}

/// {@template TypeConvertersAnnotation}
/// Data class for the floor [TypeConverters] annotation
/// {@endtemplate}
class TypeConvertersAnnotation extends AnnotationType {
  /// The states of all [TypeConverter] specified
  final Map<Element, TypeConverterState> value;

  /// {@macro TypeConvertersAnnotation}
  const TypeConvertersAnnotation(this.value);
}

/// {@template IgnoreAnnotation}
/// Data class for the floor [ignore] annotation
/// {@endtemplate}
class IgnoreAnnotation extends AnnotationType {
  /// {@macro IgnoreAnnotation}
  const IgnoreAnnotation();
}

/// {@template ColumnInfoAnnotation}
/// Data class for the floor [ColumnInfo] annotation
/// {@endtemplate}
class ColumnInfoAnnotation extends AnnotationType {
  /// The name this field should have in the database
  final String? name;

  /// {@macro ColumnInfoAnnotation}
  const ColumnInfoAnnotation(this.name);

  /// returns the drift code for this annotation
  ///
  /// if the column doesn't get renamed returns an empty string
  String get getDriftNamed {
    return (name != null && name!.isNotEmpty) ? ".named(\"$name\")" : "";
  }
}

/// {@template EntityAnnotation}
/// Data class for the floor [Entity] annotation
/// {@endtemplate}
class EntityAnnotation extends AnnotationType {
  /// The name this entity should have in the database
  final String? tableName;

  /// {@macro EntityAnnotation}
  const EntityAnnotation(this.tableName);
}
