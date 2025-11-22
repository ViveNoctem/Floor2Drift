import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/dao_method/dao_method_converter.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/helper/sql_helper.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/sql/statement_converter/statement_converter.dart';
import 'package:floor2drift/src/value_response.dart';

class QueryMethodConverter extends DaoMethodConverter {
  const QueryMethodConverter();
  ValueResponse<(String, String)> parse(MethodElement method, DartObject queryAnnotation, TableSelector tableSelector) {
    var body = "";
    var usedTable = "";

    final returnType = BaseHelper.getTypeSpecification(method.returnType);

    var singleMethod = "";
    bool found = false;

    final data = _handleQueryAnnotation(method, queryAnnotation, tableSelector);

    switch (data) {
      case ValueData<(String, String)>():
        break;

      case ValueError<(String, String)>():
        return data.wrap();
    }

    // TODO find better way to cut methods than check isEmpty
    if (data.data.$1.isEmpty) {
      return ValueResponse.value(("", ""));
    }

    final (metaDataResult, table) = data.data;
    found = true;
    singleMethod += "$metaDataResult\n";
    // TODO usedTables are here but are needed in tableSelector
    usedTable = table;

    // add method if a query annotation has been found
    if (found) {
      body += _generateMethodHeader(returnType, method, "");
      body += singleMethod;
      body += "}\n\n";
    }

    return ValueResponse.value((body, usedTable));
  }

  ValueResponse<(String, String)> _handleQueryAnnotation(
    MethodElement method,
    DartObject metaData,
    TableSelector tableSelector,
  ) {
    final query = metaData.getField("value")?.toStringValue();
    if (query == null) {
      return ValueResponse.error("@Query value is null", method);
    }

    final parseResult = SqlHelper.sqlEngine.parse(query);
    if (parseResult.errors.isNotEmpty) {
      return ValueResponse.error("encountered problem while parsing $query\n ${parseResult.errors}", method);
    }

    final rootNode = parseResult.rootNode;
    return StatementConverter.parseStatement(rootNode, method, tableSelector);
  }

  String _generateMethodHeader(TypeSpecification returnType, MethodElement method, String classNameSuffix) {
    var newClassName = "";
    var oldClassName = "";
    if (classNameSuffix.isNotEmpty) {
      final returnTypeString = method.returnType.getDisplayString(withNullability: false);
      var end = returnTypeString.indexOf(">");

      final start = returnTypeString.lastIndexOf("<") + 1;
      final type = returnTypeString.substring(start, end);

      // TODO do not add the suffix to enum
      var isEnum = _checkIfEnum(returnType, method);

      oldClassName = type;
      newClassName = "$type$classNameSuffix";
      const knownType = ["int", "String", "DateTime", "double", "void", "Uint8List", "bool"];
      if (isEnum || knownType.contains(oldClassName)) {
        oldClassName = "";
        newClassName = "";
      }
    }

    var result = method.getDisplayString(withNullability: true, multiline: true);

    if (newClassName.isNotEmpty) {
      result = result.replaceFirst(oldClassName, newClassName);
    }

    result += " {\n";

    return result;
  }

  bool _checkIfEnum(TypeSpecification returnType, MethodElement method) {
    var methodReturnType = method.returnType;

    if (methodReturnType is! InterfaceType) {
      return false;
    }

    var typeArgument = methodReturnType.typeArguments.firstOrNull;

    if (returnType.firstTypeArgument == EType.list) {
      if (typeArgument is! InterfaceType) {
        return false;
      }
      typeArgument = typeArgument.typeArguments.firstOrNull;
    }

    return typeArgument?.element is EnumElement;
  }
}
