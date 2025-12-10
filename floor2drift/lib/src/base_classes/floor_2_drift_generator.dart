import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:dart_style/dart_style.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/input_option.dart';
import 'package:floor2drift/src/base_classes/processing_option.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/generator/base_entity_generator.dart';
import 'package:floor2drift/src/generator/class_generator.dart';
import 'package:floor2drift/src/generator/dao_generator.dart';
import 'package:floor2drift/src/generator/database_generator.dart';
import 'package:floor2drift/src/generator/entity_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

import 'output_option.dart';

class Floor2DriftGenerator {
  final InputOptionBase inputOption;

  final ProcessingOptionBase processingOption;

  final OutputOptionBase outputOption;

  /// Constructor for custom option support
  ///
  /// Use at your own risk.
  Floor2DriftGenerator.custom(this.inputOption, this.processingOption, this.outputOption);

  /// [rootPath] path to the root directory of the project to be converted
  /// [dbPath] path to the file in which the [Database] annotated class is
  /// [classNameFilter] glob pattern to filter which classNames are being converted
  /// [outputFileSuffix] suffix that is added to all generated file. If left empty floor file will be overridden.
  /// [dryRun] if true no files are written only their paths written to the output
  /// [convertDao] should [dao] annotated classes in filed of the [dbPath] class be converted
  /// [convertEntity] should [Database.entities] be converted
  /// [convertTypeConverter] should found [TypeConverter] classes be converted
  factory Floor2DriftGenerator({
    required String dbPath,
    String rootPath = "../",
    Glob? classNameFilter,
    String outputFileSuffix = "Drift",
    bool dryRun = false,
    bool convertDao = true,
    bool convertEntity = true,
    bool convertTypeConverter = true,
    bool useRowClass = true,
    ETableNameOption tableRenaming = ETableNameOption.floorScheme,
  }) {
    final rootEntity = _getRootEntity(rootPath);

    final dbFile = _getDbFile(dbPath);
    final classNameGlob = classNameFilter ?? Glob("*");

    final inputOption = InputOptions(
      root: rootEntity,
      glob: classNameGlob,
      convertDbDaos: convertDao,
      convertDbEntities: convertEntity,
      convertDbTypeConverters: convertTypeConverter,
      dbFile: dbFile,
      // migrations: migrations,
    );

    final outputOption = OutputOptions(root: rootEntity, dryRun: dryRun, fileSuffix: outputFileSuffix);

    final processingOption = _getProcessingOption(inputOption, outputOption, useRowClass, tableRenaming);

    return Floor2DriftGenerator.custom(inputOption, processingOption, outputOption);
  }

  static FileSystemEntity _getRootEntity(String rootPath) {
    final type = FileSystemEntity.typeSync(rootPath);
    final rootEntity = switch (type) {
      // FileSystemEntityType.file => File(rootPath),
      FileSystemEntityType.directory => Directory(rootPath),
      _ => null,
    };

    if (rootEntity == null) {
      throw ArgumentError(
        // "Expected rootPath to be a file or directory",
        "Expected rootPath to be a directory",
        "rootPath",
      );
    }

    return rootEntity;
  }

  static File _getDbFile(String dbPath) {
    final typeDbLocation = FileSystemEntity.typeSync(dbPath);

    if (typeDbLocation != FileSystemEntityType.file) {
      throw ArgumentError("Expected dbPath to be a file", "dbPath");
    }

    return File(dbPath);
  }

  static ProcessingOptions _getProcessingOption(
    InputOptionBase inputOption,
    OutputOptionBase outputOption,
    bool useRowClass,
    ETableNameOption tableNameOption,
  ) {
    final baseDaoGenerator = inputOption.convertDbDaos ? BaseDaoGenerator(inputOption: inputOption) : null;

    final daoGenerator =
        inputOption.convertDbDaos ? DaoGenerator(inputOption: inputOption, useRowClass: useRowClass) : null;

    final baseEntityGenerator = inputOption.convertDbEntities ? BaseEntityGenerator(inputOption: inputOption) : null;

    final entityGenerator =
        inputOption.convertDbEntities
            ? EntityGenerator(
              classNameSuffix: "",
              useRowClass: useRowClass,
              inputOption: inputOption,
              tableName: tableNameOption,
            )
            : null;

    final typeConverterGenerator =
        inputOption.convertDbTypeConverters
            ? TypeConverterGenerator(classNameSuffix: "", inputOption: inputOption)
            : null;

    final databaseGenerator = DatabaseGenerator(inputOption: inputOption, useRowClass: useRowClass);

    return ProcessingOptions(
      typeConverterGenerator: typeConverterGenerator,
      entityGenerator: entityGenerator,
      daoGenerator: daoGenerator,
      baseEntityGenerator: baseEntityGenerator,
      baseDaoGenerator: baseDaoGenerator,
      databaseGenerator: databaseGenerator,
      outputOption: outputOption,
    );
  }

  void start() async {
    DatabaseState? dbState;
    for (final (path, context) in inputOption.getFiles()) {
      dbState = await processingOption.processDatabaseGenerator(context, path, inputOption);

      if (dbState != null) {
        break;
      }
    }

    if (dbState == null) {
      throw InvalidGenerationSource("Expected one Class with @Database Annotation");
    }

    // allTypeConverters.addAll(dbState.typeConverters.map((s) => s.classElement));
    var newFiles = <String, GeneratedSource>{};

    // order of the generators is specific.
    // databaseGenerator always first
    // entityGenerators must come before dao generators. DaoGenerator need the entityClasses in the dbState.
    // baseDaoGenerator must come before daoGenerator

    final (text1, isNull) = await _processClassElements(
      [dbState.databaseClass.element!.toClassElement],
      dbState,
      processingOption.databaseGenerator,
      newFiles,
    );

    newFiles = text1;

    final usedTypeConverters = <ClassElement>{};
    final entityFieldConverted = <String, List<String>>{};

    if (inputOption.convertDbEntities) {
      if (processingOption.entityGenerator != null) {
        final (text, genResult) = await _processClassElements(
          dbState.entities,
          dbState,
          processingOption.entityGenerator!,
          newFiles,
        );
        newFiles = text;

        for (final entry in genResult) {
          usedTypeConverters.addAll(entry.value.$1);
          if (entry.value.$2.isNotEmpty) {
            entityFieldConverted[entry.key] = entry.value.$2;
          }
        }
      }

      if (processingOption.baseEntityGenerator != null) {
        final (text, genResult) = await _processClassElements(
          dbState.baseEntities,
          dbState,
          processingOption.baseEntityGenerator!,
          newFiles,
        );

        newFiles = text;
        // TODO does entityFieldConverted sense?
        // TODO the key is always the base entity name
        // TODO probably for baseDao conversion?
        for (final entry in genResult) {
          usedTypeConverters.addAll(entry.value.$1);
          if (entry.value.$2.isNotEmpty) {
            if (entityFieldConverted.containsKey(entry.key)) {
              entityFieldConverted[entry.key]!.addAll(entry.value.$2);
            } else {
              entityFieldConverted[entry.key] = entry.value.$2;
            }
          }
        }
      }

      // TODO try to find better solution
      // TODO dao generators need to know which field in the current class and super classes are renamed with @ColumnInfo
      // TODO entityGenerator and baseEntityGenerator fill the renameMaps
      // TODO here the renameMaps of the class and the renameMaps of its super classes are being merged.
      for (final entry in dbState.renameMap.entries) {
        for (final superElement in entry.value.superElement) {
          final superRenames = dbState.renameMap[superElement];

          if (superRenames == null) {
            continue;
          }

          entry.value.renamedFields.addAll(superRenames.renamedFields);
        }
      }
    }
    // TODO ok to just add it to the db State?
    dbState.convertedFields = entityFieldConverted;

    if (inputOption.convertDbDaos) {
      if (processingOption.baseDaoGenerator != null) {
        final (text, isNull) = await _processClassElements(
          dbState.baseDaos,
          dbState,
          processingOption.baseDaoGenerator!,
          newFiles,
        );

        newFiles = text;
      }

      if (processingOption.daoGenerator != null) {
        final (text, isNull) = await _processClassElements(
          dbState.daos,
          dbState,
          processingOption.daoGenerator!,
          newFiles,
        );
        newFiles = text;
      }
    }

    if (inputOption.convertDbTypeConverters) {
      if (processingOption.typeConverterGenerator != null) {
        // TODO see doc comment allTypeConverters
        // TODO test usedTypeConverters
        // TODO check if not used TypeConverters are ignored
        final (text, isNull) = await _processClassElements(
          usedTypeConverters,
          dbState,
          processingOption.typeConverterGenerator!,
          newFiles,
        );

        newFiles = text;
      }
    }

    final formatter = DartFormatter();

    for (final entry in newFiles.entries) {
      final formattedContent = formatter.format(entry.value.toFileContent());
      outputOption.writeFile(File(entry.key), formattedContent);
    }
  }

  Future<(Map<String, GeneratedSource>, List<S>)> _processClassElements<T, S>(
    Iterable<ClassElement> classElements,
    DatabaseState dbState,
    AnnotationGenerator<T, S> generator,
    Map<String, GeneratedSource> newFiles,
  ) async {
    final generatorResult = <S>[];

    for (final classElement in classElements) {
      final source = classElement.source;

      if (source is! FileSource) {
        print("${classElement.name} is not a FileSource and can't be processed");
        continue;
      }

      final (generatedSource, genResult) = await processingOption.processClassElement(classElement, dbState, generator);

      if (generatedSource.isEmpty) {
        continue;
      }

      generatorResult.addAll(genResult);

      String newPath = outputOption.getNewPath(source.file.path);

      // if the to be written result already contains a file append only the new class File content
      if (newFiles.containsKey(newPath)) {
        final oldValue = newFiles[newPath];
        newFiles[newPath] = oldValue! + generatedSource;
      } else {
        newFiles[newPath] = generatedSource;
      }
    }

    return (newFiles, generatorResult);
  }
}
