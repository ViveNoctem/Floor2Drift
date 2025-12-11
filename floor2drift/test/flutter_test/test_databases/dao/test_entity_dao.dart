import 'package:floor/floor.dart';

import '../support_classes/enums.dart';

@dao
abstract class TestEntityDao {
  @Query("SELECT type FROM entityENTITY WHERE type = :argument")
  Future<List<TaskType>> columnCasingWrong(TaskType argument);

  // TODO TypeConverter between 2 native sql type doesn't see to work in drift
  // @Query("SELECT stringConverted FROM entityEntity WHERE stringConverted = :message")
  // Future<List<Uint8List>> getBase64String(String message);
}
