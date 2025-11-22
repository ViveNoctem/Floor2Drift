import 'package:floor/floor.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';

import 'base_class.dart';

@convertBaseDao
abstract class ExampleBaseDao<T extends ExampleBaseClass<T>> {
  @Query('SELECT * FROM ExampleTask')
  Future<List<T>> getAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> tempMany(List<T> temp);

  @Query("UPDATE ExampleTask SET id = :userId WHERE id = :userId2")
  Future<int?> updateTaskBase(int userId, int userId2);
}
