import 'package:floor/floor.dart';

import 'base_dao.dart';
import 'task.dart';

@dao
abstract class ExampleTaskDao extends ExampleBaseDao<ExampleTask> {
  @Query('SELECT * FROM ExampleTask WHERE id = :id LIMIT 1')
  Future<ExampleTask?> findTaskById(int id);

  @Query('SELECT * FROM ExampleTask WHERE userId = :userId')
  Future<List<ExampleTask>> getAllForUser(int userId);

  @insert
  Future<void> add(ExampleTask task);

  @update
  Future<void> updateTask(ExampleTask task);
}
