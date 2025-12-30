import 'dart:io';
import 'dart:typed_data';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/sql/expression_converter/expression_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

/// {@template SqlHelper}
/// Helper Class to Convert Sql Code to Drift Core Api Calls
/// {@endtemplate}
class SqlHelper {
  final ExpressionConverterUtil _expressionConverterUtil;

  /// {@macro SqlHelper}
  const SqlHelper({ExpressionConverterUtil expressionConverterUtil = const ExpressionConverterUtil()})
    : _expressionConverterUtil = expressionConverterUtil;

  /// static sqlEngine to parse SQL code to AST
  static final sqlEngine = SqlEngine();

  /// returns the drift code for a ORDER by clause
  ValueResponse<String> addOrderByClause(
    OrderBy orderBy,
    Element element,
    List<ParameterElement> parameters,
    TableSelector selector,
    bool useSelectOnly,
  ) {
    var result = "..orderBy([";

    final orderingTermns = <String>[];

    for (final orderingTerm in orderBy.terms) {
      if (orderingTerm is! OrderingTerm) {
        return ValueResponse.error("Order by termin $orderingTerm is not a OrderingTerm", element);
      }

      final orderingTermResult = _addOrderingTerm(orderingTerm, selector, element, parameters, useSelectOnly);

      switch (orderingTermResult) {
        case ValueError<String>():
          return orderingTermResult.wrap();
        case ValueData<String>():
      }

      orderingTermns.add(orderingTermResult.data);
    }

    result += orderingTermns.join(",");

    result += "])";

    return ValueResponse.value(result);
  }

  ValueResponse<String> _addOrderingTerm(
    OrderingTerm orderingTerm,
    TableSelector selector,
    Element element,
    List<ParameterElement> parameters,
    bool useSelectOnly,
  ) {
    final mode = _getOrderingMode(orderingTerm.orderingMode);

    final expressionResult = _expressionConverterUtil.parseExpression(
      orderingTerm.expression,
      element,
      parameters: parameters,
      selector: selector,
    );

    switch (expressionResult) {
      case ValueError<(String, EExpressionType)>():
        return expressionResult.wrap();
      case ValueData<(String, EExpressionType)>():
    }

    final expression = "expression: ${expressionResult.data.$1}";

    final nulls = _getNulls(orderingTerm.nulls);

    var result = "";

    // if selectOnly is used do not add the function selector
    if (useSelectOnly == false) {
      result += "(${selector.functionSelector}) =>";
    }

    result += "OrderingTerm($expression$mode$nulls)";
    return ValueResponse.value(result);
  }

  String _getOrderingMode(OrderingMode? mode) {
    if (mode == null) {
      return "";
    }

    var result = ", mode: ";

    result += switch (mode) {
      OrderingMode.ascending => "OrderingMode.asc",
      OrderingMode.descending => "OrderingMode.desc",
    };

    return result;
  }

  String _getNulls(OrderingBehaviorForNulls? nulls) {
    if (nulls == null) {
      return "";
    }

    var result = ", nulls: ";

    result += switch (nulls) {
      OrderingBehaviorForNulls.first => "NullsOrder.first",
      OrderingBehaviorForNulls.last => "NullsOrder.last",
    };

    return result;
  }

  /// returns the drift code for a WHERE clause
  ValueResponse<String> addWhereClause(
    Expression whereExpression,
    Element element,
    List<ParameterElement> parameters,
    bool useTableSelector,
    TableSelector selector,
  ) {
    var result = "..where(";
    if (useTableSelector == false) {
      result += "(${selector.functionSelector}) => ";
    }

    final whereResult = _expressionConverterUtil.parseExpression(
      whereExpression,
      element,
      parameters: parameters,
      selector: selector,
    );

    switch (whereResult) {
      case ValueData<(String, EExpressionType)>():
        break;
      case ValueError<(String, EExpressionType)>():
        return whereResult.wrap();
    }

    result += whereResult.data.$1;
    result += ")";
    return ValueResponse.value(result);
  }

  /// depending on [returnType] returns the different calls on how to execute the sql query
  String getGetter(TypeSpecification returnType) {
    var getterMethod = ".";

    switch (returnType.type) {
      case EType.future:
        switch (returnType.firstTypeArgument) {
          case EType.unknown:
            getterMethod += "getSingleOrNull";
          case EType.list:
            getterMethod += "get";
          case EType.voidType:
            print("Void Type not supported here");
            return "";
          default:
            print("Type not supported");
            return "";
        }
      case EType.stream:
        switch (returnType.firstTypeArgument) {
          case EType.unknown:
            getterMethod += "watchSingleOrNull";
          case EType.list:
            getterMethod += "watch";
          case EType.voidType:
            print("Void Type not supported here");
            return "";
          default:
            print("Type not supported");
            return "";
        }
      default:
        print("Returntype is not supported");
        return "";
    }

    getterMethod += "()";
    return getterMethod;
  }

  /// checks if the given entityName in the [selector] has a typeConverter
  ///
  /// if true returns code to convert the give [argumentName] with the correct typeConverter
  /// if false returns an empty string
  String checkTypeConverter(TableSelector selector, String argumentName) {
    final currentField = selector.currentFieldState;

    assert(currentField != null, "currentFieldState must always be set here");

    if (currentField == null) {
      return "";
    }

    if (currentField.isConverted == false) {
      return "";
    }

    return "${selector.selector}.${currentField.fieldName}.converter.toSql($argumentName)";
  }

  /// returns if the given [type] is a sql native type
  ///
  /// Stream, Future, and List are being unwrapped and the result for the type argument is retunred
  // TODO is used to determine if the typeConverter should be used or not
  // TODO doesn't work with string to string converter.
  // TODO The to and from type of the converter is needed to better determine if the converter should be used or not
  // TODO For a correct solution the typeConverter to-/ from type is needed
  // TODO floor seems to use somthing similar. these cases don't seem to work either
  bool isNativeSqlType(DartType type) {
    var localType = type;

    // unwrap future or stream type argument
    if (localType.isDartAsyncFuture || localType.isDartAsyncStream) {
      if (localType is! InterfaceType) {
        return false;
      }
      final nullableType = localType.typeArguments.firstOrNull;

      if (nullableType == null) {
        return false;
      }

      localType = nullableType;
    }

    // unwrap list type argument
    if (localType.isDartCoreList) {
      if (localType is! InterfaceType) {
        return false;
      }
      final nullableType = localType.typeArguments.firstOrNull;

      if (nullableType == null) {
        return false;
      }

      localType = nullableType;
    }

    if (localType.isDartCoreInt ||
        localType.isDartCoreBool ||
        localType.isDartCoreString ||
        localType.isDartCoreDouble) {
      return true;
    }

    if (const TypeChecker.fromRuntime(Uint8List).isExactlyType(localType)) {
      return true;
    }

    return false;
  }

  /// initializes different field in the given [tableSelector]
  ///
  /// set the selector, currentClassState, and entityName
  TableSelector configureTableSelector(
    TableSelector tableSelector,
    DatabaseState dbState,
    List<String> fromTableNames,
  ) {
    switch (tableSelector) {
      case TableSelectorBaseDao():
        tableSelector.selector = tableSelector.table;
      // currentClassState is set when creating the TableSelectorBaseDao
      case TableSelectorDao():
        final newClassStates = <ClassState>[];
        outerLoop:
        for (final state in dbState.entityClassStates) {
          for (final tableName in fromTableNames) {
            if (state.sqlTablename.toLowerCase() != tableName.toLowerCase()) {
              continue;
            }
            newClassStates.add(state);

            if (newClassStates.length == fromTableNames.length) {
              break outerLoop;
            }
          }
        }

        // setting the selector here
        tableSelector.selector = newClassStates.firstOrNull?.driftTableGetter ?? "";
        tableSelector.currentClassStates = newClassStates;

      // TODO selector has to be set directly in the expression conversion
      // TODO has the expression access to the tablename if tablename.columnname is used?
      // TODO if no tableName is set search the classState for the correct table
      // TODO abort if the table cannot be found
      // if (tableSelector.currentClassState == null) {
      //   return tableSelector;
      // }

      // final selectorName = tableSelector.currentClassState!.className;
      // tableSelector.selector = "${ReCase(selectorName).camelCase}s";
    }

    return tableSelector;
  }

  ValueResponse<(String, String)> addSelectClause(
    SelectStatement statement,
    Element element,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
    List<ResultColumn> columns,
    bool useSelectOnly,
    bool isView,
  ) {
    String result;
    var selectOnlyFunctionResult = "";
    if (useSelectOnly) {
      for (final column in columns) {
        if (column is! ExpressionResultColumn) {
          return ValueResponse.error("Expected ExpressionResultColumn $column", element);
        }

        final functionResult = _expressionConverterUtil.parseExpression(
          column.expression,
          element,
          parameters: parameters,
          selector: tableSelector,
        );

        switch (functionResult) {
          case ValueData<(String, EExpressionType)>():
            break;
          case ValueError<(String, EExpressionType)>():
            return functionResult.wrap();
        }

        if (selectOnlyFunctionResult.isNotEmpty) {
          selectOnlyFunctionResult += ", ${functionResult.data.$1}";
        } else {
          selectOnlyFunctionResult = functionResult.data.$1;
        }
      }

      // query in view always uses select and addColumns isn't needed

      if (isView) {
        result = "select([$selectOnlyFunctionResult])";
      } else {
        result =
            "(selectOnly(${tableSelector is TableSelectorBaseDao ? BaseDaoGenerator.tableSelector : tableSelector.selector}${statement.distinct ? ", distinct: true" : ""})"
            "..addColumns([$selectOnlyFunctionResult])";
      }
    } else {
      result = "(select(${tableSelector.selector}${statement.distinct ? ", distinct: true" : ""})";
    }

    return ValueResponse.value((result, selectOnlyFunctionResult));
  }

  ValueResponse<String> addFromClause(
    Queryable? statementFrom,
    Element element,
    TableSelector tableSelector,
    List<ParameterElement> parameters,
    bool isView,
  ) {
    if (statementFrom == null) {
      return ValueError("From clause is expected to be not null", element);
    }

    return switch (statementFrom) {
      TableReference() => ValueResponse.value(("")),
      JoinClause() => _getCodeForJoinClause(statementFrom, element, tableSelector, parameters, isView: isView),
      Queryable() => ValueResponse.error(
        "Only table select and jooin statements are supported $statementFrom",
        element,
      ),
    };
  }

  ValueResponse<List<String>> getTablesForFromClause(Queryable? statementFrom, Element element) {
    if (statementFrom == null) {
      return ValueError("From clause is expected to be not null", element);
    }

    return switch (statementFrom) {
      TableReference() => ValueResponse.value(([statementFrom.tableName])),
      JoinClause() => _getTableNameInJoinClause(statementFrom, element),
      Queryable() => ValueResponse.error(
        "Only table select and jooin statements are supported $statementFrom",
        element,
      ),
    };
  }

  ValueResponse<List<String>> _getTableNameInJoinClause(JoinClause joinClause, Element element) {
    final tableNames = <String>[];

    final primary = joinClause.primary;

    if (primary is! TableReference) {
      return ValueResponse.error("Only TableReference is supported in join $primary", element);
    }

    tableNames.add(primary.tableName);

    for (final join in joinClause.joins) {
      final joinQuery = join.query;

      if (joinQuery is! TableReference) {
        return ValueResponse.error("Only TableReference is supported in join $join", element);
      }

      final joinedTableName = joinQuery.tableName;

      tableNames.add(joinedTableName);
    }
    return ValueResponse.value(tableNames);
  }

  ValueResponse<String> _getCodeForJoinClause(
    JoinClause joinClause,
    Element element,
    TableSelector tableSelector,
    List<ParameterElement> parameters, {
    bool isView = false,
  }) {
    final primary = joinClause.primary;

    if (primary is! TableReference) {
      return ValueResponse.error("Only TableReference is supported in join $primary", element);
    }

    var joinCode = "";

    if (isView) {
      final primaryClassState = tableSelector.getClassStateForTable(primary.tableName);

      if (primaryClassState == null) {
        return ValueResponse.error("Couldn't determine class for primary table in join ${primary.tableName}", element);
      }

      joinCode += ".from(${primaryClassState.driftTableGetter})";
    }

    joinCode += ".join([";

    for (final join in joinClause.joins) {
      final joinQuery = join.query;

      if (joinQuery is! TableReference) {
        return ValueResponse.error("Only TableReference is supported in join $join", element);
      }

      final joinedTableName = joinQuery.tableName;

      final methodNameResult = _getJoinOperatorName(join.operator, element);

      switch (methodNameResult) {
        case ValueError<String>():
          return methodNameResult.wrap();
        case ValueData<String>():
      }

      final methodName = methodNameResult.data;

      final onClauseResult = _getJoinOnClause(join.constraint, element, parameters, tableSelector);

      switch (onClauseResult) {
        case ValueError<String>():
          return onClauseResult.wrap();
        case ValueData<String>():
      }

      final onClause = onClauseResult.data;

      final joinedClassState = tableSelector.getClassStateForTable(joinedTableName);

      // for (final state in tableSelector.currentClassStates) {
      //   if (state.sqlTablename != joinedTableName) {
      //     continue;
      //   }
      //
      //   realTableName = state.driftTableGetter;
      // }

      if (joinedClassState == null) {
        return ValueResponse.error("Couldn't determine entity name for table $joinedTableName", element);
      }

      // TODO joinedTableName is wrong. I need the class name. Therefore the correct classState for the table needs to be found.
      joinCode += "$methodName(${joinedClassState.driftTableGetter}$onClause)";
    }

    joinCode += "])";

    return ValueResponse.value((joinCode));
  }

  ValueResponse<String> _getJoinOnClause(
    JoinConstraint? constraint,
    Element element,
    List<ParameterElement> parameters,
    TableSelector tableSelector,
  ) {
    if (constraint == null) {
      return ValueResponse.value("");
    }

    if (constraint is! OnConstraint) {
      return ValueResponse.error("Only OnConstraint are supported in join", element);
    }

    tableSelector.useSelector = true;

    final expressionResult = _expressionConverterUtil.parseExpression(
      constraint.expression,
      element,
      parameters: parameters,
      selector: tableSelector,
      asExpression: true,
    );

    tableSelector.useSelector = false;

    switch (expressionResult) {
      case ValueError<(String, EExpressionType)>():
        return expressionResult.wrap();
      case ValueData<(String, EExpressionType)>():
    }

    return ValueResponse.value(", ${expressionResult.data.$1}");
  }

  ValueResponse<String> _getJoinOperatorName(JoinOperator operator, Element element) {
    if (operator.outer) {
      if (operator.operator != JoinOperatorKind.left) {
        return ValueResponse.error("Only left outer join is currently supported $operator", element);
      }
    }

    if (operator.natural) {
      return ValueResponse.error("Natural join is not supported", element);
    }

    return switch (operator.operator) {
      JoinOperatorKind.none || JoinOperatorKind.comma || JoinOperatorKind.inner => ValueResponse.value("innerJoin"),
      JoinOperatorKind.cross => ValueResponse.value("crossJoin"),
      JoinOperatorKind.left => ValueResponse.error("Left inner join is not supported", element),
      JoinOperatorKind.right => ValueResponse.error("Right inner join is not supported", element),
      JoinOperatorKind.full => ValueResponse.error("Full inner join is not supported", element),
    };
  }
}
