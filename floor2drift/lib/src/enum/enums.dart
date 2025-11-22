import 'package:analyzer/dart/element/type.dart';

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
  final Map<String, List<String>> convertedFields;

  String selector;
  String entityName;
  String currentFieldName;

  TableSelector(this.convertedFields, {this.selector = "", this.entityName = "", this.currentFieldName = ""});

  @override
  String toString() {
    // TODO hack because selector got replaced with tableSelector
    return selector;
  }
}

class TableSelectorBaseDao extends TableSelector {
  final String table;
  TableSelectorBaseDao(this.table, super.convertedFields, {super.selector, super.entityName, super.currentFieldName});
}

class TableSelectorDao extends TableSelector {
  final List<String> tables;
  TableSelectorDao(this.tables, super.convertedFields, {super.selector, super.entityName, super.currentFieldName});
}
