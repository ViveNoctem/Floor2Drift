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
  ValueResponse<(String, Set<ClassElement>, List<String>)> generateFields(
    ClassElement classElement,
    Map<Element, TypeConverterClassElement> typeConverters,
    Map<Element, ClassState> classStates,
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
        case ValueData<(String, ClassElement?, String?, (String, String)?, bool)>():
      }

      final (dartCode, typeConverter, fieldName, newFieldRename, isEnum) = fieldResult.data;
      fieldString += dartCode;

      if (typeConverter != null) {
        usedTypeConverters.add(typeConverter);
        convertedFields.add(fieldName!);
      } else if (isEnum) {
        // enum count as being converted because the intEnum converter is used
        convertedFields.add(fieldName!);
      }

      if (newFieldRename != null) {
        var map = classStates[classElement];

        if (map == null) {
          map = ClassState(classType: classElement.thisType);
          classStates[classElement] = map;
        }

        map.renamedFields[newFieldRename.$1] = newFieldRename.$2;
      }
    }

    return ValueResponse.value((fieldString, usedTypeConverters, convertedFields));
  }

  ValueResponse<(String, String, Set<ClassElement>, List<String>)> generateInheritanceFields(
    ClassElement annotatedClass,
    DatabaseState dbState,
  ) {
    var typeConverters = dbState.typeConverterMap;
    ClassElement? currentElement = annotatedClass;

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
        case UnknownAnnotation():
        case ColumnInfoAnnotation():
          continue;
        case TypeConvertersAnnotation():
          typeConverters = <Element, TypeConverterClassElement>{...typeConverters, ...annotation.value};
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
        final result = generateFields(currentElement, typeConverters, dbState.renameMap);

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

      // add superElement to classState. To add the renames from baseClasses to this class
      final renamed = dbState.renameMap[annotatedClass];
      if (renamed != null) {
        renamed.superElement.add(superType);
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
  // TODO clean up the arguments and return value
  ValueResponse<(String, ClassElement?, String?, (String, String)?, bool isEnum)> generateField(
    FieldElement field,
    InterfaceType fieldType,
    Map<Element, TypeConverterClassElement> typeConverters,
    List<AnnotationType> annotations,
    ConstructorElement? constructor,
  ) {
    final localTypeConverters = Map<Element, TypeConverterClassElement>.from(typeConverters);

    var metaDataSuffix = "";
    ColumnInfoAnnotation? namedAnnotation;

    for (final annotation in annotations) {
      switch (annotation) {
        case IgnoreAnnotation():
          return ValueResponse.value(("", null, null, null, false));
        case PrimaryKeyAnnotation():
          metaDataSuffix += annotation.getStringValue;
        case TypeConvertersAnnotation():
          localTypeConverters.addAll(annotation.value);
        case UnknownAnnotation():
          break;
        case ColumnInfoAnnotation():
          if (namedAnnotation != null) {
            print("Field $field has mulitple ColumnInfo Annotations");
            break;
          }
          namedAnnotation = annotation;
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
        final valueString = usedTypeConverter == null
            ? defaultValue
            : "const ${usedTypeConverter.classElement.name}().toSql($defaultValue)!";
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

    var isEnum = fieldType.element is EnumElement;

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

    // if renamed return the renamed and real name
    final columnRenamed = namedAnnotation != null && namedAnnotation.name != null
        ? (namedAnnotation.name!.toLowerCase(), field.name)
        : null;

    return ValueResponse.value((
      dartCode,
      usedTypeConverter?.classElement,
      field.name,
      columnRenamed,
      isEnum,
    ));
  }

  String generateFieldSuffix(FieldElement field, InterfaceType fieldType, TypeConverterClassElement? typeConverter) {
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
