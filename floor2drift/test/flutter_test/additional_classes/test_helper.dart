import 'package:test/test.dart';

import '../test_databases/entities/task.dart';

class TestHelper {
  const TestHelper();
}

extension TaskDriftEntityExtension on TestTask? {
  TestTask? get toTask {
    if (this == null) {
      return null;
    }

    return TestTask(
      id: this!.id,
      status: this!.status,
      timestamp: this!.timestamp,
      type: this!.type,
      message: this!.message,
      isRead: this!.isRead,
      customDouble: this!.customDouble,
      integers: this!.integers,
      attachment: this!.attachment,
    );
  }
}

class EqualTaskMatcher extends Matcher {
  final Object? _expected;

  const EqualTaskMatcher(this._expected);

  @override
  Description describe(Description description) {
    return description.addDescriptionOf(_expected);
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    final expected = _expected;

    if (item == null && expected == null) {
      return true;
    }

    if (item is! TestTask || expected is! TestTask) {
      return false;
    }

    return _taskEqual(item, expected);
  }

  bool _taskEqual(TestTask floor, TestTask drift) {
    expect(floor.message, equals(drift.message));
    expect(floor.isRead, equals(drift.isRead));
    expect(floor.timestamp, equals(drift.timestamp));
    expect(floor.status, equals(drift.status));
    expect(floor.type, equals(drift.type));
    _listEqual(floor.attachment?.toList(), drift.attachment?.toList());
    _listEqual(floor.integers, drift.integers);
    expect(floor.customDouble, equals(drift.customDouble));

    return true;
  }

  bool _listEqual<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null && list2 == null) {
      return true;
    }

    expect(list1, isNotNull);
    expect(list2, isNotNull);

    expect(list1!.length, equals(list2!.length), reason: "list lengths aren't equal");

    for (int i = 0; i < list1.length; i++) {
      expect(list1[i], equals(list2[i]));
    }

    return true;
  }
}
