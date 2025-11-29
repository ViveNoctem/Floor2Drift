import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/base_classes/database_state.dart';
import 'package:floor2drift/src/dao_method/dao_method_converter.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/annotation_helper.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:floor2drift/src/return_type.dart';
import 'package:floor2drift/src/value_response.dart';

import '../helper/dao_helper.dart';

class UpdateMethodConverter extends DaoMethodConverter {
  final AnnotationHelper annotationHelper;

  const UpdateMethodConverter({this.annotationHelper = const AnnotationHelper()});
  @override
  ValueResponse<(String, String)> parse(
    MethodElement method,
    DartObject insertAnnotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    if (method.parameters.isEmpty || method.parameters.length > 1) {
      return ValueResponse.error("expected method to have excactly one parameter", method);
    }

    final parameter = method.parameters.first;

    final parameterType = BaseHelper.getTypeSpecification(parameter.type);
    final returnType = BaseHelper.getTypeSpecification(method.returnType);
    // only future supported for @insert
    switch (returnType.type) {
      case EType.future:
        break;

      default:
        return ValueResponse.error("Future return type expected for  @insert", method);
    }

    final methodHeaderResult = getMethodHeader(method);

    switch (methodHeaderResult) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return methodHeaderResult.wrap();
    }

    final methodHeader = methodHeaderResult.data;

    final methodBodyResult = _getMethodBody(tableSelector, parameter, parameterType, returnType);

    switch (methodBodyResult) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return methodBodyResult.wrap();
    }

    final methodBody = methodBodyResult.data;

    final result = """$methodHeader
    $methodBody
    }""";

    return ValueResponse.value((result, ""));
  }

  ValueResponse<String> _getMethodBody(
    TableSelector tableSelector,
    ParameterElement parameter,
    TypeSpecification parameterType,
    TypeSpecification returnType,
  ) {
    final tableNameResult = getTableName(tableSelector, parameter, parameterType);

    switch (tableNameResult) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return tableNameResult.wrap();
    }

    final tableName = tableNameResult.data;

    final argumentNameResult = getArgumentName(parameter);

    switch (argumentNameResult) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return argumentNameResult.wrap();
    }

    final argumentName = argumentNameResult.data;

    ValueResponse<String> quantityResult = switch (parameterType.type) {
      EType.unknown => ValueResponse.value("await update($tableName).replace($argumentName);"),
      EType.list => ValueResponse.value("""await batch((batch) {
          batch.replaceAll($tableName, $argumentName);
        });"""),
      _ => ValueResponse.error("Parmeter type is not supported", parameter),
    };

    switch (quantityResult) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return quantityResult.wrap();
    }

    final quantity = quantityResult.data;

    switch (returnType.firstTypeArgument) {
      case EType.voidType:
        return ValueResponse.value(quantity);
      case EType.unknown:
        if (parameterType.type == EType.unknown) {
          return ValueResponse.value("$quantity\nreturn -1;");
        }
        return ValueResponse.value("$quantity\nreturn -1;");
      default:
        return ValueResponse.error("Expected object void or int as Return Type", parameter);
    }
  }

  @override
  ValueResponse<String> parseUsedTable(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    return const DaoHelper().parseUsedTableAnnotation(method, annotation, tableSelector, dbState);
  }
}
