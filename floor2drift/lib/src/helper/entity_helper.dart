import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../entity/annotation_converter/annotation_converter.dart';
import '../generator/entity_generator.dart';

class ClassHelper {
  const ClassHelper();

  static String mixinSuffix = "Mixin";

  /// returns the dart code for the generated fields and a set of used TypeConverters
  ValueResponse<(String, Set<ClassElement>, List<String>)> generateFields(
    ClassElement classElement,
    Map<DartType, TypeConverterClassElement> typeConverters,
  ) {
    var fieldString = "";
    final usedTypeConverters = <ClassElement>{};
    final convertedFields = <String>[];

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
        case ValueError():
          return fieldResult.wrap();
        case ValueData<(String, ClassElement?, String?)>():
      }
      final (dartCode, typeConverter, fieldName) = fieldResult.data;
      fieldString += dartCode;
      if (typeConverter != null) {
        usedTypeConverters.add(typeConverter);
        convertedFields.add(fieldName!);
      }
    }

    return ValueResponse.value((fieldString, usedTypeConverters, convertedFields));
  }

  ValueResponse<(String, String, Set<ClassElement>, List<String>)> generateInheritanceFields(
    ClassElement annotatedClass,
    Map<DartType, TypeConverterClassElement> typeConverters,
  ) {
    ClassElement? currentElement = annotatedClass;

    // TODO generate annotation
    final annotationResult = getAnnotations(annotatedClass.metadata);

    switch (annotationResult) {
      case ValueData<List<AnnotationType>>():
        break;
      case ValueError<List<AnnotationType>>():
        return annotationResult.wrap();
    }

    // only TypeConverter annotation is supported at the moment
    for (final annotation in annotationResult.data) {
      switch (annotation) {
        case IgnoreAnnotation():
        case PrimaryKeyAnnotation():
        case UnkownAnnotaion():
          continue;
        case TypeConvertersAnnotation():
          typeConverters = <DartType, TypeConverterClassElement>{...typeConverters, ...annotation.value};
          break;
      }
    }

    var fieldString = "";
    var mixinString = "";
    var isSuperType = false;

    final usedTypeConverters = <ClassElement>{};
    final convertedFields = <String>[];

    while (currentElement != null) {
      // generate drift code only for methods in this class
      // add a with mixin clause for every inherited class
      if (isSuperType == false) {
        final result = generateFields(currentElement, typeConverters);

        switch (result) {
          case ValueError():
            return result.wrap();
          case ValueData<(String, Set<ClassElement>, List<String>)>():
        }

        final (dartCode, typeconverterResult, convertedFieldResult) = result.data;

        usedTypeConverters.addAll(typeconverterResult);
        convertedFields.addAll(convertedFieldResult);

        fieldString = dartCode + fieldString;
      }

      final superType = currentElement.supertype?.element;

      if (superType == null || superType is! ClassElement || superType.name == "Object") {
        break;
      }

      isSuperType = true;
      currentElement = superType;

      final reader = LibraryReader(superType.library);
      if (reader.annotatedWith(TypeChecker.fromRuntime(ConvertBaseEntity)).isEmpty) {
        break;
      }

      if (mixinString.isNotEmpty) {
        mixinString += ", ";
      }

      mixinString += "${currentElement.name}$mixinSuffix";
    }

    if (mixinString.isNotEmpty) {
      mixinString = "with $mixinString";
    }

    return ValueResponse.value((fieldString, mixinString, usedTypeConverters, convertedFields));
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
  ValueResponse<(String, ClassElement?, String?)> generateField(
    FieldElement field,
    InterfaceType fieldType,
    Map<DartType, TypeConverterClassElement> typeConverters,
    List<AnnotationType> annotations,
    ConstructorElement? constructor,
  ) {
    final localTypeConverters = Map<DartType, TypeConverterClassElement>.from(typeConverters);
    var metaDataSuffix = "";

    if (constructor != null) {
      for (final parameter in constructor.parameters) {
        if (parameter.name != field.name) {
          continue;
        }

        final defaultValue = parameter.defaultValueCode;

        if (parameter.hasDefaultValue == false || defaultValue == null || defaultValue.isEmpty) {
          break;
        }

        //TODO build_option to change from client_default to server default
        metaDataSuffix += ".clientDefault(() => $defaultValue)";
        break;
      }
    }

    for (final annotation in annotations) {
      switch (annotation) {
        case IgnoreAnnotation():
          return ValueResponse.value(("", null, null));
        case PrimaryKeyAnnotation():
          metaDataSuffix += annotation.getStringValue;
        case TypeConvertersAnnotation():
          localTypeConverters.addAll(annotation.value);
        case UnkownAnnotaion():
          break;
      }
    }

    final usedTypeConverter = localTypeConverters[field.type];

    if (usedTypeConverter != null) {
      // TODO cast Exception?
      fieldType = usedTypeConverter.toType as InterfaceType;
    }

    var returnTypName = fieldType.getDisplayString(withNullability: false);
    var isEnum = fieldType.element is EnumElement;

    if (returnTypName.isEmpty) {
      return ValueResponse.error("Couldn't determine returnType for $field", field);
    }

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

    return ValueResponse.value((
      "$columntype get ${field.name} => $columnCode()${generateFieldSuffix(field, fieldType, usedTypeConverter)}$metaDataSuffix();\n",
      usedTypeConverter?.classElement,
      field.name,
    ));
  }

  String generateFieldSuffix(FieldElement field, InterfaceType fieldType, TypeConverterClassElement? typeConverter) {
    var result = "";

    if (typeConverter != null) {
      // TODO check if name is correct
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
  String getClassHeader(String className, String mixins, String classNameSuffix, bool useRowClass) {
    return "${useRowClass ? "@UseRowClass($className)\n" : ""}class ${getClassName(className, classNameSuffix)} extends Table $mixins {\n";
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
