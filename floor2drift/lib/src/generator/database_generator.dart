import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/input_option.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/generator/class_generator.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:source_gen/source_gen.dart';

class DatabaseGenerator extends AnnotationGenerator<Database, Null> {
  final typeConverterChecker = TypeChecker.fromRuntime(TypeConverters);
  final bool useRowClass;

  DatabaseGenerator({required super.inputOption, required this.useRowClass});

  @override
  FutureOr<bool> getImport(LibraryReader library) {
    for (final annotatedElement in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (inputOption.canAnalyze(annotatedElement.element.name ?? "") == false) {
        continue;
      }

      return true;
    }

    return false;
  }

  @override
  (String, Set<String>, Null) generateForAnnotatedElement(
    ClassElement classElement,
    OutputOptionBase outputOption,
    DatabaseState state,
  ) {
    var fileName = outputOption.getFileName(classElement.source.shortName);
    fileName = fileName.replaceAll(".dart", ".g.dart");
    final partDirective = "part '$fileName';";

    final className = classElement.name;
    final schemaVersion = state.schemaVersion;
    var tables = "";

    final newImports = <String>{};

    // always needs drift import
    newImports.add("import 'package:drift/drift.dart';");

    final targetFilePath = outputOption.getFileName((classElement.librarySource as FileSource).file.path);

    for (final entity in state.entities) {
      // If useRowClass is used the Entity needs to be imported for the drift .g.dart file
      if (useRowClass) {
        final entityClassUri = state.floorClasses[entity.name];

        if (entityClassUri != null) {
          final tableImport = BaseHelper.getImport(entityClassUri.librarySource.uri, targetFilePath);

          if (tableImport != null) {
            newImports.add(tableImport);
          }
        }
      }

      tables += "${entity.name}s,";
    }

    if (tables.isNotEmpty) {
      tables = "tables:[$tables],";
    }

    var daos = "";

    for (final dao in state.daos) {
      daos += "${dao.name},";
    }

    if (daos.isNotEmpty) {
      daos = "daos:[$daos],";
    }

    final result = '''@DriftDatabase($tables $daos)
    class $className extends _\$$className {
    $className(super.e);

    @override
    int get schemaVersion => $schemaVersion;
    }
    ''';

    // final migrations = _convertMigrations(
    //   state.migrations,
    //   state.schemaVersion,
    // );

    final documentation = BaseHelper.getDocumentationForElement(classElement);

    return ("$partDirective\n\n$documentation$result", newImports, null);
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

  (Set<ClassElement>, Set<ClassElement>) generateDaoSet(
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

  (Set<ClassElement>, Set<ClassElement>) generateEntitySet(
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
        if (reader.annotatedWith(TypeChecker.fromRuntime(ConvertBaseEntity)).isEmpty) {
          break;
        }

        baseEntities.add(superclass);

        superType = superclass.supertype;
      }

      entities.add(entityClass);
    }

    return (entities, baseEntities);
  }

  Set<TypeConverterClassElement> generateTypeConverterSet(
    ClassElement classElement,
    ConstantReader annotation,
    InputOptionBase inputOption,
  ) {
    final typeConverterAnnotation = typeConverterChecker.firstAnnotationOf(
      classElement,
      throwOnUnresolved: throwOnUnresolved,
    );

    if (typeConverterAnnotation == null) {
      return const {};
    }

    final annotationReader = ConstantReader(typeConverterAnnotation);

    // TODO Should Type Converters be always be converted?
    // TODO best solution would be all actually used typeConverters.
    final typeConverters = annotationReader
        .read("value")
        .objectValue
        .toListValue()
        ?.map((object) {
          final name = object.type?.element?.name;
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

    Set<TypeConverterClassElement> result = {};

    for (final classType in typeConverters) {
      final element = classType.element!.toClassElement;
      final superType = element.supertype;

      if (superType == null) {
        continue;
      }

      if (superType.typeArguments.length != 2) {
        continue;
      }

      final fromType = superType.typeArguments[0].element;

      final toType = superType.typeArguments[1];

      if (fromType == null) {
        throw ArgumentError("Couldn't determine generic elements for typeConverter $classType");
      }

      result.add(TypeConverterClassElement(element.toClassElement, fromType, toType));
    }

    return result;
  }

  int generateSchemaVersion(ConstantReader annotation) {
    final version = annotation.read("version");
    if (version.isInt == false) {
      throw InvalidGenerationSource("Version in the database annotation is not an int");
    }

    return version.intValue;
  }

  DatabaseState? generateDatabaseState(LibraryReader library, InputOptionBase inputOption) {
    DatabaseState? result;

    for (var annotatedElement in library.annotatedWith(typeChecker, throwOnUnresolved: throwOnUnresolved)) {
      if (result != null) {
        throw InvalidGenerationSource("Got Multiple Classes annotated with @Database expected one");
      }

      final classElement = annotatedElement.element.toClassElement;

      final typeConverters = generateTypeConverterSet(classElement, annotatedElement.annotation, inputOption);

      final (daos, baseDaos) = generateDaoSet(classElement, annotatedElement.annotation, inputOption);

      final (entities, baseEnities) = generateEntitySet(classElement, annotatedElement.annotation, inputOption);

      final schemaVersion = generateSchemaVersion(annotatedElement.annotation);

      result = DatabaseState(
        typeConverters: typeConverters,
        databaseClass: classElement.thisType,
        daos: daos,
        baseDaos: baseDaos,
        entities: entities,
        baseEntities: baseEnities,
        schemaVersion: schemaVersion,
        // migrations: inputOption.migrations,
      );
    }

    return result;
  }
}
