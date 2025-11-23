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

    // TODO support type converters
    // TODO need list of all fields in the current table/tables that has a typeConverter
    // TODO if it has a type converter add s.tablename.converter.toSql(value)

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
