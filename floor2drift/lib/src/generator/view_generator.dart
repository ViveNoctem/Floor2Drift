import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:code_builder/code_builder.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/entity/annotation_converter/annotation_converter.dart';
import 'package:floor2drift/src/entity/annotation_converter/annotations.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/entity_helper.dart';
import 'package:floor2drift/src/helper/sql_helper.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/sql/expression_converter/expression_converter.dart';
import 'package:floor2drift/src/sql/statement_converter/statement_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

class ViewGenerator extends DriftClassGenerator<DatabaseView, ClassState> {
  final bool _useRowClass;

  final EntityHelper _entityHelper;

  const ViewGenerator({
    required super.inputOption,
    required bool useRowClass,
    EntityHelper entityHelper = const EntityHelper(),
  }) : _useRowClass = useRowClass,
       _entityHelper = entityHelper;

  @override
  (GeneratedSource, ClassState) generateForAnnotatedElement(
    ClassElement element,
    OutputOptionBase outputOption,
    DatabaseState dbState,
    GeneratedSource currentSource,
  ) {
    // TODO view generator must be kinda a dao and entity generator
    // TODO query as must be converted to its drift equivalent
    // TODO the class itself must be converted to a classState, that it can be used as as table in other daos

    final targetFilePath = outputOption.getFileName((element.librarySource as FileSource).file.path);
    final classStateResult = _entityHelper.parseEntityFields(element, dbState, true);

    switch (classStateResult) {
      case ValueError<(String, ClassState)>():
        throw InvalidGenerationSource("Error while parsing View: ${classStateResult.error}", element: element);
      case ValueData<(String, ClassState)>():
    }

    final currentClassState = classStateResult.data.$2;

    final header = _getHeader(_useRowClass, currentClassState);

    final newImports = <String>{...currentSource.imports};

    newImports.add("import 'package:drift/drift.dart';");

    newImports.remove("import 'package:floor_annotation/floor_annotation.dart';");
    newImports.remove('import "package:floor_annotation/floor_annotation.dart"');

    if (_useRowClass) {
      final thisImport = const BaseHelper().getImport(element.librarySource.uri, targetFilePath);
      if (thisImport != null) {
        newImports.add(thisImport);
      }
    }

    DatabaseViewAnnotation? databaseView;

    for (final annotation in element.metadata) {
      final parsedAnnotationResult = AnnotationConverter.parseAnnotation(annotation);

      switch (parsedAnnotationResult) {
        case ValueError<AnnotationType>():
          continue;
        case ValueData<AnnotationType>():
      }

      final parseAnnotation = parsedAnnotationResult.data;

      // TODO typeconverter must be taken into account while converting class
      switch (parseAnnotation) {
        case UnknownAnnotation():
        case PrimaryKeyAnnotation():
        case TypeConvertersAnnotation():
        case IgnoreAnnotation():
        case ColumnInfoAnnotation():
        case EntityAnnotation():
          continue;
        case DatabaseViewAnnotation():
          databaseView = parseAnnotation;
          break;
      }
    }

    if (databaseView == null) {
      return throw InvalidGenerationSource("Expected view to have @DatabaseView annotation", element: element);
    }

    final parseResult = SqlHelper.sqlEngine.parse(databaseView.query);

    if (parseResult.errors.isNotEmpty) {
      throw InvalidGenerationSource(
        "encountered problem while parsing ${databaseView.query}\n ${parseResult.errors}",
        element: element,
      );
    }

    final rootNode = parseResult.rootNode;

    // returnType shouldn't matter for ViewGenerator
    const returnType = TypeSpecification(EType.unknown, EType.unknown, true);

    final tableSelector = TableSelectorDao(currentClassStates: []);

    final statementResult = StatementConverter.parseStatement(
      rootNode,
      element,
      [],
      tableSelector,
      dbState,
      returnType,
      true,
    );

    switch (statementResult) {
      case ValueError<String>():
        throw InvalidGenerationSource(statementResult.error, element: element);
      case ValueData<String>():
    }

    final tables = getTables(tableSelector.currentClassStates);

    for (final classState in tableSelector.currentClassStates) {
      final tableImport = const BaseHelper().getClassImport(targetFilePath, classState);

      if (tableImport == null) {
        continue;
      }

      final newImport = outputOption.rewriteExistingImport(tableImport);

      newImports.add(newImport);
    }

    final query =
        """@override
    Query as() => ${statementResult.data}
    """;

    final code = "$header$tables$query}";

    final outputSource = currentSource.copyWith(code: code, imports: newImports);

    return (outputSource, currentClassState);
  }

  String _getHeader(bool useRowClass, ClassState classState) {
    final viewEntityName = classState.className;
    final viewClassName = "${classState.className}s";
    final rowClass = useRowClass ? "@UseRowClass($viewEntityName)\n" : "";
    return "${rowClass}abstract class $viewClassName extends View {\n\n";
  }

  String getTables(List<ClassState> usedTables) {
    var result = "";
    for (final classState in usedTables) {
      result += "${classState.className}s get ${classState.driftTableGetter};\n";
    }

    return "$result\n\n";
  }
}
