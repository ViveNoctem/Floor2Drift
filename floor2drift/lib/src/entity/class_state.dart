import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template ClassState}
/// Internal representation for a floor class
///
/// Contains everything the generators needs to know about the floor classes
/// fields, used typeconverters, superclass, etc.
/// When searching for a specific classState be aware that on names of classes/tables/entites
/// .toLowerCase() should always be used because of sqlites case insensitivity
/// {@endtemplate}
class ClassState {
  /// Name of this class
  final String className;

  /// DartType for this class
  final DartType classType;

  /// [FieldState]s of all field that existing in the class
  final Set<FieldState> _fieldStates;

  /// Name this class has in the database, if it is being renamed with [Entity]
  final String? renamed;

  /// [ClassElement]s for all entities this class inherits from
  final Set<ClassElement> superClasses;

  /// [ClassState]s for all entities this class inherits from
  ///
  /// is filled after the [BaseDaoGenerator] is done running
  final Set<ClassState>? superStates;

  /// {@macro ClassState}
  ClassState({
    required this.classType,
    required this.renamed,
    required this.className,
    required this.superClasses,
    required Set<FieldState> fieldStates,
    this.superStates,
  }) : _fieldStates = fieldStates;

  /// all [TypeConverter] used in this and its super classes
  ///
  /// is lazy loaded only call after [superStates] was filled
  late final Set<TypeConverterState> usedTypeConverters = _initAllTypeConverters();

  Set<TypeConverterState> _initAllTypeConverters() {
    final result = <TypeConverterState>{};

    for (final field in _fieldStates) {
      if (field.converted == null) {
        continue;
      }
      result.add(field.converted!);
    }

    if (superStates != null) {
      for (final superState in superStates!) {
        result.addAll(superState.usedTypeConverters);
      }
    }

    return result;
  }

  /// all [FieldState]s used in this and its super classes
  ///
  /// is lazy loaded only call after [superStates] was filled
  late final Set<FieldState> allFieldStates = _initAllFieldStates();

  Set<FieldState> _initAllFieldStates() {
    final result = <FieldState>{..._fieldStates};

    if (superStates == null) {
      return result;
    }

    for (final superState in superStates!) {
      result.addAll(superState.allFieldStates);
    }

    return result;
  }

  @override
  bool operator ==(Object other) {
    if (other is! ClassState) {
      return false;
    }

    return identical(this, other) || classType.element == other.classType.element;
  }

  /// returns the name that this class has in the database
  ///
  /// if the class is [renamed] this value is returned else [className] will be returned
  String get sqlTablename => renamed != null ? renamed! : className;

  @override
  int get hashCode => Object.hash(classType.element, null);

  /// {@template copyWith}
  /// copy this class with some arguments changed
  /// all arguments not used will be copied from the old instance
  /// {@endtemplate}
  ClassState copyWith({
    String? className,
    DartType? classType,
    Set<FieldState>? fieldStates,
    String? renamed,
    Set<ClassElement>? superClasses,
    Set<ClassState>? superStates,
  }) {
    return ClassState(
      classType: classType ?? this.classType,
      renamed: renamed ?? this.renamed,
      className: className ?? this.className,
      superClasses: superClasses ?? this.superClasses,
      fieldStates: fieldStates ?? _fieldStates,
      superStates: superStates ?? this.superStates,
    );
  }
}

/// {@template FieldState}
/// Internal representation for a floor entity field
/// {@endtemplate}
class FieldState {
  /// dart name of this field
  final String fieldName;

  /// [FieldElement] for this field
  final FieldElement fieldElement;

  /// Name this filed has in the database, if it is being renamed with [ColumnInfo]
  final String? renamed;

  /// The [TypeConverterState] used on this field or null if no type converter is used
  ///
  /// returns null for enums because no explicit type converter is used.
  /// See [isConverted] for that case
  final TypeConverterState? converted;

  /// {@macro FieldState}
  const FieldState({
    required this.fieldElement,
    required this.fieldName,
    required this.renamed,
    required this.converted,
  });

  /// is a type converter used on this field
  ///
  /// returns true if [converted] is not null or this field is a enum
  bool get isConverted => converted != null || const TypeChecker.fromRuntime(Enum).isSuperTypeOf(fieldElement.type);

  @override
  bool operator ==(Object other) {
    if (other is! FieldState) {
      return false;
    }

    return identical(this, other) || fieldElement == other.fieldElement;
  }

  @override
  int get hashCode => Object.hash(fieldElement, null);

  /// Name of this field in the database
  ///
  /// return [renamed] if not empty. Else [fieldName] is returned
  String get sqlColumnName => (renamed != null && renamed!.isNotEmpty) ? renamed! : fieldName;
}

/// {@template TypeConverterState}
///
/// {@endtemplate}
class TypeConverterState {
  /// [ClassState] of this type converter
  final ClassElement classElement;

  /// The type the converted fields have in the dart code
  final DartType fromType;

  /// The type the converted fields have in the sql database
  final DartType toType;

  /// {@macro TypeConverterState}
  const TypeConverterState(this.classElement, this.fromType, this.toType);

  @override
  bool operator ==(Object other) {
    if (other is! TypeConverterState) {
      return false;
    }

    return identical(this, other) || classElement.thisType.element == other.classElement.thisType.element;
  }

  @override
  int get hashCode => Object.hash(classElement.thisType.element, null);
}
