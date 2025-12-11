import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/entity/annotation_converter/classState.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../entity/annotation_converter/annotation_converter.dart';
import '../entity/annotation_converter/annotations.dart';
import '../generator/entity_generator.dart';

class ClassHelper {
  const ClassHelper();

  static String mixinSuffix = "Mixin";

  /// returns the dart code for the generated fields and a set of used TypeConverters
  ValueResponse<(String code, Set<FieldState> fieldStates)> generateFields(
    ClassElement classElement,
    Map<Element, TypeConverterState> typeConverters,
  ) {
    var fieldString = "";
    final fieldStates = <FieldState>{};

    for (final field in classElement.fields) {
      final fieldType = field.type;

      if (field.isSynthetic) {
        print("$field is synthetic and is being ignored");
        continue;
      }

      if (field.isStatic) {
        print("$field is static and is being ignored");
        continue;
      }

      if (fieldType is! InterfaceType) {
        print("${field.type} is not an InterfaceType");
        continue;
      }

      // ignore hashCode method
      if (field.name == "hashCode") {
        continue;
      }

      final annotationResult = getAnnotations(field.metadata);

      switch (annotationResult) {
        case ValueError():
          return annotationResult.wrap();
        case ValueData<List<AnnotationType>>():
      }

      final fieldResult = generateField(
        field,
        fieldType,
        typeConverters,
        annotationResult.data,
        classElement.constructors.firstOrNull,
      );

      switch (fieldResult) {
        case ValueError<(String, FieldState?)>():
          return fieldResult.wrap();
        case ValueData<(String, FieldState?)>():
      }

      final (dartCode, fieldState) = fieldResult.data;

      if (fieldState != null) {
        fieldString += "$dartCode\n\n";
        fieldStates.add(fieldState);
      }
    }

    return ValueResponse.value((fieldString, fieldStates));
  }

  ValueResponse<(String code, ClassState classState)> generateInheritanceFields(
    ClassElement annotatedClass,
    DatabaseState dbState,
  ) {
    var typeConverters = dbState.typeConverterMap;

    final annotationResult = getAnnotations(annotatedClass.metadata);

    switch (annotationResult) {
      case ValueData<List<AnnotationType>>():
        break;
      case ValueError<List<AnnotationType>>():
        return annotationResult.wrap();
    }

    String? renamedTableName;

    // only TypeConverter annotation is supported at the moment
    for (final annotation in annotationResult.data) {
      switch (annotation) {
        case IgnoreAnnotation():
        case PrimaryKeyAnnotation():
        case UnknownAnnotation():
        case ColumnInfoAnnotation():
          continue;
        case TypeConvertersAnnotation():
          typeConverters = <Element, TypeConverterState>{...typeConverters, ...annotation.value};
        case EntityAnnotation():
          renamedTableName = annotation.tableName;
      }
    }

    final result = generateFields(annotatedClass, typeConverters);

    switch (result) {
      case ValueError<(String, Set<FieldState>)>():
        return result.wrap();
      case ValueData<(String, Set<FieldState>)>():
    }

    final (dartCode, fieldStates) = result.data;
    final mixins = _getSuperClasses(annotatedClass);

    final classState = ClassState(
      classType: annotatedClass.thisType,
      renamed: renamedTableName,
      className: annotatedClass.name,
      superClasses: mixins,
      fieldStates: fieldStates,
    );

    return ValueResponse.value((dartCode, classState));
  }

  Set<ClassElement> _getSuperClasses(ClassElement annotatedClass) {
    final mixins = <ClassElement>{};

    ClassElement? currentElement = annotatedClass;

    while (currentElement != null) {
      // generate drift code only for methods in this class
      // add a with mixin clause for every inherited class

      final superType = currentElement.supertype?.element;

      if (superType == null || superType is! ClassElement || superType.name == "Object") {
        break;
      }

      currentElement = superType;

      final reader = LibraryReader(superType.library);
      if (reader.annotatedWith(TypeChecker.fromRuntime(ConvertBaseEntity)).isEmpty) {
        break;
      }

      mixins.add(currentElement);
    }

    return mixins;
  }

  ValueResponse<List<AnnotationType>> getAnnotations(List<ElementAnnotation> annotations) {
    List<AnnotationType> result = [];
    for (final annotation in annotations) {
      final valueResult = AnnotationConverter.parseAnnotation(annotation);

      switch (valueResult) {
        case ValueError():
          return valueResult.wrap();

        case ValueData<AnnotationType>():
      }

      result.add(valueResult.data);
    }
    return ValueResponse.value(result);
  }

  /// Returns the string of the generated field the used typeConverter or null and the name of the field if the typeConverter is not null
  // TODO clean up the arguments and return value
  ValueResponse<(String, FieldState? field)> generateField(
    FieldElement field,
    InterfaceType fieldType,
    Map<Element, TypeConverterState> typeConverters,
    List<AnnotationType> annotations,
    ConstructorElement? constructor,
  ) {
    final localTypeConverters = Map<Element, TypeConverterState>.from(typeConverters);

    var metaDataSuffix = "";
    ColumnInfoAnnotation? namedAnnotation;

    for (final annotation in annotations) {
      switch (annotation) {
        case IgnoreAnnotation():
          return ValueResponse.value(("", null));
        case PrimaryKeyAnnotation():
          metaDataSuffix += annotation.getStringValue;
        case TypeConvertersAnnotation():
          localTypeConverters.addAll(annotation.value);
        case ColumnInfoAnnotation():
          if (namedAnnotation != null) {
            print("Field $field has mulitple ColumnInfo Annotations");
            break;
          }
          namedAnnotation = annotation;
        case UnknownAnnotation():
        case EntityAnnotation():
          break;
      }
    }

    final usedTypeConverter = localTypeConverters[field.type.element];

    if (constructor != null) {
      for (final parameter in constructor.parameters) {
        if (parameter.name != field.name) {
          continue;
        }

        final defaultValue = parameter.defaultValueCode;

        // ignore empty or null default value
        if (parameter.hasDefaultValue == false ||
            defaultValue == null ||
            defaultValue.isEmpty ||
            defaultValue == "null") {
          break;
        }

        //TODO build_option to change from client_default to server default
        var valueString = "";
        if (usedTypeConverter != null) {
          valueString = "const ${usedTypeConverter.classElement.name}().toSql($defaultValue)!";
        } else {
          valueString = defaultValue;

          final isEnum = parameter.type.element is EnumElement;

          if (isEnum) {
            valueString += ".index";
          }
        }

        metaDataSuffix += ".clientDefault(() => $valueString)";
        break;
      }
    }

    String? returnTypName = "";
    if (usedTypeConverter != null) {
      if (usedTypeConverter.toType is InterfaceType) {
        fieldType = usedTypeConverter.toType as InterfaceType;
        returnTypName = fieldType.getDisplayString(withNullability: false);
      }
    } else {
      returnTypName = fieldType.getDisplayString(withNullability: false);
    }

    if (returnTypName.isEmpty) {
      return ValueResponse.error("Couldn't determine returnType for $field", field);
    }

    final isEnum = fieldType.element is EnumElement;

    final (columntype, columnCode) = switch (returnTypName) {
      "bool" => const ("BoolColumn", "boolean"),
      "int" => const ("IntColumn", "integer"),
      "DateTime" => const ("DateTimeColumn", "dateTime"),
      "String" => const ("TextColumn", "text"),
      "double" => const ("RealColumn", "real"),
      "Uint8List" => const ("BlobColumn", "blob"),
      // TODO implement enum as string build_option
      _ => isEnum ? ("IntColumn", "intEnum<${fieldType.element.name}>") : const ("", ""),
    };

    if (columntype.isEmpty || columnCode.isEmpty) {
      return ValueResponse.error("$returnTypName is not supported", field);
    }

    final fieldSuffix = generateFieldSuffix(field, fieldType, usedTypeConverter);

    final namedString = namedAnnotation != null ? namedAnnotation.getDriftNamed() : "";

    final documentation = BaseHelper.getDocumentationForElement(field);

    final dartCode =
        "$documentation$columntype get ${field.name} => $columnCode()$namedString$fieldSuffix$metaDataSuffix();\n";

    final fieldState = FieldState(
        fieldElement: field, fieldName: field.name, renamed: namedAnnotation?.name, converted: usedTypeConverter);

    return ValueResponse.value((dartCode, fieldState));
  }

  String generateFieldSuffix(FieldElement field, InterfaceType fieldType, TypeConverterState? typeConverter) {
    var result = "";

    if (typeConverter != null) {
      result += ".map(const ${typeConverter.classElement.name}${EntityGenerator.staticClassNameSuffix}())";
    }

    if (fieldType.nullabilitySuffix == NullabilitySuffix.question) {
      result += ".nullable()";
    }

    return result;
  }

  String handlePrimaryKeyAnnotation(ElementAnnotation metaData) {
    final autoGenerate = metaData.computeConstantValue()?.getField("autoGenerate");
    final boolValue = autoGenerate?.toBoolValue();
    assert(boolValue != null, "autoGenerate sollte nicht null sein");
    if (boolValue == true) {
      return ".autoIncrement()";
    }
    return "";
  }

  String handleDefaultType(String? name) {
    print("type $name is not supported");
    return "";
  }

  /// Appends s to the entity name, drift strips the s for the entity class.
  String getClassHeader(String className, Set<ClassElement> mixinSet, String classNameSuffix, bool useRowClass) {
    var mixinString = "";
    if (mixinSet.isNotEmpty) {
      mixinString = "with ";
    }

    mixinString += mixinSet.map((s) => "${s.name}$mixinSuffix").join(", ");

    return "${useRowClass ? "@UseRowClass($className)\n" : ""}class ${getClassName(className, classNameSuffix)} extends Table $mixinString {\n";
  }

  String getClassName(String className, String classNameSuffix) {
    return "$className${classNameSuffix}s";
  }

  String getMixinHeader(String mixinName) {
    return "mixin $mixinName on Table {\n";
  }

  String closeClass() {
    return "}\n";
  }

  bool isEnum(ParameterElement parameter) {
    TypeChecker enumChecker = const TypeChecker.fromRuntime(Enum);
    final typeElement = parameter.type.element;

    if (typeElement == null) {
      return false;
    }

    return enumChecker.isSuperOf(typeElement);
  }
}

extension ElementX on Element {
  /// returns the analyzer ASTNode for the current element
  AstNode? getNode() {
    final session = this.session;
    if (session == null) {
      return null;
    }

    final parsedLibrary = session.getParsedLibraryByElement(library!);

    if (parsedLibrary is! ParsedLibraryResult) {
      return null;
    }

    final declarationResult = parsedLibrary.getElementDeclaration(this);
    return declarationResult?.node;
  }
}
