import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:floor_annotation/floor_annotation.dart';

import 'base_class.dart';

@convertBaseDao
// TODO create new Dao, to have separate Dao Tests and BaseDao Tests
abstract class BaseDao<T extends BaseClass<T>> {
  @Query('SELECT * FROM TaskTest')
  Future<List<T>> getAll();

  @Query("SELECT DifFeReNt_STRING FROM TASKTEST WHERE id = :id or DifFeReNt_STRING = :renamedString")
  Future<String?> renamedStringTestBaseDao(int id, String renamedString);

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
