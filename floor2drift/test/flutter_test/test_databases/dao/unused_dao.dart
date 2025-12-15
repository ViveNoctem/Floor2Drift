import 'package:floor/floor.dart';

import '../support_classes/enums.dart';

@dao
abstract class UnusedDao {
  @Query("SELECT type FROM entityENTITY WHERE type = :argument")
  Future<List<TaskType>> columnCasingWrong(TaskType argument);
}
