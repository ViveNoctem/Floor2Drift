import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/input_option.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// {@template DatabaseGenerator}
/// Converts a database class to the equivalent drift code
/// {@endtemplate}
class DatabaseGenerator extends DriftClassGenerator<Database, Null> {
  final _typeConverterChecker = const TypeChecker.fromRuntime(TypeConverters);
  final bool _useRowClass;

  /// {@macro DatabaseGenerator}
  DatabaseGenerator({required super.inputOption, required bool useRowClass}) : _useRowClass = useRowClass;

  @override
  bool getImport(LibraryReader library, DatabaseState dbState, bool ignoreTypeConverterUsedCheck) {
    for (final annotatedElement in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (inputOption.canAnalyze(annotatedElement.element.name ?? "") == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  @override
  (GeneratedSource, Null) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState state,
    GeneratedSource currentSource,
  ) {
    final className = classElement.name;
    final schemaVersion = state.schemaVersion;
    var tables = "";
    var views = "";

    final newImports = <String>{};

    // always needs drift import
    newImports.add("import 'package:drift/drift.dart';");

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    for (final entity in state.entities) {
      newImports.addAll(_addImport(state, entity.name, targetFilePath));
      tables += "${entity.name}s,";
    }

    if (tables.isNotEmpty) {
      tables = "tables:[$tables],";
    }

    for (final view in state.views) {
      newImports.addAll(_addImport(state, view.name, targetFilePath));
      views += "${view.name}s,";
    }

    if (views.isNotEmpty) {
      views = "views:[$views],";
    }

    var daos = "";

    for (final dao in state.daos) {
      daos += "${dao.name},";
    }

    if (daos.isNotEmpty) {
      daos = "daos:[$daos],";
    }

    final private = outputOption.isModularCodeGeneration ? "" : "_";

    final result =
        '''@DriftDatabase($tables $views $daos)
    class $className extends $private\$$className {
    $className(super.e);

    @override
    int get schemaVersion => $schemaVersion;
    }
    ''';

    // final migrations = _convertMigrations(
    //   state.migrations,
    //   state.schemaVersion,
    // );

    final documentation = const BaseHelper().getDocumentationForElement(classElement);
    final code = "$documentation$result";

    final parts = <String>{};
    var fileName = outputOption.getFileName(classElement.source.shortName);

    if (outputOption.isModularCodeGeneration) {
      fileName = fileName.replaceAll(".dart", ".drift.dart");
      final importDirective = "import '$fileName';";
      newImports.add(importDirective);
    } else {
      fileName = fileName.replaceAll(".dart", ".g.dart");
      final partDirective = "part '$fileName';";
      parts.add(partDirective);
    }

    final generatedSource = currentSource + GeneratedSource(code: code, imports: newImports, parts: parts);

    return (generatedSource, null);
  }

  /// If useRowClass is used the Entity/View needs to be imported for the drift .g.dart file
  Set<String> _addImport(DatabaseState state, String className, String targetFilePath) {
    if (_useRowClass == false) {
      return const {};
    }

    var result = <String>{};

    // ignore: deprecated_member_use_from_same_package
    final entityClassUri = state.floorClasses[className];

    if (entityClassUri != null) {
      final tableImport = const BaseHelper().getImport(entityClassUri.librarySource.uri, targetFilePath);

      if (tableImport != null) {
        result.add(tableImport);
      }
    }

    return result;
  }

  // String _convertMigrations(List<Migration> migrations, int schemaVersion) {
  //   Map<int, List<Migration>> migrationMap = {};
  //
  //   List<int> versionsWithoutMigration = [
  //     for (var i = 1; i <= schemaVersion; i++) i
  //   ];
  //
  //   for (final migration in migrations) {
  //     if (migration.endVersion < migration.startVersion) {
  //       throw InvalidGenerationSource(
  //         "Migration endVersion ${migration.endVersion} is greater than startVersion ${migration.startVersion}",
  //       );
  //     }
  //
  //     for (int i = migration.startVersion; i <= migration.endVersion; i++) {
  //       final removed = versionsWithoutMigration.remove(i);
  //       if (removed == false) {
  //         throw InvalidGenerationSource(
  //             "Version $i is multiple times in the migrations");
  //       }
  //     }
  //   }
  //
  //   return """@override
  //   MigrationStrategy get migration {
  //   return MigrationStrategy(
  //   onCreate: (Migrator m) async {
  //   await m.createAll();
  //   },
  //   onUpgrade: (Migrator m, int from, int to) async {
  //   },
  //   );
  //   }""";
  // }

  (Set<ClassElement>, Set<ClassElement>) _generateDaoSet(
    ClassElement classElement,
    ConstantReader annotation,
    InputOptionBase inputOption,
  ) {
    if (inputOption.convertDbDaos == false) {
      return const ({}, {});
    }

    final daos = <ClassElement>{};
    final baseDaos = <ClassElement>{};

    // TODO can/should floor database classes have fields, that are not daos?
    for (final field in classElement.fields) {
      final daoElement = field.type.element?.toClassElement;

      if (daoElement == null) {
        print("Couldn't resolve element for field $field");
        continue;
      }

      if (inputOption.canAnalyze(daoElement.name) == false) {
        continue;
      }

      daos.add(daoElement);

      var superType = daoElement.supertype;

      while (superType != null && superType.isDartCoreObject == false && superType.isDartCoreEnum == false) {
        final superclass = superType.element.toClassElement;
        baseDaos.add(superclass);

        superType = superclass.supertype;
      }
    }

    return (daos, baseDaos);
  }

  (Set<ClassElement>, Set<ClassElement>) _generateEntitySet(
    ClassElement classElement,
    ConstantReader annotation,
    InputOptionBase inputOption,
  ) {
    if (inputOption.convertDbEntities == false) {
      return const ({}, {});
    }

    final entityReader = annotation.read("entities");

    final list = entityReader.objectValue.toListValue();

    if (list == null) {
      return const ({}, {});
    }

    final entities = <ClassElement>{};
    final baseEntities = <ClassElement>{};

    for (final entity in list) {
      final entityClass = entity.toTypeValue()?.element?.toClassElement;

      if (entityClass == null) {
        continue;
      }

      if (inputOption.canAnalyze(entityClass.name) == false) {
        continue;
      }

      var superType = entityClass.supertype;

      while (superType != null && superType.isDartCoreObject == false && superType.isDartCoreEnum == false) {
        final superclass = superType.element.toClassElement;
        final reader = LibraryReader(superclass.library);
        if (reader.annotatedWith(const TypeChecker.fromRuntime(ConvertBaseEntity)).isEmpty) {
          break;
        }

        baseEntities.add(superclass);

        superType = superclass.supertype;
      }

      entities.add(entityClass);
    }

    return (entities, baseEntities);
  }

  Set<TypeConverterState> _generateTypeConverterSet(
    ClassElement classElement,
    ConstantReader annotation,
    InputOptionBase inputOption,
  ) {
    final typeConverterAnnotation = _typeConverterChecker.firstAnnotationOf(
      classElement,
      throwOnUnresolved: throwOnUnresolved,
    );

    if (typeConverterAnnotation == null) {
      return const {};
    }

    final annotationReader = ConstantReader(typeConverterAnnotation);

    final typeConverters = annotationReader
        .read("value")
        .objectValue
        .toListValue()
        ?.map((object) {
          final name = object.toTypeValue()?.element?.name;
          if (name == null || inputOption.canAnalyze(name) == false) {
            return null;
          }
          return object.toTypeValue();
        })
        .nonNulls
        .toList();

    if (typeConverters == null) {
      return const {};
    }

    Set<TypeConverterState> result = {};

    for (final classType in typeConverters) {
      final element = classType.element!.toClassElement;
      final superType = element.supertype;

      if (superType == null) {
        continue;
      }

      if (superType.typeArguments.length != 2) {
        continue;
      }

      final fromType = superType.typeArguments[0];
      final toType = superType.typeArguments[1];

      result.add(TypeConverterState(element.toClassElement, fromType, toType));
    }

    return result;
  }

  int _generateSchemaVersion(ConstantReader annotation) {
    final version = annotation.read("version");
    if (version.isInt == false) {
      throw InvalidGenerationSource("Version in the database annotation is not an int");
    }

    return version.intValue;
  }

  Set<ClassElement> _generateViewSet(
    ClassElement classElement,
    ConstantReader annotation,
    InputOptionBase inputOption,
  ) {
    if (inputOption.convertDbEntities == false) {
      return const {};
    }

    final entityReader = annotation.read("views");

    final list = entityReader.objectValue.toListValue();

    if (list == null) {
      return const {};
    }

    final views = <ClassElement>{};

    for (final view in list) {
      final viewClass = view.toTypeValue()?.element?.toClassElement;

      if (viewClass == null) {
        continue;
      }

      if (inputOption.canAnalyze(viewClass.name) == false) {
        continue;
      }

      views.add(viewClass);
    }

    return views;
  }

  /// analyses the database from [library] and return a [DatabaseState] for the class
  ///
  /// returns null if no database is found. Throws an [InvalidGenerationSource] exception if multiple databases are found
  DatabaseState? generateDatabaseState(LibraryReader library, InputOptionBase inputOption) {
    DatabaseState? result;

    for (var annotatedElement in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (result != null) {
        throw InvalidGenerationSource("Got Multiple Classes annotated with @Database expected one");
      }

      final classElement = annotatedElement.element.toClassElement;

      final typeConverters = _generateTypeConverterSet(classElement, annotatedElement.annotation, inputOption);

      final (daos, baseDaos) = _generateDaoSet(classElement, annotatedElement.annotation, inputOption);

      final (entities, baseEnities) = _generateEntitySet(classElement, annotatedElement.annotation, inputOption);

      final views = _generateViewSet(classElement, annotatedElement.annotation, inputOption);

      final schemaVersion = _generateSchemaVersion(annotatedElement.annotation);

      result = DatabaseState(
        typeConverters: typeConverters,
        databaseClass: classElement.thisType,
        daos: daos,
        baseDaos: baseDaos,
        entities: entities,
        baseEntities: baseEnities,
        schemaVersion: schemaVersion,
        views: views,
        // migrations: inputOption.migrations,
      );
    }

    return result;
  }
}
