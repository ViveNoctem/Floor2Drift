import 'package:drift/drift.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';

@convertBaseEntity
abstract class TestBaseEntityOne<T> implements Insertable<T> {
  const TestBaseEntityOne();

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    // TODO: implement toColumns
    throw UnimplementedError();
  }
}
