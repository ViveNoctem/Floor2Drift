import 'package:drift/drift.dart';
import 'package:floor/floor.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';

import '../support_classes/interfaces.dart';
import 'base_class_drift.dart';

/// Documentation for a baseEntity
@convertBaseEntity
abstract class BaseClass<T extends BaseClass<T>> extends Insertable<T> implements InterfaceOne<T>, InterfaceTwo {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "DifFeReNt_StRiNg")
  final String? renamedString;

  const BaseClass({this.id, this.renamedString});

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return BaseClassMixin.toColumns(nullToAbsent, this);
  }
}
