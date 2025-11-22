import 'package:drift/drift.dart';

import 'enums.dart';
import 'floor_base_task_daoDrift.dart';
import 'floor_test_databaseDrift.dart';
import 'task.dart';
import 'taskDrift.dart';

part 'floor_task_daoDrift.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<FloorTestDatabase> with BaseDaoMixin<$TasksTable, Task>, _$TaskDaoMixin {
  TaskDao(super.db);

  Future<Task?> findTaskById(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).getSingle();
  }

  Future<int?> findTaskIdById(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).map((tasks) => tasks.id).getSingle();
  }

  Future<List<Task>> findAllTasks() {
    return (select(tasks)).get();
  }

  Stream<List<Task>> findAllTasksAsStream() {
    return (select(tasks)).watch();
  }

  Stream<int?> countTasks() {
    final $1 = countAll();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).watchSingleOrNull();
  }

  Stream<double?> avgTasks() {
    final $1 = tasks.id.avg();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).watchSingleOrNull();
  }

  Stream<int?> findUniqueMessagesCountAsStream() {
    final $1 = tasks.message.count(distinct: true);
    return (selectOnly(tasks, distinct: true)..addColumns([$1])).map((tasks) => tasks.read($1)!).watchSingleOrNull();
  }

  Stream<List<Task>> findAllTasksByStatusAsStream(TaskStatus status) {
    return (select(tasks)..where((tasks) => tasks.status.equalsExp(Variable(status.index)))).watch();
  }

  Future<Task?> whereId(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).getSingle();
  }

  Future<List<Task>> whereNotEqual(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)).not())).get();
  }

  Future<List<Task>> whereNotEqualDate(DateTime timestamp) {
    return (select(tasks)
      ..where((tasks) => tasks.timestamp.equalsExp(Variable(tasks.timestamp.converter.toSql(timestamp))).not())).get();
  }

  Future<List<Task>> whereSmallerBigger(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)).not())).get();
  }

  Future<List<Task>> whereSmallerBiggerDate(DateTime timestamp) {
    return (select(tasks)
      ..where((tasks) => tasks.timestamp.equalsExp(Variable(tasks.timestamp.converter.toSql(timestamp))).not())).get();
  }

  Future<List<Task>> whereAnd(int id, bool isRead) {
    return (select(tasks)
      ..where((tasks) => tasks.id.equalsExp(Variable(id)) & tasks.isRead.equalsExp(Variable(isRead)))).get();
  }

  Future<List<Task>> whereOr(int id, bool isRead) {
    return (select(tasks)
      ..where((tasks) => tasks.id.equalsExp(Variable(id)) | tasks.isRead.equalsExp(Variable(isRead)))).get();
  }

  Future<List<Task>> whereAndOr(int id, bool isRead, int status) {
    return (select(tasks)..where(
      (tasks) =>
          tasks.id.equalsExp(Variable(id)) |
          (tasks.isRead.equalsExp(Variable(isRead)) & tasks.status.equalsExp(Variable(status))),
    )).get();
  }

  Future<List<Task>> whereAndOr2(bool isRead, int status) {
    return (select(tasks)..where(
      (tasks) =>
          tasks.isRead.equalsExp(Variable(isRead)) & (tasks.type.isNull() | tasks.status.equalsExp(Variable(status))),
    )).get();
  }

  Future<List<Task>> whereBigger(int id) {
    return (select(tasks)..where((tasks) => tasks.id.isBiggerThan(Variable(id)))).get();
  }

  Future<List<Task>> whereBiggerEqual(int id) {
    return (select(tasks)..where((tasks) => tasks.id.isBiggerOrEqual(Variable(id)))).get();
  }

  Future<List<Task>> whereSmaller(int id) {
    return (select(tasks)..where((tasks) => tasks.id.isSmallerThan(Variable(id)))).get();
  }

  Future<List<Task>> whereSmallerEqual(int id) {
    return (select(tasks)..where((tasks) => tasks.id.isSmallerOrEqual(Variable(id)))).get();
  }

  Future<List<Task>> whereBiggerDate(DateTime timestamp) {
    return (select(tasks)
      ..where((tasks) => tasks.timestamp.isBiggerThan(Variable(tasks.timestamp.converter.toSql(timestamp))))).get();
  }

  Future<List<Task>> whereBiggerEqualDate(DateTime timestamp) {
    return (select(tasks)
      ..where((tasks) => tasks.timestamp.isBiggerOrEqual(Variable(tasks.timestamp.converter.toSql(timestamp))))).get();
  }

  Future<List<Task>> whereSmallerDate(DateTime timestamp) {
    return (select(tasks)
      ..where((tasks) => tasks.timestamp.isSmallerThan(Variable(tasks.timestamp.converter.toSql(timestamp))))).get();
  }

  Future<List<Task>> whereSmallerEqualDate(DateTime timestamp) {
    return (select(tasks)
      ..where((tasks) => tasks.timestamp.isSmallerOrEqual(Variable(tasks.timestamp.converter.toSql(timestamp))))).get();
  }

  Future<List<Task>> whereIn(List<int> ids) {
    return (select(tasks)..where((tasks) => tasks.id.isIn([...ids]))).get();
  }

  Future<List<Task>> whereInEnum(List<int> status) {
    return (select(tasks)..where((tasks) => tasks.status.isIn([...status]))).get();
  }

  Future<List<Task>> whereIn582() {
    return (select(tasks)..where((tasks) => tasks.id.isIn([5, 8, 2]))).get();
  }

  Future<List<Task>> whereNotIn(List<int> ids) {
    return (select(tasks)..where((tasks) => tasks.id.isNotIn([...ids]))).get();
  }

  Future<List<Task>> whereNotInEnum(List<int> status) {
    return (select(tasks)..where((tasks) => tasks.status.isNotIn([...status]))).get();
  }

  Future<List<Task>> whereNotIn791() {
    return (select(tasks)..where((tasks) => tasks.id.isNotIn([7, 9, 1]))).get();
  }

  Future<List<Task>> whereAndOrIn(int id, bool isRead, List<int> status) {
    return (select(tasks)..where(
      (tasks) =>
          tasks.id.equalsExp(Variable(id)) |
          (tasks.isRead.equalsExp(Variable(isRead)) & tasks.status.isIn([...status])),
    )).get();
  }

  Future<Task?> returnSingleFutureTask(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).getSingle();
  }

  Stream<Task?> returnSingleStreamTask(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).watchSingleOrNull();
  }

  Stream<List<Task?>> returnMultipleStreamTask(List<int> ids) {
    return (select(tasks)..where((tasks) => tasks.id.isIn([...ids]))).watch();
  }

  Future<List<Task?>> returnMultipleFutureTask(List<int> ids) {
    return (select(tasks)..where((tasks) => tasks.id.isIn([...ids]))).get();
  }

  Stream<TaskStatus?> selectAndReturnEnum(TaskStatus status) {
    return (select(tasks)..where(
      (tasks) => tasks.status.equalsExp(Variable(status.index)),
    )).map((tasks) => tasks.status).watchSingleOrNull();
  }

  Future<List<Task>> likeMessage(String likeClause) {
    return (select(tasks)..where((tasks) => tasks.message.likeExp(Variable(likeClause)))).get();
  }

  Future<Uint8List?> returnSingleUint8List(int id) {
    return (select(tasks)
      ..where((tasks) => tasks.id.equalsExp(Variable(id)))).map((tasks) => tasks.attachment).getSingle();
  }

  Future<List<Uint8List?>> returnMultipleUint8List(int id) {
    return (select(tasks)
      ..where((tasks) => tasks.id.isBiggerThan(Variable(id)))).map((tasks) => tasks.attachment).get();
  }

  Future<List<Task>> whereUint8List(Uint8List attachment) {
    return (select(tasks)..where((tasks) => tasks.attachment.equalsExp(Variable(attachment)))).get();
  }

  Future<double?> returnSingleDouble(int id) {
    return (select(tasks)
      ..where((tasks) => tasks.id.equalsExp(Variable(id)))).map((tasks) => tasks.customDouble).getSingle();
  }

  Future<List<double>> returnMultipleDouble(int id) {
    return (select(tasks)
      ..where((tasks) => tasks.id.isBiggerThan(Variable(id)))).map((tasks) => tasks.customDouble).get();
  }

  Future<List<Task>> whereDouble(double customDouble) {
    return (select(tasks)..where((tasks) => tasks.customDouble.equalsExp(Variable(customDouble)))).get();
  }

  Future<int?> returnSingleInt(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).map((tasks) => tasks.id).getSingle();
  }

  Future<List<int?>> returnMultipleInt(int id) {
    return (select(tasks)..where((tasks) => tasks.id.isBiggerThan(Variable(id)))).map((tasks) => tasks.id).get();
  }

  Future<List<Task>> whereInt(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).get();
  }

  Future<bool?> returnSingleBool(int id) {
    return (select(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).map((tasks) => tasks.isRead).getSingle();
  }

  Future<List<bool?>> returnMultipleBool(int id) {
    return (select(tasks)..where((tasks) => tasks.id.isBiggerThan(Variable(id)))).map((tasks) => tasks.isRead).get();
  }

  Future<List<Task>> whereBool(bool isRead) {
    return (select(tasks)..where((tasks) => tasks.isRead.equalsExp(Variable(isRead)))).get();
  }

  Future<String?> returnSingleString(int id) {
    return (select(tasks)
      ..where((tasks) => tasks.id.equalsExp(Variable(id)))).map((tasks) => tasks.message).getSingle();
  }

  Future<List<String>> returnMultipleString(int id) {
    return (select(tasks)..where((tasks) => tasks.id.isBiggerThan(Variable(id)))).map((tasks) => tasks.message).get();
  }

  Future<List<Task>> whereString(String message) {
    return (select(tasks)..where((tasks) => tasks.message.equalsExp(Variable(message)))).get();
  }

  Future<int?> count() {
    final $1 = tasks.id.count();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).getSingle();
  }

  Future<int?> countStar() {
    final $1 = countAll();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).getSingle();
  }

  Future<int?> countWhere(int id) {
    final $1 = countAll();
    return (selectOnly(tasks)
          ..addColumns([$1])
          ..where(tasks.id.isSmallerThan(Variable(id))))
        .map((tasks) => tasks.read($1)!)
        .getSingle();
  }

  Future<double?> avg() {
    final $1 = tasks.id.avg();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).getSingle();
  }

  Future<double?> avgWhere(int id) {
    final $1 = tasks.id.avg();
    return (selectOnly(tasks)
          ..addColumns([$1])
          ..where(tasks.id.isSmallerThan(Variable(id))))
        .map((tasks) => tasks.read($1)!)
        .getSingle();
  }

  Future<int?> min() {
    final $1 = tasks.id.min();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).getSingle();
  }

  Future<int?> minWhere(int id) {
    final $1 = tasks.id.min();
    return (selectOnly(tasks)
          ..addColumns([$1])
          ..where(tasks.id.isBiggerThan(Variable(id))))
        .map((tasks) => tasks.read($1)!)
        .getSingle();
  }

  Future<int?> max() {
    final $1 = tasks.id.max();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).getSingle();
  }

  Future<int?> maxWhere(int id) {
    final $1 = tasks.id.max();
    return (selectOnly(tasks)
          ..addColumns([$1])
          ..where(tasks.id.isSmallerThan(Variable(id))))
        .map((tasks) => tasks.read($1)!)
        .getSingle();
  }

  Future<int?> sum() {
    final $1 = tasks.id.sum();
    return (selectOnly(tasks)..addColumns([$1])).map((tasks) => tasks.read($1)!).getSingle();
  }

  Future<int?> sumWhere(int id) {
    final $1 = tasks.id.sum();
    return (selectOnly(tasks)
          ..addColumns([$1])
          ..where(tasks.id.isSmallerThan(Variable(id))))
        .map((tasks) => tasks.read($1)!)
        .getSingle();
  }

  Future<void> deleteWhereId(int id) {
    return (delete(tasks)..where((tasks) => tasks.id.equalsExp(Variable(id)))).go();
  }

  Future<void> deleteAll() {
    return (delete(tasks)).go();
  }

  Future<int?> updateMessage(int id, String message) {
    return (customUpdate(
      "UPDATE Task SET message = :message WHERE id = :id",
      variables: [Variable(message), Variable(id)],
      updates: {tasks},
      updateKind: UpdateKind.update,
    ));
  }

  Future<int?> updateMultipleMessages(List<int> ids, String message) {
    return (customUpdate(
      "UPDATE Task SET message = :message WHERE id IN (:ids)",
      variables: [Variable(message), Variable(ids)],
      updates: {tasks},
      updateKind: UpdateKind.update,
    ));
  }

  Future<int> annotationInsertTask(Task task) async {
    return await tasks.insertOne(task);
  }

  Future<List<int>> annotationInsertTasks(List<Task> taskList) async {
    await tasks.insertAll(taskList);
    return const [];
  }

  Future<int> annotationUpdateTask(Task task) async {
    await update(tasks).replace(task);
    return -1;
  }

  Future<int> annotationUpdateTasks(List<Task> task) async {
    await batch((batch) {
      batch.replaceAll(tasks, task);
    });
    return -1;
  }

  Future<int> annotationDeleteTask(Task task) async {
    return await delete(tasks).delete(task);
  }

  Future<int> annotationDeleteTasks(List<Task> taskList) async {
    await batch((batch) {
      for (final entry in taskList) {
        batch.delete(tasks, entry);
      }
    });
    return -1;
  }
}
