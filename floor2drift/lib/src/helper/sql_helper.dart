import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
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

  ValueResponse<String> addOrderByClause(
    OrderBy orderBy,
    Element element,
    List<ParameterElement> parameters,
    TableSelector selector,
  ) {
    var result = "..orderBy([";

    final orderingTermns = <String>[];

    for (final orderingTerm in orderBy.terms) {
      if (orderingTerm is! OrderingTerm) {
        return ValueResponse.error("Order by termin $orderingTerm is not a OrderingTerm", element);
      }

      final orderingTermResult = _addOrderingTerm(orderingTerm, selector, element, parameters);

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
  ) {
    final mode = _getOrderingMode(orderingTerm.orderingMode);

    final expressionResult = expressionConverterUtil.parseExpression(
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

    var result = "(${selector.functionSelector}) => OrderingTerm($expression$mode$nulls)";
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
    Element element,
    List<ParameterElement> parameters,
    bool useTableSelector,
    TableSelector selector,
  ) {
    var result = "..where(";
    if (useTableSelector == false) {
      result += "(${selector.functionSelector}) => ";
    }

    final whereResult = expressionConverterUtil.parseExpression(
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

  /// checks if the given entityName in the [selector] has a typeConverter
  ///
  /// if true returns code to convert the give [argumentName] with the correct typeConverter
  /// if false returns an empty string
  String checkTypeConverter(TableSelector selector, String argumentName) {
    if (selector.convertedFields[selector.entityName] == null) {
      return "";
    }
    for (final entry in selector.convertedFields[selector.entityName]!) {
      if (selector.currentFieldName != entry) {
        continue;
      }

      return "${selector.selector}.${selector.currentFieldName}.converter.toSql($argumentName)";
    }
    return "";
  }

  /// returns if the given [type] is a sql native type
  ///
  /// Stream, Future, and List are being unwrapped and the result for the type argument is retunred
  /// TODO is used to determine if the typeConverter should be used or not
  /// TODO doesn't work with string to string converter.
  /// TODO The to and from type of the converter is needed to better determine if the converter should be used or not
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

    if (localType.isDartCoreInt || localType.isDartCoreBool || localType.isDartCoreString) {
      return true;
    }

    return false;
  }
}
