import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import '../additional_classes/test_helper.dart';
import '../test_databases/database/floor_test_database.dart' as floor;
import '../test_databases/database/floor_test_database_drift.dart' as drift;
import '../test_databases/entities/task.dart';
import '../test_databases/entities/task_drift.drift.dart';
import '../test_databases/support_classes/enums.dart';

// TODO test that all type converters are used. And with corrent priority db -> class -> field
// TODO test type converter with enum as db entity type
// TODO test INSERT UPDATE REMOVE
void main() {
  late drift.FloorTestDatabase driftDatabase;
  late floor.FloorTestDatabase floorDatabase;

  setUp(() async {
    floorDatabase = await floor.$FloorFloorTestDatabase.inMemoryDatabaseBuilder().build();
    driftDatabase = drift.FloorTestDatabase(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async {
    await floorDatabase.close();
    await driftDatabase.close();
  });

  group("check fields on entity", () {
    test("null initialization", () {
      final dateTime = DateTime.now();
      final taskDrift = TestTask(
        message: "",
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 5.2,
        integers: [1], // TODO IntListConverter doesnt work with empty list
      );

      final taskFloor = TestTask(
        message: "",
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 5.2,
        // TODO IntListConverter doesnt work with empty list
        integers: [1],
      );

      expect(taskDrift.toTask, EqualTaskMatcher(taskFloor));
    });

    test("value initialization", () {
      final dateTime = DateTime.now();
      final taskDrift = TestTask(
        id: 5,
        type: TaskType.story,
        isRead: true,
        message: "test message",
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 5.2,
        integers: [1, 2, 3, 4],
        attachment: Uint8List.fromList([6, 7, 3, 6]),
      );

      final taskFloor = TestTask(
        id: 5,
        type: TaskType.story,
        isRead: true,
        message: "test message",
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 5.2,
        integers: [1, 2, 3, 4],
        attachment: Uint8List.fromList([6, 7, 3, 6]),
      );

      expect(taskDrift.toTask, EqualTaskMatcher(taskFloor));
    });
  });

  // TODO maybe more default value tests
  // TODO server default?
  group("check field on companion", () {
    test("null initialization", () async {
      final dateTime = DateTime.now();

      final taskFloor = TestTask(
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 3.999,
        integers: [1], // TODO IntListConverter doesnt work with empty list
      );
      final driftInsertable = TestTasksCompanion.insert(
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 3.999,
        integers: [1],
      );

      final (taskDrift, voidValue) = await (
        driftDatabase.testTasks.insertReturning(driftInsertable),
        floorDatabase.taskDao.annotationInsertTask(taskFloor),
      ).wait;

      expect(taskDrift.toTask, EqualTaskMatcher(taskFloor));
    });

    test("value initialization", () {
      final dateTime = DateTime.now();
      final taskDrift = TestTask(
        id: 5,
        type: TaskType.story,
        isRead: true,
        message: "test message",
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 95123.5,
        attachment: Uint8List.fromList([6, 7, 3, 6]),
        integers: [5, 6],
      );

      final taskFloor = TestTask(
        id: 5,
        type: TaskType.story,
        isRead: true,
        message: "test message",
        timestamp: dateTime,
        status: TaskStatus.done,
        customDouble: 95123.5,
        attachment: Uint8List.fromList([6, 7, 3, 6]),
        integers: [5, 6],
      );

      expect(taskDrift.toTask, EqualTaskMatcher(taskFloor));
    });
  });

  test("INSERT TEST", () async {
    final dateTime = DateTime.now();

    final (_, _) = await (
      driftDatabase.testTasks.insertOne(
        TestTasksCompanion.insert(
          timestamp: dateTime,
          status: TaskStatus.inProgress,
          type: Value(TaskType.bug),
          customDouble: 859.258,
          integers: [1],
        ),
      ),
      floorDatabase.taskDao.annotationInsertTask(
        TestTask(
          timestamp: dateTime,
          status: TaskStatus.inProgress,
          type: TaskType.bug,
          customDouble: 859.258,
          integers: [1],
        ),
      ),
    ).wait;

    final (driftSelect, floorSelect) =
        await (driftDatabase.testTasks.select().get(), floorDatabase.taskDao.getAll()).wait;

    expect(driftSelect.length, equals(floorSelect.length));

    for (int i = 0; i < floorSelect.length; i++) {
      expect(floorSelect[i], EqualTaskMatcher(driftSelect[i].toTask));
    }
  });
}
