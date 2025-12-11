import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/entity/annotation_converter/classState.dart';

enum EExpressionType { reference, colonNamedVariable, unkown }

enum EType {
  stream,
  future,
  list,
  voidType,
  unknown;

  static EType getByDartType(DartType dartType) {
    if (dartType.isDartCoreList) {
      return EType.list;
    }

    if (dartType.isDartAsyncStream) {
      return EType.stream;
    }

    if (dartType.isDartAsyncFuture) {
      return EType.future;
    }

    if (dartType is VoidType) {
      return EType.voidType;
    }

    return EType.unknown;
  }
}

enum EAggregateFunctions {
  count,
  avg,
  min,
  max,
  sum,
  total,
  // aliased to stringAgg
  groupConcat,
}

enum ETableNameOption {
  /// Uses the drift naming scheme
  ///
  /// tablename = entity name + s
  driftScheme,

  /// Uses the floor naming scheme
  ///
  /// tablename = entity name
  /// tablenames specified in the  @Entity annotation have priority.
  floorScheme,

  /// Uses the drift naming scheme, but uses the table name from the @Entity annotation, if specified.
  driftSchemeWithOverride,
}

sealed class TableSelector {
  String functionSelector;
  String selector;
  FieldState? currentFieldState;
  ClassState? currentClassState;

  TableSelector({
    this.selector = "",
    this.currentFieldState,
    this.functionSelector = "s",
    required this.currentClassState,
  });
}

class TableSelectorBaseDao extends TableSelector {
  final String table;
  TableSelectorBaseDao(
    this.table, {
    super.selector,
    super.currentFieldState,
    required super.currentClassState,
  });
}

class TableSelectorDao extends TableSelector {
  TableSelectorDao({
    super.selector,
    super.currentFieldState,
    required super.currentClassState,
  });
}
