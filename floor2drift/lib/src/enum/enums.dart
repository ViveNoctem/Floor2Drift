// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/generator/dao_generator.dart';

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

/// Represents the current state in an sql query
sealed class TableSelector {
  /// selectorName which should be used for functions
  String functionSelector;

  /// selector name for the current field
  String selector;

  /// FieldState of the current field being converted
  FieldState? currentFieldState;

  /// ClassState of the current dao class being converted
  // ClassState? currentClassState;

  /// ClassStates of the current dao query being converted
  /// can be multiple if the query is a joini
  List<ClassState> currentClassStates;

  /// TODO good idea?
  /// TODO should be set to true to force tableName.columName in an expression
  bool useSelector = false;

  final String tableNameSuffix;

  TableSelector({
    this.selector = "",
    this.currentFieldState,
    this.functionSelector = "s",
    required this.currentClassStates,
    required this.tableNameSuffix,
  });

  ClassState? getClassStateForTable(String tableName) {
    for (final classState in currentClassStates) {
      if (classState.sqlTablename.toLowerCase() != tableName.toLowerCase()) {
        continue;
      }

      return classState;
    }

    return null;
  }
}

/// {@template TableSelectorBaseDao}
/// Represents the current state in an sql query for a [BaseDaoGenerator]
/// {@endtemplate}
class TableSelectorBaseDao extends TableSelector {
  /// Selector name to access the inherited table
  final String table;

  /// {@macro TableSelectorBaseDao}
  TableSelectorBaseDao(
    this.table, {
    super.selector,
    super.currentFieldState,
    required super.currentClassStates,
    required super.tableNameSuffix,
  });
}

/// {@template TableSelectorDao}
/// Represents the current state in an sql query for a [DaoGenerator]
/// {@endtemplate}
class TableSelectorDao extends TableSelector {
  /// {@macro TableSelectorDao}
  TableSelectorDao({
    super.selector,
    super.currentFieldState,
    required super.currentClassStates,
    required super.tableNameSuffix,
  });
}
