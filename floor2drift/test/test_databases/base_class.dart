import 'package:drift/drift.dart';
import 'package:floor/floor.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';

@convertBaseEntity
abstract class BaseClass<T extends BaseClass<T>> extends Insertable<T> {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  const BaseClass({this.id});

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {"id": Variable(id)};
  }
}
