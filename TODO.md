## Todos

### General
- modular code generation not supported
    - changes need in generated Files
        - replace _$ with just $ to extend drift classes
        - replace part statement mit import .drift.dart instead par .g.dart
- call dart fix on all generated files?
    - remove unused imports etc.
- add more tests to test all features
- code structure clean up
    - EntityGenerator
    - BaseEntityGenerator
    - BaseDaoGenerator
    - TypeConverterGenerator
- 2 classes aren't allowed to have the same name
- add github ci for tests
- option to print warnings. ValueResponse can only be used for errors.
- add documentation for available build_options
- add the doc comments on fields methods classes from the old files to the generated new files.
- import rewriting doesn't work properly when only converting part of all files
    - to many imports are rewritten
    - needs to check if the class is actually used in the db or actually being converted
- maybe merge or cleanUp dbState and tableSelector

### Floor2DriftGenerator

### (Base)Dao Generator
- WHERE IN doesn't work in custom update statement
- implement limit
- like with escape clause
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
- add tests for renaming in expression_converter_test
#### DaoGenerator

##### BaseDaoGenerator
- aggregate functions (count, avg, etc.) don't work
    - Could work need to be cast for `avg` to work
    - final a = table.columnsByName[""]!.count();

### (Base)EntityGenerator
- generate toColumns method when using @UseRowClass
- default value
    - default value on field not in constructor
- what to do with "real" implemented functions in entities, daos, etc.
    - copy them to the generated file?
#### EntityGenerator

#### BaseEntityGenerator

### TypeConverterGenerator