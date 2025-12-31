# Floor2Drift
**Floor2Drift** is dart library to help you migrate from the [Floor](https://pub.dev/packages/floor) orm library to [Drift](https://pub.dev/packages/drift).

The library generates the equivalent drift code for your floor database.
For a (not complete) list of supported features see [Features](#features)

> [!WARNING]
>
> This project is WORK IN PROGRESS.
> 
> Not all floor features are supported at the moment and expect to make some adjustments to the generated code to work properly.

## Getting Started

### 1. Setup dependencies
Add the `floor2Drift` as a dev dependencies and `floor2Drift_annotation` as a regular dependencies to your `pubspec.yaml`.
If you want to convert only part of your database you also need to add `glob`.

```yaml
dependencies:
  floor2drift_annotation: 1.0.0

dev_dependencies:
  floor2drift: 0.1.0

```

```shell
flutter pub add dev:floor2drift floor2drift_annotation
```

### 2. Add annotations for super classes
If your entities/daos inherit fields or queries from a super class you need to annotated these super classes.

Base entities with `@convertBaseEntitiy` and base daos with `@convertBaseDao`.
If the super classes are not annotated the generator will not convert these and the fields/queries will be missing from the output.

### 3. Floor2Drift script

To generate the drift classes you need to write a script and place it under `tool/floor2drift.dart`.
The Script is used to configure the builder and start the generation process.

The `dbPath` should point to the location of your with `@Database` annotated Floor database class.
The `rootPath` should point to the root directory of your flutter project. (Directory in which the `/lib` is).

The `classNameFilter` option can be used to generate dart file for a subset of all files.
If set only Entity/Dao/TypeConverter Classnames which pass the glob will be converted.
This is perfect for initial testing with only one or a few entities.

Use can use the `outputFileSuffix` argument to add a suffix to all generated files. The default value is `"_drift"`.

For all configuration options see: [Configuration](#configuration)

> [!NOTE]
> 
> In the default configuration the generator uses the drift `@UseRowClass` annotation. This is needed if you have any kind of logic in your entity classes.
> 
> See [UseRowClass](#userowclass) for instruction on how to use this option.

```dart
import 'package:floor2drift/floor2drift.dart';
import 'package:glob/glob.dart';

void main(List<String> arguments) async {
  final generator = Floor2DriftGenerator(
    dbPath: "../test_databases/floor_test_database.dart",
    rootPath: "../",
    classNameFilter: Glob("*task*", caseSensitive: false),
  );

  generator.start();
}
```

#### 4.  Drift builder configuration
case_from_dart_to_sql: camelCase is needed for the column names from drift and floor to be the same.

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          case_from_dart_to_sql: camelCase
```


## To be noted

### Annotations
Most of the result of methods annotated with `@Insert` `@Update` `@delete` will be different than the floor equivalent at the moment.

e.g. @Insert will return rowId instead of inserted id. @Update will result nothing or always -1, etc.

**Check your usage of the return values for these kinds of methods.**

## TODOS / Planned Features
see [TODO.md](./TODO.md)

## Database Migrations
At the moment DB migrations have to be converted manually to [drift migrations](https://drift.simonbinder.eu/migrations/).

## Example
The example consists of 2 flutter projects

The initial_project directory contains a very simple todo app with a login in floor.
The converted_project directory contains the same simple todo app but converted to drift using this library.

To run the converted_project the drift files need to be generated and the build_runner has to run 
Generating the drift files
```shell
cd floor2drift/example/converted_project/tool && dart floor2drift.dart
```

Running the build_runner
```shell
cd floor2drift/example/converted_project && dart run build_runner build
```
## Tests
Generate the test drift files
```shell
cd floor2drift/test/tool && dart test_generator.dart
```

Run the build_runner
```shell
cd floor2drift && dart run build_runner build
```

Run all flutter tests
```shell
cd floor2drift && flutter test test/flutter_test
```

Run all dart tests
```shell
cd floor2drift && dart test test/dart_test
```

## Features
Overview over some of the feature, which are already supported.

This ist not an exhaustive list. 
If a feature that you need is not listed here. Try out if it already works or feel free to create an issue.

### Entity
- type converters
  - Including the same priority system, that the closes type converter is used
- default values in the default constructor are added as [drift client default](https://drift.simonbinder.eu/dart_api/tables/#clientdefault)
- inheritance with `@convertBaseEntity`
- enums save the value fo `.index` in the column
- renaming
  - table with `@Entity(tableName: "tableName")`
  - column with `@ColumnInfo(name: "columnName")`
- 

### Dao
- `@Query`: see [expression_converter.dart](./floor2drift/lib/src/sql/expression_converter/expression_converter.dart) and [token_converter](./floor2drift/lib/src/sql/token_converter/token_converter.dart) for all supported sql expressions and tokens
  - custom SELECT, DELETE, and UPDATE statements
- `@delete`, `@insert`, and `@delete` supported, but most return values are wrong
- type converters of the columns are applied for return values and arguments
- Inheritance requires a specific structure at the moment, but is possible with `@convertBaseDao`

## Configuration
### Floor2DriftGenerator
The easiest way to configure this library is to use the `Floor2DriftGenerator` default constructor.

```dart
factory Floor2DriftGenerator({
  required String dbPath,
  String rootPath = "../",
  Glob? classNameFilter,
  String outputFileSuffix = "_drift",
  bool dryRun = false,
  bool convertDao = true,
  bool convertEntity = true,
  bool convertTypeConverter = true,
  bool useRowClass = true,
  ETableNameOption tableRenaming = ETableNameOption.floorScheme,
  bool useDriftModularCodeGeneration = false,
})
```

#### dbPath
The path to the file containing the floor database.

#### rootPath
The path to the root of the project to be converted (parent directory of lib directory)
The default should work for you if the scripts working dir is `/tool/floor2drift.dart`

#### classNameFilter
A [glob](https://pub.dev/packages/glob) to filter the class name that should be converted.
This is used for `@dao`, `@entity` and, `@typeConverter` classes. Found base dao and base entity classes, with the correct annotation, are always converted.

#### outputFileSuffix
If you want to use have the floor and drift files side by side, you can use this option to specify a suffix that will be added to the file name of all generated file for drift classes.

If the suffix is set to an empty string, the generated files will overwrite the existing floor files.

This option will work with imports in the generated files.
If the generated database file imports a generated dao file, the suffix will be added to the import to ensure that the correct file is imported.

#### dryRun
If set to true it will print the paths of files that would be generated instead of writing the files.

#### convertDao
If set to false, dao classes will not be converted.

#### convertEntity
If set to false, entity classes will not be converted.

#### convertTypeConverter
If set to false, type converter classes will not be converted.

#### useRowClass
If set to true all table/entity classes will be annotated with [@UseRowClass](https://drift.simonbinder.eu/dart_api/rows#custom-dataclass) from Drift.

The Drift builder will not generate an own entity class and will use the old Floor entity in the database.
All entities used for this need to implement the `Insertable` interface by implementing `Map<String, Expression> toColumns(bool nullToAbsent);`

If your entity classes are not only data classes and contain any kind of logic, this option should be set to true.

TODO setting the option to false will produce error at the moment.
#### tableRenaming
You can specify which table naming convention should be used. If you want to migrate existing floor databases to drift you should stick with the default `floorScheme`.
Then drift can open the old floor db and migrate it to drift directly.

- `floorScheme` (default)
    - the table name is the same as the class name.
    - overrides with `@Table(name: "NewName")` annotation, will be taken into account.
- `driftScheme`
    - the table name is snake_case version of the class name
- `driftSchemeWithOverride`
    - the same as driftScheme, but the table name can be overridden by the `@Table(name: "NewName")` annotation.
#### useDriftModularCodeGeneration
when set the generated code is changed to work with drift [modular code generation](https://drift.simonbinder.eu/generation_options/modular/)
This is recommended for larger projects.

### Custom Configuration
You can also create a more custom configuration by using the `Floor2DriftGenerator.custom` constructor.
Override the default option objects or implement them yourself.
Beware that some checks to guarantee that the configuration is valid are not done with the custom constructor.