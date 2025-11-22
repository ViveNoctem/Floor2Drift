import 'package:drift/drift.dart';
import 'package:floor/floor.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';

@convertBaseEntity
class ExampleBaseClass<T extends ExampleBaseClass<T>> implements Insertable<T> {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  const ExampleBaseClass({this.id});

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {"id": Variable(id)};
  }
}
