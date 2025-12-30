import 'package:floor_annotation/floor_annotation.dart';

import '../views/task_user_view.dart';

@dao
abstract class TaskUserViewDao {
  @Query("SELECT * FROM TaskUserView")
  Future<List<TaskUserView>> getAll();
}
