import 'package:floor2drift_annotation/floor2drift_annotation.dart';

import '../support_classes/enums.dart';
import 'test_base_entity_one.dart';

@convertBaseEntity
abstract class TestBaseEntityTwo extends TestBaseEntityOne {
  final TaskType type;

  const TestBaseEntityTwo({this.type = TaskType.story});
}
