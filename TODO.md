## General
### features
- convert DatabaseViews
- support drift [modular code generation](https://drift.simonbinder.eu/generation_options/modular/)
    - changes need in generated Files
        - replace `_$` with just `$` to extend drift classes
        - replace part statement mit import .drift.dart instead par .g.dart
- call dart fix on all generated files to remove unnecessary imports etc.
- add GitHub ci for tests

### Bugs
- 2 classes aren't allowed to have the same name
- import rewriting doesn't work properly when only converting part of all files
  - should be fixed everywhere except (base-)entity classes. To fix it there the generator should create all classStates before converting the imports of (base-)entities
- useRowClass = false will probably generate wrong code. Especially for BaseEntities

### Structural
- maybe merge or cleanUp dbState and tableSelector
- how to convert floor transactions
  - in dao it could be converted to drift entities. All other transaction maybe with transaction_generator using the annotation?

## Dao
### Features
- implement limit
- like with escape clause
- group by? (does floor support it?)
- custom insert

### Bugs
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
- WHERE IN doesn't work in custom update statement
- BaseDao aggregate functions (count, avg, etc.) don't work
    - Could work need to be cast for `avg` to work
    - final a = table.columnsByName[""]!.count();

## Entity
### Features
- generate toColumns method when using @UseRowClass
- default value in field declaration?
- support for using string for enums instead of index?