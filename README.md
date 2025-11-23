# Floor2Drift
> [!WARNING]
> 
>WORK IN PROGRESS
> 
> Simple use cases should work, but expect things to break and to manually fix some things in the generated code

This project is a Flutter/Dart library to help migrate away from the [Floor](https://pub.dev/packages/floor) orm library to [Drift](https://pub.dev/packages/drift).
The library analyzes your flutter project with the [analyzer](https://pub.dev/packages/analyzer) package and generates drift equivalents for all found floor classes.

## Getting Started
To generate the drift classes you need to write a script and place it under `tool/floor2drift.dart`.
The Script is used to configure the builder and start the generation process.

The `dbPath` should point to the location of your with `@Database` annotated Floor database class.
If you put the script under `tool/floor2drift.dart` the rootPath can be left empty. Else this should point to the root directory of your flutter project. (Directory in which the `/lib` is).

The `classNameFilter` option can be used to generate dart file for a subset of all files.
If set only Entity/Dao/TypeConverter Classnames which pass the glob will be converted.
This is perfect for initial testing with only one or a few entities.

For all configuration options see: [Configuration](#configuration)

> [!NOTE]
> 
> The default is use the drift `@UseRowClass` annotation. This is needed if you have any kind of logic in your entity classes.
> 
> See [UseRowClass](#userowclass) for instruction on how to use this option.

```dart
import 'package:floor2drift/src/build_runner/build_runner.dart';
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

#### Dao/Entity Inheritance
If you use Dao or Entity inheritance the base classes needs to the annotated with `@ConvertBaseDao` and `@ConvertBaseEntity` respectively.
The Generators will not generate inherited classes, that have not an annotation 

#### Drift builder configuration
case_from_dart_to_sql: camelCase is needed for the column names from drift and floor to be the same.
`@ColumnInfo` doesn't work at the moment.

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          case_from_dart_to_sql: camelCase
```

## Database Migrations
DB Migrations have to be converted manually to drift migrations

## General differences

### DateTime
Dart does natively support DateTime columns. See the [Drift datetime documentation](https://drift.simonbinder.eu/dart_api/tables/#datetime-options) if you still need a typeConverter for your use case.

### TypeConverters
If a queries uses columns with an TypeConverter floor automatically uses the converter to converter the parameter to the actual sql type.

Drift doesn't do this an expects all parameter to be in the sql column data type, because of this, the generator will apply used typeConverters directly in the dao class to be compatible.

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

## Configuration
### BuildRunner
The easiest way to configure this libarary is to use the `BuildRunner` default constructor.

```dart
factory BuildRunner({
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
})
```

#### dbPath
The path to the file containing the floor database.

The library analyzes the first class with the `@Databse` annotation and will generate drift equivalents for entities, daos, etc. used in this database.

#### rootPath
The path to the root of the project to be converted.
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

If your entity classes are not only data classes and contain any kind of logig, this option should be set to true.

TODO setting the option to false will produce error at the moment.
#### tableRenaming
You can specify which table naming convention should be used. If you want to migrate existing floor databases to drift you should stick with the default `floorScheme`.
Then drift can open the old floor db and migrate it to drift directly.

- `floorScheme` (default)
    - the table name is the same as the class name.
    - overrides with `@Table(name: "NewName")` annotation, will be taken into account.
- `driftScheme`
    - the table name is snake_case version of the class name
    - check if this is correct.
- `driftSchemeWithOverride`
    - the same as driftScheme, but the table name can be overridden by the `@Table(name: "NewName")` annotation.

### Custom Configuration
You can also create a more custom configuration by using the `BuildRunner.custom` constructor.
Override the default option objects or implement them yourself.
Beware that some checks to guarantee that the configuration is valid are not done with the custom constructor.

## Contribute

## Todos

TODO Example User Import isn't added in converted project

### General
- call dart fix on all generated files?
  - remove unused imports etc.
- code documentation
- many features aren't tested
- code structure clean up
    - EntityGenerator
    - BaseEntityGenerator
    - BaseDaoGenerator
    - TypeConverterGenerator
- 2 classes aren't allowed to have the same name
  - the code internally uses a map of all generated classnames, if 2 classes have the same name they would override each other.
- add github ci for tests and protect main branch
- option to print warnings. ValueResponse can only be used for errors.
- add documentation for available build_options
- add the doc comments on fields methods classes from the old files to the generated new files.
- import rewriting doesn't work properly when only converting part of all files
  - to many imports are rewritten

### Floor2DriftGenerator

### (Base)Dao Generator
- WHERE IN doesn't work in custom update statement
- implement limit
- make an empty dao a warning not an error
- like with escape clause
- order by
- group by? (does floor support it?)
- add tests for fields with type converters
    - check why floor doesn't work with `IntListConverter` and empty lists
- @delete
    - maybe use customUpdate? 
    - delete List<Entity> always returns void
        - if the return type is int, then an empty List is returned.
- @insert
    - maybe use customInsert? 
    - insert List<Entity> always returns void
        - if the return type is int, then an empty List is returned.
- @update
    - maybe use customUpdate? 
    - it always returns void at the moment.
        - update single could easily be changed to return 1 if ok or 0 if not.
- custom update
  - doesn't work with List<int> as a parameter.
- custom insert
#### DaoGenerator 

##### BaseDaoGenerator
- aggregate functions (count, avg, etc.) don't work
  - Could work need to be cast for `avg` to work
  - final a = table.columnsByName[""]!.count();
- check: different Drift Dao Mixin name if a modular build is used

### (Base)EntityGenerator
- only autoIncrement primary keys supported @PrimaryKey(autogenerate: true)
- generate toColumns method when using @UseRowClass
- Primary keys must be autogenerated
- default value
    - default value on field not in constructor
- rename field names
  - probably the user must set `case_from_dart_to_sql : PascalCase/preserve` themselves
  - and add automatic migration from `@ColumnInfo(name: "NewName")` to `named(""")` in drift
- what to do with "real" implemented functions in entities, daos, etc.
  - copy them to the generated file?
#### EntityGenerator
- @Entity(tablename: "TableName") doesn't work
  - The dao Generator uses the tableName to get the entity Class Name
- tests
    - useRowClass test

#### BaseEntityGenerator

### TypeConverterGenerator