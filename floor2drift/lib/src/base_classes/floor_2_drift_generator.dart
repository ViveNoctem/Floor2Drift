import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:dart_style/dart_style.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/base_classes/input_option.dart';
import 'package:floor2drift/src/base_classes/output_option.dart';
import 'package:floor2drift/src/base_classes/processing_option.dart';
import 'package:floor2drift/src/element_extension.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/generator/base_entity_generator.dart';
import 'package:floor2drift/src/generator/dao_generator.dart';
import 'package:floor2drift/src/generator/database_generator.dart';
import 'package:floor2drift/src/generator/drift_class_generator.dart';
import 'package:floor2drift/src/generator/entity_generator.dart';
import 'package:floor2drift/src/generator/generated_source.dart';
import 'package:floor2drift/src/generator/type_converter_generator.dart';
import 'package:floor2drift/src/generator/view_generator.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

/// Generator class to migrate a floor database to drift
///
/// See the README.md on how to use this class
class Floor2DriftGenerator {
  /// Options for which files to convert
  final InputOptionBase inputOption;

  /// Options how the files should be converted
  final ProcessingOptionBase processingOption;

  /// Options where the converted will be written to.
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
  /// [convertView] should found [DatabaseView] classes be converted
  /// [useDriftModularCodeGeneration] when set the generated code is changed to work with drift modular code generation
  /// [tableNameSuffix] change the default suffix added to drift table classes
  factory Floor2DriftGenerator({
    required String dbPath,
    String rootPath = "../",
    Glob? classNameFilter,
    String outputFileSuffix = "_drift",
    bool dryRun = false,
    bool convertDao = true,
    bool convertEntity = true,
    bool convertTypeConverter = true,
    bool convertView = true,
    bool useRowClass = true,
    ETableNameOption tableRenaming = ETableNameOption.floorScheme,
    bool useDriftModularCodeGeneration = false,
    String tableNameSuffix = "s",
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
      convertViews: convertView,
      dbFile: dbFile,
      // migrations: migrations,
    );

    final outputOption = OutputOptions(
      dryRun: dryRun,
      fileSuffix: outputFileSuffix,
      isModularCodeGeneration: useDriftModularCodeGeneration,
      tableNameSuffix: tableNameSuffix,
    );

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

    final daoGenerator = inputOption.convertDbDaos
        ? DaoGenerator(inputOption: inputOption, useRowClass: useRowClass)
        : null;

    final typeConverterGenerator = inputOption.convertDbTypeConverters
        ? TypeConverterGenerator(inputOption: inputOption)
        : null;

    final baseEntityGenerator = inputOption.convertDbEntities
        ? BaseEntityGenerator(
            inputOption: inputOption,
            typeConverterGenerator: typeConverterGenerator,
            useRowClass: useRowClass,
          )
        : null;

    final entityGenerator = inputOption.convertDbEntities
        ? EntityGenerator(
            useRowClass: useRowClass,
            inputOption: inputOption,
            tableName: tableNameOption,
            typeConverterGenerator: typeConverterGenerator,
          )
        : null;

    final databaseGenerator = DatabaseGenerator(inputOption: inputOption, useRowClass: useRowClass);

    final viewGenerator = inputOption.convertViews
        ? ViewGenerator(inputOption: inputOption, useRowClass: useRowClass)
        : null;

    return ProcessingOptions(
      typeConverterGenerator: typeConverterGenerator,
      entityGenerator: entityGenerator,
      daoGenerator: daoGenerator,
      baseEntityGenerator: baseEntityGenerator,
      baseDaoGenerator: baseDaoGenerator,
      databaseGenerator: databaseGenerator,
      viewGenerator: viewGenerator,
      outputOption: outputOption,
    );
  }

  /// Starts the generation process
  void start() async {
    DatabaseState? dbState;
    for (final (path, context) in inputOption.getDatabaseFile()) {
      dbState = await processingOption.processDatabaseGenerator(context, path, inputOption);

      if (dbState != null) {
        break;
      }
    }

    if (dbState == null) {
      throw InvalidGenerationSource("Expected one Class with @Database Annotation");
    }

    var newFiles = <String, GeneratedSource>{};

    // order of the generators is specific.
    // entityGenerators must come first to fill the entityClasses and floorClasses in the dbState.
    // baseEntityGenerator muss come before entityGenerator. EntityGenerator expects, that dbState.entityClassStates is filled with alls baseEntityStates
    // order for databaseGenerator shouldn't matter.
    // baseDaoGenerator must come before daoGenerator

    if (inputOption.convertDbEntities) {
      if (processingOption.baseEntityGenerator != null) {
        final (text, classStates) = _processClassElements(
          dbState.baseEntities,
          dbState,
          processingOption.baseEntityGenerator!,
          newFiles,
        );

        newFiles = text;
        dbState.entityClassStates.addAll(classStates);
      }

      if (processingOption.entityGenerator != null) {
        final (text, classStates) = _processClassElements(
          dbState.entities,
          dbState,
          processingOption.entityGenerator!,
          newFiles,
        );
        newFiles = text;

        dbState.entityClassStates.addAll(classStates);
      }

      if (inputOption.convertViews) {
        if (processingOption.viewGenerator != null) {
          final (text, classStates) = _processClassElements(
            dbState.views,
            dbState,
            processingOption.viewGenerator!,
            newFiles,
          );

          newFiles = text;

          dbState.entityClassStates.addAll(classStates);
        }
      }
    }

    final (text1, isNull) = _processClassElements(
      [dbState.databaseClass.element!.toClassElement],
      dbState,
      processingOption.databaseGenerator,
      newFiles,
    );

    newFiles = text1;

    if (inputOption.convertDbDaos) {
      if (processingOption.baseDaoGenerator != null) {
        final (text, isNull) = _processClassElements(
          dbState.baseDaos,
          dbState,
          processingOption.baseDaoGenerator!,
          newFiles,
        );

        newFiles = text;
      }

      if (processingOption.daoGenerator != null) {
        final (text, isNull) = _processClassElements(dbState.daos, dbState, processingOption.daoGenerator!, newFiles);
        newFiles = text;
      }
    }

    if (inputOption.convertDbTypeConverters) {
      if (processingOption.typeConverterGenerator != null) {
        final typeConverters = {
          for (final state in dbState.entityClassStates) ...state.usedTypeConverters.map((s) => s.classElement),
        };

        final (text, isNull) = _processClassElements(
          typeConverters,
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

  (Map<String, GeneratedSource>, List<S>) _processClassElements<T, S>(
    Iterable<ClassElement> classElements,
    DatabaseState dbState,
    DriftClassGenerator<T, S> generator,
    Map<String, GeneratedSource> newFiles,
  ) {
    final generatorResult = <S>[];

    for (final classElement in classElements) {
      final source = classElement.source;

      if (source is! FileSource) {
        print("${classElement.name} is not a FileSource and can't be processed");
        continue;
      }

      final (generatedSource, genResult) = processingOption.processClassElement(classElement, dbState, generator);

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
