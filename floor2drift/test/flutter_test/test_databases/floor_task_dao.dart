import 'dart:typed_data';

import 'package:floor_annotation/floor_annotation.dart';

import '../additional_classes/annotation.dart';
import 'enums.dart';
import 'floor_base_task_dao.dart';
import 'task.dart';

@dao
abstract class TestTaskDao extends BaseDao<TestTask> {
  // @Query('SELECT * FROM Task')
  // Future<List<Task>> getAll();

  @TestAnnotation()
  @Query('SELECT * FROM TestTask WHERE id = :id LIMIT 1')
  Future<TestTask?> findTaskById(int id);

  @Query('SELECT id FROM TestTask WHERE id = :id')
  Future<int?> findTaskIdById(int id);

  @Query('SELECT * FROM TestTask')
  Future<List<TestTask>> findAllTasks();

  @Query('SELECT * FROM TestTask')
  Stream<List<TestTask>> findAllTasksAsStream();

  @Query('SELECT COUNT(*) FROM TestTask')
  Stream<int?> countTasks();

  @Query('SELECT AVG(id) FROM TestTask')
  Stream<double?> avgTasks();

  @Query('SELECT DISTINCT COUNT(DISTINCT message) FROM TestTask')
  Stream<int?> findUniqueMessagesCountAsStream();

  @Query('SELECT * FROM TestTask WHERE status = :status')
  Stream<List<TestTask>> findAllTasksByStatusAsStream(TaskStatus status);

  // @annotate.Query('UPDATE OR ABORT TestTask SET type = :type WHERE id = :id')
  // Future<int?> updateTypeById(TaskType type, int id);

  // region whereQueries

  @Query('SELECT * FROM TestTask WHERE id = :id')
  Future<TestTask?> whereId(int id);

  @Query('SELECT * FROM TestTask WHERE id != :id')
  Future<List<TestTask>> whereNotEqual(int id);

  @Query('SELECT * FROM TestTask WHERE timestamp != :timestamp')
  Future<List<TestTask>> whereNotEqualDate(DateTime timestamp);

  @Query('SELECT * FROM TestTask WHERE id <> :id')
  Future<List<TestTask>> whereSmallerBigger(int id);

  @Query('SELECT * FROM TestTask WHERE timestamp <> :timestamp')
  Future<List<TestTask>> whereSmallerBiggerDate(DateTime timestamp);

  @Query('SELECT * FROM TestTask WHERE id = :id AND isRead = :isRead')
  Future<List<TestTask>> whereAnd(int id, bool isRead);

  @Query('SELECT * FROM TestTask WHERE id = :id OR isRead = :isRead')
  Future<List<TestTask>> whereOr(int id, bool isRead);

  @Query('SELECT * FROM TestTask WHERE id = :id OR (isRead = :isRead AND status = :status)')
  Future<List<TestTask>> whereAndOr(int id, bool isRead, int status);

  @Query('SELECT * FROM TestTask WHERE isRead = :isRead AND (type IS NULL OR status = :status)')
  Future<List<TestTask>> whereAndOr2(bool isRead, int status);

  // endregion

  // region whereBiggerSmaller

  @Query('SELECT * FROM TestTask WHERE id > :id')
  Future<List<TestTask>> whereBigger(int id);

  @Query('SELECT * FROM TestTask WHERE id >= :id')
  Future<List<TestTask>> whereBiggerEqual(int id);

  @Query('SELECT * FROM TestTask WHERE id < :id')
  Future<List<TestTask>> whereSmaller(int id);

  @Query('SELECT * FROM TestTask WHERE id <= :id')
  Future<List<TestTask>> whereSmallerEqual(int id);

  @Query('SELECT * FROM TestTask WHERE timestamp > :timestamp')
  Future<List<TestTask>> whereBiggerDate(DateTime timestamp);

  @Query('SELECT * FROM TestTask WHERE timestamp >= :timestamp')
  Future<List<TestTask>> whereBiggerEqualDate(DateTime timestamp);

  @Query('SELECT * FROM TestTask WHERE timestamp < :timestamp')
  Future<List<TestTask>> whereSmallerDate(DateTime timestamp);

  @Query('SELECT * FROM TestTask WHERE timestamp <= :timestamp')
  Future<List<TestTask>> whereSmallerEqualDate(DateTime timestamp);

  // endregion

  // region WHERE IN
  @Query('SELECT * FROM TestTask WHERE id IN (:ids)')
  Future<List<TestTask>> whereIn(List<int> ids);

  @Query('SELECT * FROM TestTask WHERE status IN (:status)')
  Future<List<TestTask>> whereInEnum(List<int> status);

  @Query('SELECT * FROM TestTask WHERE id IN (5, 8, 2)')
  Future<List<TestTask>> whereIn582();

  @Query('SELECT * FROM TestTask WHERE id NOT IN (:ids)')
  Future<List<TestTask>> whereNotIn(List<int> ids);

  @Query('SELECT * FROM TestTask WHERE status NOT IN (:status)')
  Future<List<TestTask>> whereNotInEnum(List<int> status);

  @Query('SELECT * FROM TestTask WHERE id NOT IN (7,9,1)')
  Future<List<TestTask>> whereNotIn791();

  @Query('SELECT * FROM TestTask WHERE id = :id OR (isRead = :isRead AND status IN (:status))')
  Future<List<TestTask>> whereAndOrIn(int id, bool isRead, List<int> status);

  // endregion

  // region testing return values remove?
  // just many methods to test generation of different return types
  // if the floor2drift.g.dart has no errors everything is fine
  @Query('SELECT * FROM TestTask WHERE id = :id')
  Future<TestTask?> returnSingleFutureTask(int id);

  @Query('SELECT * FROM TestTask WHERE id = :id')
  Stream<TestTask?> returnSingleStreamTask(int id);

  @Query('SELECT * FROM TestTask WHERE id IN (:ids)')
  Stream<List<TestTask?>> returnMultipleStreamTask(List<int> ids);

  @Query('SELECT * FROM TestTask WHERE id IN (:ids)')
  Future<List<TestTask?>> returnMultipleFutureTask(List<int> ids);

  @Query('SELECT status FROM TestTask WHERE status = :status')
  Stream<TaskStatus?> selectAndReturnEnum(TaskStatus status);

  // endregion

  // region LIKE

  @Query('SELECT * FROM TestTask WHERE message LIKE :likeClause')
  Future<List<TestTask>> likeMessage(String likeClause);

  // endregion

  // region typeTests
  // region Uint8List
  @Query('SELECT attachment FROM TestTask WHERE id = :id')
  Future<Uint8List?> returnSingleUint8List(int id);

  @Query('SELECT attachment FROM TestTask WHERE id > :id')
  Future<List<Uint8List?>> returnMultipleUint8List(int id);

  @Query('SELECT * FROM TestTask WHERE attachment = :attachment')
  Future<List<TestTask>> whereUint8List(Uint8List attachment);

  // endregion

  // region double
  @Query('SELECT cUsToMdOuBlE FROM TestTask WHERE id = :id')
  Future<double?> returnSingleDouble(int id);

  @Query('SELECT cUsToMdOuBlE FROM TestTask WHERE id > :id')
  Future<List<double>> returnMultipleDouble(int id);

  @Query('SELECT * FROM TestTask WHERE cUsToMdOuBlE = :customDouble')
  Future<List<TestTask>> whereDouble(double customDouble);

  // endregion

  // region int
  @Query('SELECT id FROM TestTask WHERE id = :id')
  Future<int?> returnSingleInt(int id);

  @Query('SELECT id FROM TestTask WHERE id > :id')
  Future<List<int?>> returnMultipleInt(int id);

  @Query('SELECT * FROM TestTask WHERE id = :id')
  Future<List<TestTask>> whereInt(int id);

  // endregion

  // region bool
  @Query('SELECT isRead FROM TestTask WHERE id = :id')
  Future<bool?> returnSingleBool(int id);

  @Query('SELECT isRead FROM TestTask WHERE id > :id')
  Future<List<bool?>> returnMultipleBool(int id);

  @Query('SELECT * FROM TestTask WHERE isRead = :isRead')
  Future<List<TestTask>> whereBool(bool isRead);

  // endregion

  // region string
  @Query('SELECT message FROM TestTask WHERE id = :id')
  Future<String?> returnSingleString(int id);

  @Query('SELECT message FROM TestTask WHERE id > :id')
  Future<List<String>> returnMultipleString(int id);

  @Query('SELECT * FROM TestTask WHERE message = :message')
  Future<List<TestTask>> whereString(String message);

  // endregion

  // endregion

  // region aggregate functions

  @Query("SELECT COUNT(id) FROM TestTask")
  Future<int?> count();

  @Query("SELECT COUNT(*) FROM TestTask")
  Future<int?> countStar();

  @Query("SELECT COUNT(*) FROM TestTask WHERE id < :id")
  Future<int?> countWhere(int id);

  @Query("SELECT AVG(id) FROM TestTask")
  Future<double?> avg();

  @Query("SELECT AVG(id) FROM TestTask WHERE id < :id")
  Future<double?> avgWhere(int id);

  @Query("SELECT MIN(id) FROM TestTask")
  Future<int?> min();

  @Query("SELECT MIN(id) FROM TestTask WHERE id > :id")
  Future<int?> minWhere(int id);

  @Query("SELECT MAX(id) FROM TestTask")
  Future<int?> max();

  @Query("SELECT MAX(id) FROM TestTask WHERE id < :id")
  Future<int?> maxWhere(int id);

  @Query("SELECT SUM(id) FROM TestTask")
  Future<int?> sum();

  @Query("SELECT SUM(id) FROM TestTask WHERE id < :id")
  Future<int?> sumWhere(int id);

  @Query("SELECT TOTAL(id) FROM TestTask")
  Future<double?> total();

  @Query("SELECT TOTAL(id) FROM TestTask WHERE id < :id")
  Future<double?> totalWhere(int id);

  // TODO Filter not supported
  // @Query("SELECT TOTAL(id) FILTER (WHERE id < :id) FROM TestTask")
  // Future<double?> totalFilter(int id);

  //endregion

  // region custom delete

  @Query("DELETE FROM TestTask WHERE id = :id")
  Future<void> deleteWhereId(int id);

  @Query("DELETE FROM TestTask")
  Future<void> deleteAll();

  // endregion

  // region custom update

  @Query("UPDATE TestTask SET message = :message WHERE id = :id")
  Future<int?> updateMessage(int id, String message);

  @Query("UPDATE TestTask SET message = :message WHERE id IN (:ids)")
  Future<int?> updateMultipleMessages(List<int> ids, String message);

  // endregion

  // region BETWEEN
  @Query("SELECT * FROM TestTask WHERE id BETWEEN :fromId  AND :toId")
  Future<List<TestTask>> betweenId(int fromId, int toId);

  @Query("SELECT * FROM TestTask WHERE message NOT BETWEEN :fromMessage  AND :toMessage")
  Future<List<TestTask>> betweenNotMessage(String fromMessage, String toMessage);

  // Floor doesn't support converted enum in query argumen
  // Is still needed to check that the converter works correctly with converted enum
  @Query("SELECT * FROM TestTask WHERE type NOT BETWEEN :fromType  AND :toType")
  Future<List<TestTask>> betweenNotTaskType(TaskType fromType, TaskType toType);
  // endregion

  // region insert update delete

  @Insert()
  Future<int> annotationInsertTask(TestTask task);

  @Insert()
  Future<int> annotationInsertUser(TestUser user);

  @insert
  Future<List<int>> annotationInsertTasks(List<TestTask> taskList);

  @update
  Future<int> annotationUpdateTask(TestTask task);

  @Update()
  Future<int> annotationUpdateTasks(List<TestTask> task);

  @delete
  Future<int> annotationDeleteTask(TestTask task);

  @delete
  Future<int> annotationDeleteTasks(List<TestTask> taskList);

  // endregion

  // region renamed test

  @Query("SELECT DifFeReNt_STRING FROM testTask WHERE id = :id or DifFeReNt_STRING = :renamedString")
  Future<String?> renamedStringTest(int id, String renamedString);

  // endregion

  // region orderBy

  @Query("SELECT * FROM testTask ORDER BY id")
  Future<List<TestTask>> orderById();

  @Query("SELECT * FROM testTask ORDER BY id ASC")
  Future<List<TestTask>> orderByIdAsc();

  @Query("SELECT * FROM testTask ORDER BY id DESC")
  Future<List<TestTask>> orderByIdDesc();

  @Query("SELECT * FROM testTask ORDER BY type DESC NULLS LAST")
  Future<List<TestTask>> orderByTypeDescNullsLast();

  @Query("SELECT * FROM testTask ORDER BY type DESC NULLS FIRST")
  Future<List<TestTask>> orderByTypeDescNullsFirst();

  @Query("SELECT * FROM testTask ORDER BY message Asc, id")
  Future<List<TestTask>> orderByMessageAscId();

  @Query("SELECT * FROM testTask ORDER BY message DESC, id DESC")
  Future<List<TestTask>> orderByMessageDescIdAsc();

  @Query("SELECT * FROM testTask WHERE id < :argument ORDER BY id DESC")
  Future<List<TestTask>> getOrderByWhere(int argument);
  // endregion
}
