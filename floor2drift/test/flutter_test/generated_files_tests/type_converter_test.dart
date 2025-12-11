import 'package:test/test.dart';

import '../test_databases/support_classes/enums.dart';
import '../test_databases/type_converters/type_converters.dart' as floor;
import '../test_databases/type_converters/type_convertersDrift.dart' as drift;

void main() {
  setUp(() {});

  group("nullable type converter", () {
    test("decode null", () {
      final floorConverter = floor.TaskTypeConverter();
      final driftConverter = drift.TaskTypeConverter();

      expect(floorConverter.decode(null), equals(driftConverter.fromSql(null)));
    });

    test("decode non null", () {
      final floorConverter = floor.TaskTypeConverter();
      final driftConverter = drift.TaskTypeConverter();

      expect(floorConverter.decode("bug"), equals(driftConverter.fromSql("bug")));
    });

    test("encode null", () {
      final floorConverter = floor.TaskTypeConverter();
      final driftConverter = drift.TaskTypeConverter();

      expect(floorConverter.encode(null), equals(driftConverter.toSql(null)));
    });

    test("encode non null", () {
      final floorConverter = floor.TaskTypeConverter();
      final driftConverter = drift.TaskTypeConverter();

      expect(floorConverter.encode(TaskType.story), equals(driftConverter.toSql(TaskType.story)));
    });
  });

  group("non nullable type converter", () {
    test("decode", () {
      final floorConverter = floor.DateTimeConverter();
      final driftConverter = drift.DateTimeConverter();
      final dateTime = "1969-07-20T20:18:04.000Z";

      expect(floorConverter.decode(dateTime), equals(driftConverter.fromSql(dateTime)));
    });

    test("encode", () {
      final floorConverter = floor.DateTimeConverter();
      final driftConverter = drift.DateTimeConverter();
      final dateTime = DateTime.now();

      expect(floorConverter.encode(dateTime), equals(driftConverter.toSql(dateTime)));
    });
  });
}
