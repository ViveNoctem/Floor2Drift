import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

/// Internal representation for a floor class
///
/// Contains everything the generators needs to know about the floor classes
/// fields, used typeconverters, superclass, etc.
/// When searching for a specific classState be aware that on names of classes/tables/entites
/// .toLowerCase() should always be used because of sqlites case insensitivity
class ClassState {
  final String className;
  final DartType classType;
  final Set<FieldState> _fieldStates;
  final String? renamed;
  final Set<ClassElement> superClasses;
  final Set<ClassState>? superStates;

  ClassState({
    required this.classType,
    required this.renamed,
    required this.className,
    required this.superClasses,
    required Set<FieldState> fieldStates,
    this.superStates,
  }) : _fieldStates = fieldStates;

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

  String get sqlTablename => renamed != null ? renamed! : className;

  @override
  int get hashCode => Object.hash(classType.element, null);

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

/// Internal representation for a floor entity field
class FieldState {
  final String fieldName;
  final FieldElement fieldElement;
  final String? renamed;

  /// The [TypeConverterState] used on this field or null if no type converter is used
  ///
  /// returns null for enums because no explicit type converter is used.
  /// See [isConverted] for that case
  final TypeConverterState? converted;

  const FieldState({
    required this.fieldElement,
    required this.fieldName,
    required this.renamed,
    required this.converted,
  });

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

  String get sqlColumnName => renamed != null ? renamed! : fieldName;
}

class TypeConverterState {
  final ClassElement classElement;
  final DartType fromType;
  final DartType toType;

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
