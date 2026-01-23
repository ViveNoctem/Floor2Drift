## General
### features
- convert DatabaseViews
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
- like with escape clause
- group by? (does floor support it?)
- custom insert

### Bugs
- @delete
    - maybe use customUpdate?
    - delete List<Entitiy>
    - doesn't use a batch but a transaction over all entities
    - delete every entity one after another instead of a batch delete
    - what is the performance impact?
- @insert
    - maybe use customInsert?
    - insert List<Entity>
      - doesn't use a batch but a transaction over all entities
      - insert every entity on after another instead of all at once
      - what is the performance impact?
- @update
    - maybe use customUpdate?
    - it always returns void at the moment.
        - update single could easily be changed to return 1 if ok or 0 if not.
- custom update
    - doesn't work with List<int> as a parameter.
- WHERE IN doesn't work in custom update statement

## Entity
### Features
- default value in field declaration?
- support for using string for enums instead of index?