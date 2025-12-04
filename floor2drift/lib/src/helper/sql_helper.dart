import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/sql/expression_converter/expression_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:sqlparser/sqlparser.dart';

/// Helper Class to Convert Sql Code to Drift Core Api Calls
class SqlHelper {
  final ExpressionConverterUtil expressionConverterUtil;

  const SqlHelper({this.expressionConverterUtil = const ExpressionConverterUtil()});

  static final sqlEngine = SqlEngine();

  static const selectorName = "s";

  ValueResponse<String> addOrderByClause(OrderBy orderBy, MethodElement method, TableSelector selector) {
    var result = "..orderBy([";

    final orderingTermns = <String>[];

    for (final orderingTerm in orderBy.terms) {
      if (orderingTerm is! OrderingTerm) {
        return ValueResponse.error("Order by termin $orderingTerm is not a OrderingTerm", method);
      }

      final orderingTermResult = _addOrderingTerm(orderingTerm, selector, method);

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

  ValueResponse<String> _addOrderingTerm(OrderingTerm orderingTerm, TableSelector selector, MethodElement method) {
    final mode = _getOrderingMode(orderingTerm.orderingMode);

    final expressionResult = expressionConverterUtil.parseExpression(
      orderingTerm.expression,
      method,
      parameters: method.parameters,
      selector: selector,
    );

    switch (expressionResult) {
      case ValueError<(String, EExpressionType)>():
        return expressionResult.wrap();
      case ValueData<(String, EExpressionType)>():
    }

    final expression = "expression: ${expressionResult.data.$1}";

    final nulls = _getNulls(orderingTerm.nulls);

    var result = "(${selector.selector}) => OrderingTerm($expression$mode$nulls)";
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

  ValueResponse<String> addWhereClause(
    Expression whereExpression,
    MethodElement method,
    bool useTableSelector,
    TableSelector selector,
  ) {
    var result = "..where(";
    if (useTableSelector == false) {
      result += "($selector) => ";
    }

    final whereResult = expressionConverterUtil.parseExpression(
      whereExpression,
      method,
      parameters: method.parameters,
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

  String getGetter(TypeSpecification returnType) {
    var getterMethod = ".";

    switch (returnType.type) {
      case EType.future:
        switch (returnType.firstTypeArgument) {
          case EType.unknown:
            // getterMethod += returnType.nullable ? "getSingleOrNull" : "getSingle";
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
            // getterMethod += returnType.nullable ? "watchSingleOrNull" : "watchSingleOrNull";
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
}
