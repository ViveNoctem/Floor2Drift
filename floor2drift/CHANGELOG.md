## 0.1.8
- entity wasn't imported if the dao only had methods inherited from a base dao
- files written use the current platforms line terminator instead of always '\n'
- fixed problem where git indicated files changed even if the content was the same.
- hide material/cupertino table import in (base-)entity classes to fix  name collision of `Table` class
- fixed imports when only converting part of a database (except in (base-)entity classes)
- copy all from dao/type converter generator ignored methods to the result
- first found type converter was being ignored
- added support for drift modular code generation
- databasewide type converter didn't work
- couldn't differentiate between type converters with nullable and non-nullable return type
- added support for aggregate functions in base entity
- @update and @delete list functions now return the same result as floor
- toColumns helper methods are generated in (base-)entity classes if useRowClass is set
- doc comment from the entity wasn't copied to the table class
- @transaction methods in dao classes will be converted to drift transactions
- interfaces from floor dao are added to the drift dao

## 0.1.7
- rolled back dart sdk dependency to ^3.6.0
- changed analyzer dependency back to '>=5.13.0 <7.0.0'

## 0.1.6
- changed dart sdk dependency to '>=3.6.0 <3.9.0'

## 0.1.5
- changed analyzer dependency to ^6.11.0

## 0.1.4
- added flutter as dev dependency
- change sqflite to dev dependency

## 0.1.3
- added simple example for pub.dev
- removed flutter dependency the script is dart only
- changed analyzer dependency to ^6.6.0

## 0.1.2
- changed dart_style version from ^2.3.7 to ^2.2.4

## 0.1.1
- changed dart_style version from ^2.3.8 to ^2.3.7

## 0.1.0
- Initial version.