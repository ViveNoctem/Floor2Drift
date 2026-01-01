import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:floor_annotation/floor_annotation.dart';
import 'package:flutter/cupertino.dart';

import '../entities/base_class.dart';
import '../support_classes/interfaces.dart';

@convertBaseDao
// TODO create new Dao, to have separate Dao Tests and BaseDao Tests
abstract class BaseDao<T extends BaseClass<T>> implements InterfaceOne<T>, InterfaceTwo {
  /// doc comment implemented method in dao
  @visibleForTesting
  Future<List<T>> implementedGetAll() async {
    // test comment describing the content
    final result = await getAll();
    return result;
  }

  @transaction
  Future<List<T>> transactionGetEveryOther() async {
    final result = await getAll();

    final list = <T>[];

    var skip = true;

    for (final item in result) {
      skip = !skip;
      if (skip) {
        continue;
      } else {
        list.add(item);
      }
    }

    return list;
  }

  @Query('SELECT * FROM TaskTest')
  Future<List<T>> getAll();

  @Query("SELECT DifFeReNt_STRING FROM TASKTEST WHERE id = :id or DifFeReNt_STRING = :renamedString")
  Future<String?> renamedStringTestBaseDao(int id, String renamedString);

  // region aggregate functions
  @Query("SELECT COUNT(id) FROM TaskTest")
  Future<int?> countBaseEntity();

  @Query("SELECT COUNT(*) FROM TaskTest")
  Future<int?> countStarBaseEntity();

  @Query("SELECT COUNT(*) FROM TaskTest WHERE id < :id")
  Future<int?> countWhereBaseEntity(int id);

  @Query("SELECT AVG(id) FROM TaskTest")
  Future<double?> avgBaseEntity();

  @Query("SELECT AVG(id) FROM TaskTest WHERE id < :id")
  Future<double?> avgWhereBaseEntity(int id);

  @Query("SELECT MIN(id) FROM TaskTest")
  Future<int?> minBaseEntity();

  @Query("SELECT MIN(id) FROM TaskTest WHERE id > :id")
  Future<int?> minWhereBaseEntity(int id);

  @Query("SELECT MAX(id) FROM TaskTest")
  Future<int?> maxBaseEntity();

  @Query("SELECT MAX(id) FROM TaskTest WHERE id < :id")
  Future<int?> maxWhereBaseEntity(int id);

  @Query("SELECT SUM(id) FROM TaskTest")
  Future<int?> sumBaseEntity();

  @Query("SELECT SUM(id) FROM TaskTest WHERE id < :id")
  Future<int?> sumWhereBaseEntity(int id);

  @Query("SELECT TOTAL(id) FROM TaskTest")
  Future<double?> totalBaseEntity();

  @Query("SELECT TOTAL(id) FROM TaskTest WHERE id < :id")
  Future<double?> totalWhereBaseEntity(int id);

  // endregion

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
