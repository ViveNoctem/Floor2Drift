import 'package:floor/floor.dart';

import 'base_class.dart';

abstract class ExampleBaseDao<T extends ExampleBaseClass> {
  @Query('SELECT * FROM ExampleTask')
  Future<List<T>> getAll();
}
