import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:floor_annotation/floor_annotation.dart';

import 'base_class.dart';

@convertBaseDao
// TODO create new Dao, to have separate Dao Tests and BaseDao Tests
abstract class BaseDao<T extends BaseClass<T>> {
  @Query('SELECT * FROM task')
  Future<List<T>> getAll();

  // @insert
  // Future<List<int>> baseTaskInsertList(List<T> list);
  //
  // @Insert(onConflict: OnConflictStrategy.rollback)
  // Future<int> baseTaskInsertOne(T one);
  //
  // @delete
  // Future<int> baseTaskDeleteList(List<T> list);
  //
  // @delete
  // Future<int> baseTaskDeleteOne(T one);
  //
  // @Update(onConflict: OnConflictStrategy.ignore)
  // Future<int> baseTaskUpdateList(List<T> list);
  //
  // @update
  // Future<int> baseTaskUpdateOne(T one);
}
