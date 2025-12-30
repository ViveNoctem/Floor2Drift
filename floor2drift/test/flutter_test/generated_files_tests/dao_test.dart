import 'package:drift/drift.dart' show Uint8List, DatabaseConnection, Variable, TableStatements;
import 'package:drift/native.dart';
import 'package:test/test.dart';

import '../additional_classes/test_helper.dart';
import '../test_databases/dao/floor_task_dao.dart' as floor_dao;
import '../test_databases/dao/floor_task_dao_drift.dart' as drift_dao;
import '../test_databases/dao/task_user_view_dao.dart' as floor_view;
import '../test_databases/dao/task_user_view_dao_drift.dart' as drift_view;
import '../test_databases/database/floor_test_database.dart' as floor;
import '../test_databases/database/floor_test_database_drift.dart' as drift;
import '../test_databases/entities/task.dart';
import '../test_databases/support_classes/enums.dart';

// TODO Add test for integers with IntListConverter
// TODO Add tests for aggregate functions with filter clause
// TODO Add test for group_concat with order by
// TODO Add test for stringAgg
void main() {
  late floor.FloorTestDatabase floorDatabase;
  late drift.FloorTestDatabase driftDatabase;
  late floor_dao.TestTaskDao floorTaskDao;
  late drift_dao.TestTaskDao driftTaskDao;
  late floor_view.TaskUserViewDao floorTaskUserViewDao;
  late drift_view.TaskUserViewDao driftTaskUserViewDao;
  List<TestTask> floorTestEntities = [
    TestTask(
      id: 1,
      isRead: true,
      message: "1",
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      type: TaskType.bug,
      customDouble: 1.1,
      attachment: Uint8List.fromList(const [1, 2, 3]),
      integers: const [1, 2, 3],
      renamedString: "USELESS STRING",
    ),
    TestTask(
      id: 2,
      isRead: true,
      message: "2",
      timestamp: DateTime(2025, 2, 1),
      status: TaskStatus.inProgress,
      type: TaskType.story,
      customDouble: 1.1,
      attachment: Uint8List.fromList(const [1, 2, 3]),
      integers: const [1, 2, 3],
    ),
    TestTask(
      id: 3,
      isRead: true,
      message: "3",
      timestamp: DateTime(2025, 3, 1),
      status: TaskStatus.open,
      type: TaskType.task,
      customDouble: 2.2,
      attachment: Uint8List.fromList(const [4, 5, 6]),
      integers: const [4, 5, 6],
    ),
    TestTask(
      id: 4,
      isRead: true,
      message: "4",
      timestamp: DateTime(2025, 4, 1),
      status: TaskStatus.done,
      type: TaskType.bug,
      customDouble: 2.2,
      attachment: Uint8List.fromList(const [4, 5, 6]),
      integers: const [4, 5, 6],
    ),
    TestTask(
      id: 5,
      isRead: true,
      message: "5",
      timestamp: DateTime(2025, 5, 1),
      status: TaskStatus.inProgress,
      type: TaskType.task,
      customDouble: 3.3,
      attachment: Uint8List.fromList(const [7, 8, 9]),
      integers: const [7, 8, 9],
    ),
    TestTask(
      id: 6,
      isRead: false,
      message: "6",
      timestamp: DateTime(2025, 6, 1),
      status: TaskStatus.open,
      type: TaskType.story,
      customDouble: 3.3,
      attachment: Uint8List.fromList(const [7, 8, 9]),
      integers: const [7, 8, 9],
    ),
    TestTask(
      id: 7,
      isRead: false,
      message: "7",
      timestamp: DateTime(2025, 7, 1),
      status: TaskStatus.done,
      type: TaskType.story,
      customDouble: 4.4,
      attachment: Uint8List.fromList(const [10, 11, 12]),
      integers: const [10, 11, 12],
    ),
    TestTask(
      id: 8,
      isRead: false,
      message: "8",
      timestamp: DateTime(2025, 8, 1),
      status: TaskStatus.inProgress,
      type: TaskType.task,
      customDouble: 4.4,
      attachment: Uint8List.fromList(const [10, 11, 12]),
      integers: const [10, 11, 12],
    ),
    TestTask(
      id: 9,
      isRead: false,
      message: "9",
      timestamp: DateTime(2025, 9, 1),
      status: TaskStatus.open,
      type: TaskType.bug,
      customDouble: 5.5,
      attachment: Uint8List.fromList(const [13, 14, 15]),
      integers: const [13, 14, 15],
    ),
    TestTask(
      id: 10,
      isRead: false,
      message: "10",
      timestamp: DateTime(2025, 10, 1),
      status: TaskStatus.open,
      type: TaskType.bug,
      customDouble: 5.5,
      attachment: Uint8List.fromList(const [13, 14, 15]),
      integers: const [13, 14, 15],
    ),
    // TODO why is isRead and attachment not allowed to be null
    TestTask(
      id: 11,
      message: "Cased",
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      customDouble: 0,
      integers: const [1],
      isRead: false,
      attachment: Uint8List.fromList(const [1, 1, 1]),
    ),
    TestTask(
      id: 12,
      message: "cased",
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      customDouble: 0,
      integers: const [1],
      isRead: false,
      attachment: Uint8List.fromList(const [1, 1, 1]),
    ),
    TestTask(
      id: 13,
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      customDouble: 0,
      integers: const [1],
      isRead: false,
      type: null,
      attachment: Uint8List.fromList(const [1, 1, 1]),
    ),
  ];

  List<TestTask> driftTestEntities = [
    TestTask(
      id: 1,
      isRead: true,
      message: "1",
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      type: TaskType.bug,
      customDouble: 1.1,
      attachment: Uint8List.fromList(const [1, 2, 3]),
      integers: const [1, 2, 3],
      renamedString: "USELESS STRING",
    ),
    TestTask(
      id: 2,
      isRead: true,
      message: "2",
      timestamp: DateTime(2025, 2, 1),
      status: TaskStatus.inProgress,
      type: TaskType.story,
      customDouble: 1.1,
      attachment: Uint8List.fromList(const [1, 2, 3]),
      integers: const [1, 2, 3],
    ),
    TestTask(
      id: 3,
      isRead: true,
      message: "3",
      timestamp: DateTime(2025, 3, 1),
      status: TaskStatus.open,
      type: TaskType.task,
      customDouble: 2.2,
      attachment: Uint8List.fromList(const [4, 5, 6]),
      integers: const [4, 5, 6],
    ),
    TestTask(
      id: 4,
      isRead: true,
      message: "4",
      timestamp: DateTime(2025, 4, 1),
      status: TaskStatus.done,
      type: TaskType.bug,
      customDouble: 2.2,
      attachment: Uint8List.fromList(const [4, 5, 6]),
      integers: const [4, 5, 6],
    ),
    TestTask(
      id: 5,
      isRead: true,
      message: "5",
      timestamp: DateTime(2025, 5, 1),
      status: TaskStatus.inProgress,
      type: TaskType.task,
      customDouble: 3.3,
      attachment: Uint8List.fromList(const [7, 8, 9]),
      integers: const [7, 8, 9],
    ),
    TestTask(
      id: 6,
      isRead: false,
      message: "6",
      timestamp: DateTime(2025, 6, 1),
      status: TaskStatus.open,
      type: TaskType.story,
      customDouble: 3.3,
      attachment: Uint8List.fromList(const [7, 8, 9]),
      integers: const [7, 8, 9],
    ),
    TestTask(
      id: 7,
      isRead: false,
      message: "7",
      timestamp: DateTime(2025, 7, 1),
      status: TaskStatus.done,
      type: TaskType.story,
      customDouble: 4.4,
      attachment: Uint8List.fromList(const [10, 11, 12]),
      integers: const [10, 11, 12],
    ),
    TestTask(
      id: 8,
      isRead: false,
      message: "8",
      timestamp: DateTime(2025, 8, 1),
      status: TaskStatus.inProgress,
      type: TaskType.task,
      customDouble: 4.4,
      attachment: Uint8List.fromList(const [10, 11, 12]),
      integers: const [10, 11, 12],
    ),
    TestTask(
      id: 9,
      isRead: false,
      message: "9",
      timestamp: DateTime(2025, 9, 1),
      status: TaskStatus.open,
      type: TaskType.bug,
      customDouble: 5.5,
      attachment: Uint8List.fromList(const [13, 14, 15]),
      integers: const [13, 14, 15],
    ),
    TestTask(
      id: 10,
      isRead: false,
      message: "10",
      timestamp: DateTime(2025, 10, 1),
      status: TaskStatus.open,
      type: TaskType.bug,
      customDouble: 5.5,
      attachment: Uint8List.fromList(const [13, 14, 15]),
      integers: const [13, 14, 15],
    ),
    TestTask(
      id: 11,
      message: "Cased",
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      customDouble: 0,
      integers: const [1],
      isRead: false,
      attachment: Uint8List.fromList(const [1, 1, 1]),
    ),
    TestTask(
      id: 12,
      message: "cased",
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      customDouble: 0,
      integers: const [1],
      isRead: false,
      attachment: Uint8List.fromList(const [1, 1, 1]),
    ),
    TestTask(
      id: 13,
      message: 'default',
      timestamp: DateTime(2025, 1, 1),
      status: TaskStatus.done,
      type: null,
      customDouble: 0,
      integers: const [1],
      isRead: false,
      attachment: Uint8List.fromList(const [1, 1, 1]),
    ),
  ];

  List<TestUser> testUserEntities = [
    TestUser(name: "user1", password: "user1", id: 1, createdAt: DateTime(2020)),
    TestUser(name: "user2", password: "user2", id: 2, createdAt: DateTime(2020)),
    TestUser(name: "user3", password: "user3", id: 3, createdAt: DateTime(2020)),
    TestUser(name: "user4", password: "user4", id: 4, createdAt: DateTime(2020)),
    TestUser(name: "user5", password: "user5", id: 5, createdAt: DateTime(2020)),
  ];

  setUp(() async {
    floorDatabase = await floor.$FloorFloorTestDatabase.inMemoryDatabaseBuilder().build();
    floorTaskDao = floorDatabase.taskDao;
    await floorTaskDao.annotationInsertTasks(floorTestEntities);
    driftDatabase = drift.FloorTestDatabase(DatabaseConnection(NativeDatabase.memory()));
    driftTaskDao = driftDatabase.testTaskDao;
    await driftDatabase.testTasks.insertAll(driftTestEntities);

    floorTaskUserViewDao = floorDatabase.taskUserViewDao;
    driftTaskUserViewDao = driftDatabase.taskUserViewDao;
  });

  tearDown(() async {
    await floorDatabase.close();
    await driftDatabase.close();
  });

  group("WHERE", () {
    test("WHERE", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereId(1), driftTaskDao.whereId(1)).wait;

      expect(floorTask, EqualTaskMatcher(driftTask.toTask));
    });

    test("WHERE NOT EQUAL", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereNotEqual(8), driftTaskDao.whereNotEqual(8)).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE SMALLER BIGGGER", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereSmallerBigger(8),
        driftTaskDao.whereSmallerBigger(8),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE NOT EQUAL DATE", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereNotEqualDate(DateTime(2025, 10, 1)),
        driftTaskDao.whereNotEqualDate(DateTime(2025, 10, 1)),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE SMALLER BIGGER DATE", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereSmallerBiggerDate(DateTime(2025, 10, 1)),
        driftTaskDao.whereSmallerBiggerDate(DateTime(2025, 10, 1)),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE AND 1", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereAnd(2, true), driftTaskDao.whereAnd(2, true)).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE AND 2", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereAnd(8, true), driftTaskDao.whereAnd(8, true)).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE OR", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereOr(3, false), driftTaskDao.whereOr(3, false)).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE AND OR", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereAndOr(6, true, TaskStatus.done),
        driftTaskDao.whereAndOr(6, true, TaskStatus.done),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE AND OR 2", () async {
      // every task in the db has TaskStatus.done
      // TaskStatus in the sql query should not be TaskStatus.done
      final (floorTask, driftTask) = await (
        floorTaskDao.whereAndOr2(false, TaskStatus.open.index),
        driftTaskDao.whereAndOr2(false, TaskStatus.open.index),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("WHERE IN", () {
    test("WHERE IN", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereIn([2, 5]), driftTaskDao.whereIn([2, 5])).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE IN enum", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereInEnum([TaskStatus.open.index, TaskStatus.inProgress.index]),
        driftTaskDao.whereInEnum([TaskStatus.open.index, TaskStatus.inProgress.index]),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE IN 582", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereIn582(), driftTaskDao.whereIn582()).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE NOT IN", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereNotIn([8, 2]), driftTaskDao.whereNotIn([8, 2])).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE NOT IN enum", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereNotInEnum([TaskStatus.done.index]),
        driftTaskDao.whereNotInEnum([TaskStatus.done.index]),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE NOT IN 791", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereNotIn791(), driftTaskDao.whereNotIn791()).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE AND OR IN", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereAndOrIn(3, false, [TaskStatus.inProgress.index, TaskStatus.done.index]),
        driftTaskDao.whereAndOrIn(3, false, [TaskStatus.inProgress.index, TaskStatus.done.index]),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("WHERE SMALLER BIGGER", () {
    test("WHERE BIGGER", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereBigger(4), driftTaskDao.whereBigger(4)).wait;

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE BIGGER EQUAL", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereBiggerEqual(4), driftTaskDao.whereBiggerEqual(4)).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE SMALLER", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereSmaller(4), driftTaskDao.whereSmaller(4)).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE SMALLER EQUAL", () async {
      final (floorTask, driftTask) = await (floorTaskDao.whereSmallerEqual(4), driftTaskDao.whereSmallerEqual(4)).wait;
      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE BIGGER DATE", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereBiggerDate(DateTime(2025, 9, 1)),
        driftTaskDao.whereBiggerDate(DateTime(2025, 9, 1)),
      ).wait;

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE BIGGER EQUAL DATE", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereBiggerEqualDate(DateTime(2025, 9, 1)),
        driftTaskDao.whereBiggerEqualDate(DateTime(2025, 9, 1)),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE SMALLER DATE", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereSmallerDate(DateTime(2025, 9, 1)),
        driftTaskDao.whereSmallerDate(DateTime(2025, 9, 1)),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("WHERE SMALLER EQUAL DATE", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereSmallerEqualDate(DateTime(2025, 9, 1)),
        driftTaskDao.whereSmallerEqualDate(DateTime(2025, 9, 1)),
      ).wait;
      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("LIKE", () {
    setUp(() async {
      final now = DateTime.now();
      final likeEntitesFloor = [
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "testmessage", integers: [1]),
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "testmessage", integers: [1]),
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "test message", integers: [1]),
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "message", integers: [1]),
      ];

      final likeEntitiesDrift = [
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "testmessage", integers: [1]),
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "testmessage", integers: [1]),
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "test message", integers: [1]),
        TestTask(timestamp: now, status: TaskStatus.open, customDouble: 0, message: "message", integers: [1]),
      ];
      await (
        floorTaskDao.annotationInsertTasks(likeEntitesFloor),
        driftDatabase.testTasks.insertAll(likeEntitiesDrift),
      ).wait;
    });

    test("LIKE %", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.likeMessage("%message"),
        driftTaskDao.likeMessage("%message"),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("LIKE _", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.likeMessage("test_message"),
        driftTaskDao.likeMessage("test_message"),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    // TODO not supported at the moment
    // test("LIKE ESCAPE", () {
    //
    // });
  });

  group("type test", () {
    group("Uint8List", () {
      test("single Uint8List", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.returnSingleUint8List(4),
          driftTaskDao.returnSingleUint8List(4),
        ).wait;

        expect(floorTask, equals(driftTask));
      });

      test("multiple Uint8List", () async {
        // TODO why is isRead and attachment not allowed to be null
        final (floorTask, driftTask) = await (
          floorTaskDao.returnMultipleUint8List(4),
          driftTaskDao.returnMultipleUint8List(4),
        ).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i]?.length, equals(driftTask[i]?.length));
          final floorIter = floorTask[i]?.iterator;
          final driftIter = driftTask[i]?.iterator;

          for (int n = 0; n < (floorTask[i]?.length ?? 0); n++) {
            floorIter?.moveNext();
            driftIter?.moveNext();
            expect(floorIter?.current, equals(driftIter?.current));
          }
        }
      });

      test("where Uint8List", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.whereUint8List(Uint8List.fromList(const [4, 5, 6])),
          driftTaskDao.whereUint8List(Uint8List.fromList(const [4, 5, 6])),
        ).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
        }
      });
    });

    group("double", () {
      test("single double", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.returnSingleDouble(8),
          driftTaskDao.returnSingleDouble(8),
        ).wait;

        expect(floorTask, equals(driftTask));
      });

      test("multiple double", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.returnMultipleDouble(2),
          driftTaskDao.returnMultipleDouble(2),
        ).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], equals(driftTask[i]));
        }
      });

      test("where double", () async {
        final (floorTask, driftTask) = await (floorTaskDao.whereDouble(5.5), driftTaskDao.whereDouble(5.5)).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
        }
      });
    });

    group("int", () {
      test("single int", () async {
        final (floorTask, driftTask) = await (floorTaskDao.returnSingleInt(8), driftTaskDao.returnSingleInt(8)).wait;

        expect(floorTask, equals(driftTask));
      });

      test("multiple int", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.returnMultipleInt(2),
          driftTaskDao.returnMultipleInt(2),
        ).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], equals(driftTask[i]));
        }
      });

      test("where int", () async {
        final (floorTask, driftTask) = await (floorTaskDao.whereInt(2), driftTaskDao.whereInt(2)).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
        }
      });
    });

    group("bool", () {
      // TODO why is isRead and attachment not allowed to be null
      test("single bool", () async {
        final (floorTask, driftTask) = await (floorTaskDao.returnSingleBool(3), driftTaskDao.returnSingleBool(3)).wait;

        expect(floorTask, equals(driftTask));
      });

      test("multiple bool", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.returnMultipleBool(3),
          driftTaskDao.returnMultipleBool(3),
        ).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], equals(driftTask[i]));
        }
      });

      test("where bool", () async {
        final (floorTask, driftTask) = await (floorTaskDao.whereBool(true), driftTaskDao.whereBool(true)).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
        }
      });
    });

    group("String", () {
      test("single String", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.returnSingleString(9),
          driftTaskDao.returnSingleString(9),
        ).wait;

        expect(floorTask, equals(driftTask));
      });

      test("multiple String", () async {
        final (floorTask, driftTask) = await (
          floorTaskDao.returnMultipleString(1),
          driftTaskDao.returnMultipleString(1),
        ).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], equals(driftTask[i]));
        }
      });

      test("where String", () async {
        final (floorTask, driftTask) = await (floorTaskDao.whereString("9"), driftTaskDao.whereString("9")).wait;

        expect(floorTask.length, equals(driftTask.length));
        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
        }
      });
    });
  });

  group("DELETE", () {
    test("WHERE", () async {
      await (floorTaskDao.deleteWhereId(5), driftTaskDao.deleteWhereId(5)).wait;

      final (floorTask, driftTask) = await (floorTaskDao.getAll(), driftTaskDao.getAll()).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("ALL", () async {
      await (floorTaskDao.deleteAll(), driftTaskDao.deleteAll()).wait;

      final (floorTask, driftTask) = await (floorTaskDao.getAll(), driftTaskDao.getAll()).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("aggregate functions", () {
    // if aggregate function tests are added. Also add to BaseEntity Group
    group("entity", () {
      group("COUNT", () {
        test("*", () async {
          final (floorTask, driftTask) = await (floorTaskDao.count(), driftTaskDao.count()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (floorTaskDao.countWhere(4), driftTaskDao.countWhere(4)).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("AVG", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.avg(), driftTaskDao.avg()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE ", () async {
          final (floorTask, driftTask) = await (floorTaskDao.avgWhere(8), driftTaskDao.avgWhere(8)).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("MIN", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.min(), driftTaskDao.min()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE ", () async {
          final (floorTask, driftTask) = await (floorTaskDao.minWhere(8), driftTaskDao.minWhere(8)).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("MAX", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.max(), driftTaskDao.max()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (floorTaskDao.maxWhere(3), driftTaskDao.maxWhere(3)).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("SUM", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.sum(), driftTaskDao.sum()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (floorTaskDao.sumWhere(8), driftTaskDao.sumWhere(8)).wait;

          expect(floorTask, equals(driftTask));
        });

        // sum doesn't seem to be able to return null in floor
        test("NULL", () async {
          final sum = await driftTaskDao.sumWhere(0);
          expect(sum, equals(null));
        });
      });

      group("TOTAL", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.total(), driftTaskDao.total()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (floorTaskDao.totalWhere(8), driftTaskDao.totalWhere(8)).wait;

          expect(floorTask, equals(driftTask));
        });

        test("0.0", () async {
          final (floorTask, driftTask) = await (floorTaskDao.totalWhere(0), driftTaskDao.totalWhere(0)).wait;
          expect(floorTask, equals(0.0));

          expect(floorTask, equals(driftTask));
        });
      });
    });

    // copied test cases from entitiy aggregate function tests
    group("baseEntitiy", () {
      group("COUNT", () {
        test("*", () async {
          final (floorTask, driftTask) = await (floorTaskDao.countBaseEntity(), driftTaskDao.countBaseEntity()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (
            floorTaskDao.countWhereBaseEntity(4),
            driftTaskDao.countWhereBaseEntity(4),
          ).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("AVG", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.avgBaseEntity(), driftTaskDao.avgBaseEntity()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE ", () async {
          final (floorTask, driftTask) = await (
            floorTaskDao.avgWhereBaseEntity(8),
            driftTaskDao.avgWhereBaseEntity(8),
          ).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("MIN", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.minBaseEntity(), driftTaskDao.minBaseEntity()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE ", () async {
          final (floorTask, driftTask) = await (
            floorTaskDao.minWhereBaseEntity(8),
            driftTaskDao.minWhereBaseEntity(8),
          ).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("MAX", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.maxBaseEntity(), driftTaskDao.maxBaseEntity()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (
            floorTaskDao.maxWhereBaseEntity(3),
            driftTaskDao.maxWhereBaseEntity(3),
          ).wait;

          expect(floorTask, equals(driftTask));
        });
      });

      group("SUM", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.sumBaseEntity(), driftTaskDao.sumBaseEntity()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (
            floorTaskDao.sumWhereBaseEntity(8),
            driftTaskDao.sumWhereBaseEntity(8),
          ).wait;

          expect(floorTask, equals(driftTask));
        });

        // sum doesn't seem to be able to return null in floor
        test("NULL", () async {
          final sum = await driftTaskDao.sumWhereBaseEntity(0);
          expect(sum, equals(null));
        });
      });

      group("TOTAL", () {
        test("ALL", () async {
          final (floorTask, driftTask) = await (floorTaskDao.totalBaseEntity(), driftTaskDao.totalBaseEntity()).wait;

          expect(floorTask, equals(driftTask));
        });

        test("WHERE", () async {
          final (floorTask, driftTask) = await (
            floorTaskDao.totalWhereBaseEntity(8),
            driftTaskDao.totalWhereBaseEntity(8),
          ).wait;

          expect(floorTask, equals(driftTask));
        });

        test("0.0", () async {
          final (floorTask, driftTask) = await (
            floorTaskDao.totalWhereBaseEntity(0),
            driftTaskDao.totalWhereBaseEntity(0),
          ).wait;
          expect(floorTask, equals(0.0));

          expect(floorTask, equals(driftTask));
        });
      });
    });
  });

  group("Update", () {
    test("updateMessage", () async {
      final (floorResult, driftResult) = await (
        floorTaskDao.updateMessage(8, "New Message"),
        driftTaskDao.updateMessage(8, "New Message"),
      ).wait;

      expect(floorResult, equals(driftResult));

      final (floorTask, driftTask) = await (floorTaskDao.findTaskById(8), driftTaskDao.findTaskById(8)).wait;

      expect(floorTask, EqualTaskMatcher(driftTask));
    });

    // TODO WHERE IN doesn't work in custom update statement
    //   test("updateMultipleMessage", () async {
    //     final (floorResult, driftResult) =
    //         await (
    //           floorTaskDao.updateMultipleMessages([8, 7], "New Message"),
    //           driftTaskDao.updateMultipleMessages([8, 7], "New Message"),
    //         ).wait;
    //
    //     // expect(floorResult, equals(driftResult));
    //
    //     final (floorTask8, driftTask8) = await (floorTaskDao.findTaskById(8), driftTaskDao.findTaskById(8)).wait;
    //
    //     expect(floorTask8, EqualTaskMatcher(driftTask8));
    //
    //     final (floorTask7, driftTask7) = await (floorTaskDao.findTaskById(7), driftTaskDao.findTaskById(7)).wait;
    //
    //     expect(floorTask7, EqualTaskMatcher(driftTask7));
    //   });
  });

  group("BETWEEN", () {
    test("int", () async {
      final (floorTask, driftTask) = await (floorTaskDao.betweenId(5, 7), driftTaskDao.betweenId(5, 7)).wait;
      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("not string", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.betweenNotMessage("3", "6"),
        driftTaskDao.betweenNotMessage("3", "6"),
      ).wait;
      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i]));
      }
    });

    // TODO floor doesn't seem to support enum with typeConverters in query arguments
    // TODO floor uses .index instead of the converter
    test("not enum", () async {
      final driftTask = await driftTaskDao.betweenNotTaskType(TaskType.bug, TaskType.story);

      expect(driftTask.length, equals(3));

      expect(driftTask[0].id, equals(3));
      expect(driftTask[1].id, equals(5));
      expect(driftTask[2].id, equals(8));
    });
  });

  group("annotation", () {
    group("delete", () {
      test("single", () async {
        final (floorTask, driftTask) = await (floorTaskDao.findTaskById(2), driftTaskDao.findTaskById(2)).wait;

        expect(floorTask, EqualTaskMatcher(driftTask));

        final (floorDeleteResult, driftDeleteResult) = await (
          floorTaskDao.annotationDeleteTask(floorTask!),
          driftTaskDao.annotationDeleteTask(driftTask!),
        ).wait;

        expect(floorDeleteResult, equals(driftDeleteResult));
      });

      test("multiple", () async {
        final (floorTask, driftTask) = await (floorTaskDao.findAllTasks(), driftTaskDao.findAllTasks()).wait;

        final lengthBefore = floorTask.length;

        expect(floorTask.length, equals(driftTask.length));

        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i]));
        }

        final (floorDeleteResult, driftDeleteResult) = await (
          floorTaskDao.annotationDeleteTasks(floorTask.sublist(0, 5)),
          driftTaskDao.annotationDeleteTasks(driftTask.sublist(0, 5)),
        ).wait;

        expect(floorDeleteResult, equals(5));

        // The current implementation always return -1;
        expect(driftDeleteResult, equals(floorDeleteResult));

        // Because the return value doesn't work check if the deleted values are missing in the db
        final (floorTaskDeleted, driftTaskDeleted) = await (
          floorTaskDao.findAllTasks(),
          driftTaskDao.findAllTasks(),
        ).wait;

        expect(floorTaskDeleted.length, equals(lengthBefore - 5));

        expect(floorTaskDeleted.length, equals(driftTaskDeleted.length));

        for (int i = 0; i < floorTaskDeleted.length; i++) {
          expect(floorTaskDeleted[i], EqualTaskMatcher(driftTaskDeleted[i]));
        }
      });
    });

    group("insert", () {
      test("single", () async {
        final insertTask = TestTask(
          timestamp: DateTime.now(),
          status: TaskStatus.done,
          customDouble: 0.05,
          integers: [1, 2],
        );

        final (floorInsertResult, driftInsertResult) = await (
          floorTaskDao.annotationInsertTask(insertTask),
          driftTaskDao.annotationInsertTask(insertTask),
        ).wait;
        expect(floorInsertResult, equals(driftInsertResult));

        final (floorTask, driftTask) = await (
          floorTaskDao.findTaskById(floorInsertResult),
          driftTaskDao.findTaskById(driftInsertResult),
        ).wait;

        expect(floorTask, EqualTaskMatcher(driftTask));
      });

      test("multiple", () async {
        final insertTask = [
          TestTask(timestamp: DateTime.now(), status: TaskStatus.done, customDouble: 0.05, integers: [1, 2, 3]),
          TestTask(timestamp: DateTime.now(), status: TaskStatus.open, customDouble: 1.5555, integers: [5]),
        ];

        final (floorInsertResult, driftInsertResult) = await (
          floorTaskDao.annotationInsertTasks(insertTask),
          driftTaskDao.annotationInsertTasks(insertTask),
        ).wait;

        expect(floorInsertResult.length, equals(2));

        // current implementation always returns empty list
        // expect(driftInsertResult, isEmpty);

        expect(floorInsertResult.length, equals(driftInsertResult.length));

        expect(floorInsertResult[0], equals(14));
        expect(floorInsertResult[1], equals(15));

        for (int i = 0; i < floorInsertResult.length; i++) {
          expect(floorInsertResult[i], equals(driftInsertResult[i]));
        }

        var (floorTask, driftTask) = await (floorTaskDao.findTaskById(14), driftTaskDao.findTaskById(14)).wait;

        expect(floorTask, EqualTaskMatcher(driftTask));

        (floorTask, driftTask) = await (floorTaskDao.findTaskById(15), driftTaskDao.findTaskById(15)).wait;

        expect(floorTask, EqualTaskMatcher(driftTask));
      });

      test("insert user", () async {
        final now = DateTime.now();
        final users = [
          TestUser(name: "name1", password: "password1", id: 11, createdAt: now),
          TestUser(name: "name2", password: "password2", id: 22, createdAt: now),
          TestUser(name: "name3", password: "password3", id: 33, createdAt: now),
          TestUser(name: "name4", password: "password4", id: 44, createdAt: now),
          TestUser(name: "name5", password: "password5", id: 55, createdAt: now),
        ];

        for (final user in users) {
          await (floorTaskDao.annotationInsertUser(user), driftTaskDao.annotationInsertUser(user)).wait;
        }

        final (floorResult, driftResult) = await (floorTaskDao.getAllUsers(), driftTaskDao.getAllUsers()).wait;

        expect(floorResult.length, equals(5));

        expect(floorResult, equals(driftResult));
      });
    });

    group("update", () {
      test("single", () async {
        var (floorTask, driftTask) = await (floorTaskDao.findTaskById(2), driftTaskDao.findTaskById(2)).wait;

        expect(floorTask, EqualTaskMatcher(driftTask));

        floorTask = floorTask!.copyWithMessage("NewMessage");
        driftTask = driftTask!.copyWithMessage("NewMessage");

        final (floorUpdateResult, driftUpdateResult) = await (
          floorTaskDao.annotationUpdateTask(floorTask!),
          driftTaskDao.annotationUpdateTask(driftTask!),
        ).wait;
        expect(floorUpdateResult, equals(1));

        // Current implementation always returns -1
        expect(driftUpdateResult, equals(-1));

        (floorTask, driftTask) = await (floorTaskDao.findTaskById(2), driftTaskDao.findTaskById(2)).wait;

        expect(floorTask!.message, equals("NewMessage"));

        expect(floorTask, EqualTaskMatcher(driftTask));
      });

      test("multiple", () async {
        var (floorTask, driftTask) = await (floorTaskDao.findAllTasks(), driftTaskDao.findAllTasks()).wait;

        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i]));
        }

        floorTask = floorTask.map<TestTask>((s) => s.copyWithMessage("NewMessage")).toList();
        driftTask = driftTask.map<TestTask>((s) => s.copyWithMessage("NewMessage")).toList();

        final (floorUpdateResult, driftUpdateResult) = await (
          floorTaskDao.annotationUpdateTasks(floorTask),
          driftTaskDao.annotationUpdateTasks(driftTask),
        ).wait;
        expect(floorUpdateResult, equals(13));

        // Current implementation always returns -1
        expect(driftUpdateResult, equals(-1));

        (floorTask, driftTask) = await (floorTaskDao.findAllTasks(), driftTaskDao.findAllTasks()).wait;

        for (final task in floorTask) {
          expect(task.message, equals("NewMessage"));
        }

        for (int i = 0; i < floorTask.length; i++) {
          expect(floorTask[i], EqualTaskMatcher(driftTask[i]));
        }
      });
    });
  });

  group("renaming", () {
    test("baseClass", () async {
      final (floorString, driftString) = await (
        floorTaskDao.renamedStringTestBaseDao(1, "6"),
        driftTaskDao.renamedStringTestBaseDao(1, "6"),
      ).wait;

      expect(floorString, equals(driftString));
    });

    test("check rename in db", () async {
      final row = await driftDatabase
          .customSelect(
            "SELECT DifFeReNt_STRING FROM TASKTEST WHERE id = :id or DifFeReNt_STRING = :renamedString",
            variables: [Variable(1), Variable("6")],
          )
          .getSingleOrNull();

      expect(row, isNotNull);

      final driftString = row!.read<String>("DifFeReNt_StRiNg");

      final floorString = await floorTaskDao.renamedStringTestBaseDao(1, "6");

      expect(floorString, equals(driftString));
    });

    test("entity", () async {
      final (floorString, driftString) = await (
        floorTaskDao.renamedStringTest(1, "6"),
        driftTaskDao.renamedStringTest(1, "6"),
      ).wait;

      expect(floorString, equals(driftString));
    });
  });

  group("ORDER BY", () {
    test("default", () async {
      final (floorTask, driftTask) = await (floorTaskDao.orderById(), driftTaskDao.orderById()).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("simple ASC", () async {
      final (floorTask, driftTask) = await (floorTaskDao.orderByIdAsc(), driftTaskDao.orderByIdAsc()).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("simple DESC", () async {
      final (floorTask, driftTask) = await (floorTaskDao.orderByIdDesc(), driftTaskDao.orderByIdDesc()).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("nulls last", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.orderByTypeDescNullsLast(),
        driftTaskDao.orderByTypeDescNullsLast(),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));
      expect(floorTask.last.type, equals(null));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("nulls last", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.orderByTypeDescNullsFirst(),
        driftTaskDao.orderByTypeDescNullsFirst(),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));
      expect(floorTask.first.type, equals(null));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });

    test("where", () async {
      final (floorTask, driftTask) = await (floorTaskDao.getOrderByWhere(5), driftTaskDao.getOrderByWhere(5)).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("subquery", () {
    test("whereInSubquery", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.whereInSubquery([1, 2, 5]),
        driftTaskDao.whereInSubquery([1, 2, 5]),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));

      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("bitwise", () {
    test("OR", () async {
      final (floorIds, driftIds) = await (floorTaskDao.bitwiseOrId(4, 2), driftTaskDao.bitwiseOrId(4, 2)).wait;

      expect(floorIds.length, equals(driftIds.length));

      for (int i = 0; i < floorIds.length; i++) {
        expect(floorIds[i], driftIds[i]);
      }
    });

    test("AND", () async {
      final (floorIds, driftIds) = await (floorTaskDao.bitwiseAndId(12, 6), driftTaskDao.bitwiseAndId(12, 6)).wait;

      expect(floorIds.length, equals(driftIds.length));

      for (int i = 0; i < floorIds.length; i++) {
        expect(floorIds[i], driftIds[i]);
      }
    });

    test("NEGATION", () async {
      final (floorIds, driftIds) = await (
        floorTaskDao.bitwiseNegationId(4, -3),
        driftTaskDao.bitwiseNegationId(4, -3),
      ).wait;

      expect(floorIds.length, equals(driftIds.length));

      for (int i = 0; i < floorIds.length; i++) {
        expect(floorIds[i], driftIds[i]);
      }
    });
  });

  group("COLLATE", () {
    test("message", () async {
      final (floorMessages, driftMessages) = await (floorTaskDao.collateMessage(), driftTaskDao.collateMessage()).wait;

      expect(floorMessages.length, equals(driftMessages.length));

      expect(floorMessages[0], equals("default"));
      expect(floorMessages[1], equals("Cased"));
      expect(floorMessages[2], equals("cased"));

      for (int i = 0; i < floorMessages.length; i++) {
        expect(floorMessages[i], driftMessages[i]);
      }
    });
  });

  group("implemented method", () {
    test("implementedGetAll", () async {
      final (floorTask, driftTask) = await (floorTaskDao.implementedGetAll(), driftTaskDao.implementedGetAll()).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("transaction", () {
    test("transactionGetEveryOther", () async {
      final (floorTask, driftTask) = await (
        floorTaskDao.transactionGetEveryOther(),
        driftTaskDao.transactionGetEveryOther(),
      ).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], EqualTaskMatcher(driftTask[i].toTask));
      }
    });
  });

  group("View", () {
    setUp(() async {
      for (final user in testUserEntities) {
        await floorTaskDao.annotationInsertUser(user);
        await driftTaskDao.annotationInsertUser(user);
      }
    });

    test("description", () async {
      final (floorTask, driftTask) = await (floorTaskUserViewDao.getAll(), driftTaskUserViewDao.getAll()).wait;

      expect(floorTask.length, equals(driftTask.length));
      for (int i = 0; i < floorTask.length; i++) {
        expect(floorTask[i], equals(driftTask[i]));
      }
    });
  });
  //
  // group("DISTINCT", () {
  //   test("", () {});
  // });
  //
  // group("SELECT", () {
  //   test("", () {});
  // });
  //
  // group("GROUP BY", () {
  //   test("", () {});
  // });
}
