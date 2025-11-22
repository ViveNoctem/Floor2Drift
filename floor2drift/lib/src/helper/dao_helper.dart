import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/dao_method/dao_method_converter.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/value_response.dart';

class DaoHelper {
  const DaoHelper();

  ValueResponse<({String body, Set<String> usedTabled})> generateClassBody(
    ClassElement classElement,
    String classNameSuffix,
    TableSelector tableSelector,
  ) {
    var body = "";
    final usedTable = <String>{};

    for (final method in classElement.methods) {
      final result = DaoMethodConverter.parseMethod(method, tableSelector);

      switch (result) {
        case ValueData<(String, String)>():
          break;
        case ValueError<(String, String)>():
          return result.wrap();
      }

      final (methodString, table) = result.data;

      if (methodString.isEmpty) {
        continue;
      }

      if (table.isNotEmpty) {
        usedTable.add(table);
      }

      body += "$methodString\n\n";
    }

    ({String body, Set<String> usedTabled}) result = (body: body, usedTabled: usedTable);

    if (result.body.isEmpty) {
      return ValueResponse.error("No Methods found in class", classElement);
    }

    return ValueResponse.value(result);
  }
}
