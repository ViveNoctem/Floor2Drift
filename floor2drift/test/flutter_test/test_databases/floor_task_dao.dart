import 'dart:typed_data';

import 'package:floor_annotation/floor_annotation.dart';

import '../additional_classes/annotation.dart';
import 'enums.dart';
import 'floor_base_task_dao.dart';
import 'task.dart';

@dao
abstract class TaskDao extends BaseDao<Task> {
  // @Query('SELECT * FROM Task')
  // Future<List<Task>> getAll();

  @TestAnnotation()
  @Query('SELECT * FROM Task WHERE id = :id LIMIT 1')
  Future<Task?> findTaskById(int id);

  @Query('SELECT id FROM Task WHERE id = :id')
  Future<int?> findTaskIdById(int id);

  @Query('SELECT * FROM Task')
  Future<List<Task>> findAllTasks();

  @Query('SELECT * FROM Task')
  Stream<List<Task>> findAllTasksAsStream();

  @Query('SELECT COUNT(*) FROM Task')
  Stream<int?> countTasks();

  @Query('SELECT AVG(id) FROM Task')
  Stream<double?> avgTasks();

  @Query('SELECT DISTINCT COUNT(DISTINCT message) FROM Task')
  Stream<int?> findUniqueMessagesCountAsStream();

  @Query('SELECT * FROM Task WHERE status = :status')
  Stream<List<Task>> findAllTasksByStatusAsStream(TaskStatus status);

  // @annotate.Query('UPDATE OR ABORT Task SET type = :type WHERE id = :id')
  // Future<int?> updateTypeById(TaskType type, int id);

  // region whereQueries

  @Query('SELECT * FROM Task WHERE id = :id')
  Future<Task?> whereId(int id);

  @Query('SELECT * FROM Task WHERE id != :id')
  Future<List<Task>> whereNotEqual(int id);

  @Query('SELECT * FROM Task WHERE timestamp != :timestamp')
  Future<List<Task>> whereNotEqualDate(DateTime timestamp);

  @Query('SELECT * FROM Task WHERE id <> :id')
  Future<List<Task>> whereSmallerBigger(int id);

  @Query('SELECT * FROM Task WHERE timestamp <> :timestamp')
  Future<List<Task>> whereSmallerBiggerDate(DateTime timestamp);

  @Query('SELECT * FROM Task WHERE id = :id AND isRead = :isRead')
  Future<List<Task>> whereAnd(int id, bool isRead);

  @Query('SELECT * FROM Task WHERE id = :id OR isRead = :isRead')
  Future<List<Task>> whereOr(int id, bool isRead);

  @Query('SELECT * FROM Task WHERE id = :id OR (isRead = :isRead AND status = :status)')
  Future<List<Task>> whereAndOr(int id, bool isRead, int status);

  @Query('SELECT * FROM Task WHERE isRead = :isRead AND (type IS NULL OR status = :status)')
  Future<List<Task>> whereAndOr2(bool isRead, int status);

  // endregion

  // region whereBiggerSmaller

  @Query('SELECT * FROM Task WHERE id > :id')
  Future<List<Task>> whereBigger(int id);

  @Query('SELECT * FROM Task WHERE id >= :id')
  Future<List<Task>> whereBiggerEqual(int id);

  @Query('SELECT * FROM Task WHERE id < :id')
  Future<List<Task>> whereSmaller(int id);

  @Query('SELECT * FROM Task WHERE id <= :id')
  Future<List<Task>> whereSmallerEqual(int id);

  @Query('SELECT * FROM Task WHERE timestamp > :timestamp')
  Future<List<Task>> whereBiggerDate(DateTime timestamp);

  @Query('SELECT * FROM Task WHERE timestamp >= :timestamp')
  Future<List<Task>> whereBiggerEqualDate(DateTime timestamp);

  @Query('SELECT * FROM Task WHERE timestamp < :timestamp')
  Future<List<Task>> whereSmallerDate(DateTime timestamp);

  @Query('SELECT * FROM Task WHERE timestamp <= :timestamp')
  Future<List<Task>> whereSmallerEqualDate(DateTime timestamp);

  // endregion

  // region WHERE IN
  @Query('SELECT * FROM Task WHERE id IN (:ids)')
  Future<List<Task>> whereIn(List<int> ids);

  @Query('SELECT * FROM Task WHERE status IN (:status)')
  Future<List<Task>> whereInEnum(List<int> status);

  @Query('SELECT * FROM Task WHERE id IN (5, 8, 2)')
  Future<List<Task>> whereIn582();

  @Query('SELECT * FROM Task WHERE id NOT IN (:ids)')
  Future<List<Task>> whereNotIn(List<int> ids);

  @Query('SELECT * FROM Task WHERE status NOT IN (:status)')
  Future<List<Task>> whereNotInEnum(List<int> status);

  @Query('SELECT * FROM Task WHERE id NOT IN (7,9,1)')
  Future<List<Task>> whereNotIn791();

  @Query('SELECT * FROM Task WHERE id = :id OR (isRead = :isRead AND status IN (:status))')
  Future<List<Task>> whereAndOrIn(int id, bool isRead, List<int> status);

  // endregion

  // region testing return values remove?
  // just many methods to test generation of different return types
  // if the floor2drift.g.dart has no errors everything is fine
  @Query('SELECT * FROM Task WHERE id = :id')
  Future<Task?> returnSingleFutureTask(int id);

  @Query('SELECT * FROM Task WHERE id = :id')
  Stream<Task?> returnSingleStreamTask(int id);

  @Query('SELECT * FROM Task WHERE id IN (:ids)')
  Stream<List<Task?>> returnMultipleStreamTask(List<int> ids);

  @Query('SELECT * FROM Task WHERE id IN (:ids)')
  Future<List<Task?>> returnMultipleFutureTask(List<int> ids);

  @Query('SELECT status FROM Task WHERE status = :status')
  Stream<TaskStatus?> selectAndReturnEnum(TaskStatus status);

  // endregion

  // region LIKE

  @Query('SELECT * FROM Task WHERE message LIKE :likeClause')
  Future<List<Task>> likeMessage(String likeClause);

  // endregion

  // region typeTests
  // region Uint8List
  @Query('SELECT attachment FROM Task WHERE id = :id')
  Future<Uint8List?> returnSingleUint8List(int id);

  @Query('SELECT attachment FROM Task WHERE id > :id')
  Future<List<Uint8List?>> returnMultipleUint8List(int id);

  @Query('SELECT * FROM Task WHERE attachment = :attachment')
  Future<List<Task>> whereUint8List(Uint8List attachment);

  // endregion

  // region double
  @Query('SELECT customDouble FROM Task WHERE id = :id')
  Future<double?> returnSingleDouble(int id);

  @Query('SELECT customDouble FROM Task WHERE id > :id')
  Future<List<double>> returnMultipleDouble(int id);

  @Query('SELECT * FROM Task WHERE customDouble = :customDouble')
  Future<List<Task>> whereDouble(double customDouble);

  // endregion

  // region int
  @Query('SELECT id FROM Task WHERE id = :id')
  Future<int?> returnSingleInt(int id);

  @Query('SELECT id FROM Task WHERE id > :id')
  Future<List<int?>> returnMultipleInt(int id);

  @Query('SELECT * FROM Task WHERE id = :id')
  Future<List<Task>> whereInt(int id);

  // endregion

  // region bool
  @Query('SELECT isRead FROM Task WHERE id = :id')
  Future<bool?> returnSingleBool(int id);

  @Query('SELECT isRead FROM Task WHERE id > :id')
  Future<List<bool?>> returnMultipleBool(int id);

  @Query('SELECT * FROM Task WHERE isRead = :isRead')
  Future<List<Task>> whereBool(bool isRead);

  // endregion

  // region string
  @Query('SELECT message FROM Task WHERE id = :id')
  Future<String?> returnSingleString(int id);

  @Query('SELECT message FROM Task WHERE id > :id')
  Future<List<String>> returnMultipleString(int id);

  @Query('SELECT * FROM Task WHERE message = :message')
  Future<List<Task>> whereString(String message);

  // endregion

  // endregion

  // region aggregate functions

  @Query("SELECT COUNT(id) FROM Task")
  Future<int?> count();

  @Query("SELECT COUNT(*) FROM Task")
  Future<int?> countStar();

  @Query("SELECT COUNT(*) FROM Task WHERE id < :id")
  Future<int?> countWhere(int id);

  @Query("SELECT AVG(id) FROM Task")
  Future<double?> avg();

  @Query("SELECT AVG(id) FROM Task WHERE id < :id")
  Future<double?> avgWhere(int id);

  @Query("SELECT MIN(id) FROM Task")
  Future<int?> min();

  @Query("SELECT MIN(id) FROM Task WHERE id > :id")
  Future<int?> minWhere(int id);

  @Query("SELECT MAX(id) FROM Task")
  Future<int?> max();

  @Query("SELECT MAX(id) FROM Task WHERE id < :id")
  Future<int?> maxWhere(int id);

  @Query("SELECT SUM(id) FROM Task")
  Future<int?> sum();

  @Query("SELECT SUM(id) FROM Task WHERE id < :id")
  Future<int?> sumWhere(int id);

  @Query("SELECT TOTAL(id) FROM Task")
  Future<double?> total();

  @Query("SELECT TOTAL(id) FROM Task WHERE id < :id")
  Future<double?> totalWhere(int id);

  // TODO Filter not supported
  // @Query("SELECT TOTAL(id) FILTER (WHERE id < :id) FROM Task")
  // Future<double?> totalFilter(int id);

  //endregion

  // region custom delete

  @Query("DELETE FROM Task WHERE id = :id")
  Future<void> deleteWhereId(int id);

  @Query("DELETE FROM Task")
  Future<void> deleteAll();

  // endregion

  // region custom update

  @Query("UPDATE Task SET message = :message WHERE id = :id")
  Future<int?> updateMessage(int id, String message);

  @Query("UPDATE Task SET message = :message WHERE id IN (:ids)")
  Future<int?> updateMultipleMessages(List<int> ids, String message);

  // endregion

  // region BETWEEN
  @Query("SELECT * FROM TASK WHERE id BETWEEN :fromId  AND :toId")
  Future<List<Task>> betweenId(int fromId, int toId);

  @Query("SELECT * FROM TASK WHERE message NOT BETWEEN :fromMessage  AND :toMessage")
  Future<List<Task>> betweenNotMessage(String fromMessage, String toMessage);

  // Floor doesn't support converted enum in query argumen
  // Is still needed to check that the converter works correctly with converted enum
  @Query("SELECT * FROM TASK WHERE type NOT BETWEEN :fromType  AND :toType")
  Future<List<Task>> betweenNotTaskType(TaskType fromType, TaskType toType);
  // endregion

  // region insert update delete

  @Insert()
  Future<int> annotationInsertTask(Task task);

  @insert
  Future<List<int>> annotationInsertTasks(List<Task> taskList);

  @update
  Future<int> annotationUpdateTask(Task task);

  @Update()
  Future<int> annotationUpdateTasks(List<Task> task);

  @delete
  Future<int> annotationDeleteTask(Task task);

  @delete
  Future<int> annotationDeleteTasks(List<Task> taskList);

  // endregion
}
