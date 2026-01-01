part of 'dao_method_converter.dart';

/// {@template InsertMethodConverter}
/// Generates dart code for floor methods annotated with [Insert]
/// {@endtemplate}
class InsertMethodConverter extends DaoMethodConverter {
  /// {@macro InsertMethodConverter}
  const InsertMethodConverter();

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

    final result = """$methodHeader
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

    final insertMode = _getInsertMode(insertAnnotation);

    ValueResponse<String> quantityResult = switch (parameterType.type) {
      EType.unknown => ValueResponse.value("await $tableName.insertOne($insertMode$argumentName);"),
      // EType.list => ValueResponse.value("await $tableName.insertAll($insertMode$argumentName);"),
      EType.list => ValueResponse.value(''' final list = <int>[];
    await transaction(() async {
    for (final item in $argumentName) {
      list.add(await $tableName.insertOne(${insertMode}item));
    }
    });
    '''),
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
        return ValueResponse.value("return $quantity");
      case EType.list:
        return ValueResponse.value("$quantity\nreturn list;");
      default:
        return ValueResponse.error("Expected object void or list as Return Type", parameter);
    }
  }

  String _getInsertMode(DartObject insertAnnotation) {
    ConstantReader reader = ConstantReader(insertAnnotation);

    final onConflictField = reader.read("onConflict");
    final conflictName = onConflictField.objectValue.variable?.name;

    return switch (conflictName) {
      "replace" => "mode: InsertMode.replace, ",
      "rollback" => "mode: InsertMode.insertOrRollback, ",
      "fail" => "mode: InsertMode.insertOrFail, ",
      "ignore" => "mode: InsertMode.insertOrIgnore, ",
      "abort" || _ => "",
    };
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

/*
  Future<List<int>> annotationInsertTasks(List<TestTask> taskList) async {
    final temp = <int>[];
    await transaction(() async {
      for (final task in taskList) {
        temp.add(await testTasks.insertOne(task));
      }
    });
    return temp;
  }
 */
