part of 'dao_method_converter.dart';

/// {@template DeleteMethodConverter}
/// Generates dart code for floor methods annotated with [delete]
/// {@endtemplate}
class DeleteMethodConverter extends DaoMethodConverter {
  /// {@macro DeleteMethodConverter}
  const DeleteMethodConverter();

  @override
  ValueResponse<String> _parse(
    MethodElement method,
    DartObject insertAnnotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    if (method.parameters.isEmpty || method.parameters.length > 1) {
      return ValueResponse.error("expected method to have excactly one parameter", method);
    }

    final parameter = method.parameters.first;

    final parameterType = const BaseHelper().getTypeSpecification(parameter.type);
    final returnType = const BaseHelper().getTypeSpecification(method.returnType);
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

    final methodBodyResult = _getMethodBody(tableSelector, parameter, parameterType, returnType, insertAnnotation);

    switch (methodBodyResult) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return methodBodyResult.wrap();
    }

    final methodBody = methodBodyResult.data;

    final result =
        """$methodHeader
    $methodBody
    }""";

    return ValueResponse.value(result);
  }

  ValueResponse<String> _getMethodBody(
    TableSelector tableSelector,
    ParameterElement parameter,
    TypeSpecification parameterType,
    TypeSpecification returnType,
    DartObject insertAnnotation,
  ) {
    final tableNameResult = getTableName(tableSelector, parameter, parameterType);

    switch (tableNameResult) {
      case ValueData<String>():
        break;
      case ValueError<String>():
        return tableNameResult.wrap();
    }

    final tableName = tableNameResult.data;
    final argumentName = parameter.name;

    ValueResponse<String> quantityResult = switch (parameterType.type) {
      EType.unknown => ValueResponse.value("await delete($tableName).delete($argumentName);"),
      // EType.list => ValueResponse.value("""await batch((batch) {
      //     for (final entry in $argumentName) {
      //       batch.delete($tableName, entry);
      //     }
      //   });"""),
      EType.list => ValueResponse.value("""var deletedRows = 0;
    await transaction(() async {
      for (final item in $argumentName) {
        deletedRows += await delete($tableName).delete(item);
      }
    });
    """),
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
          return ValueResponse.value("return $quantity");
        }
        return ValueResponse.value("$quantity\nreturn deletedRows;");
      default:
        return ValueResponse.error("Expected object void or int as Return Type", parameter);
    }
  }

  @override
  ValueResponse<List<String>> parseUsedTable(
    MethodElement method,
    DartObject annotation,
    TableSelector tableSelector,
    DatabaseState dbState,
  ) {
    return const DaoHelper().parseUsedTableAnnotation(method, annotation, tableSelector, dbState);
  }
}
