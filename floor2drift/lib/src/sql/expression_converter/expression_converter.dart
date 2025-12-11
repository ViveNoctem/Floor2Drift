import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/entity/annotation_converter/classState.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/sql_helper.dart';
import 'package:floor2drift/src/sql/statement_converter/statement_converter.dart';
import 'package:floor2drift/src/sql/token_converter/token_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:sqlparser/sqlparser.dart';

part 'between_expression_converter.dart';
part 'binary_expression_converter.dart';
part 'collate_expression_converter.dart';
part 'colon_named_variable_expression_converter.dart';
part 'function_expression_converter.dart';
part 'in_expression_converter.dart';
part 'is_expression_converter.dart';
part 'is_null_expression_converter.dart';
part 'literal_expression_converter.dart';
part 'parentheses_expression_converter.dart';
part 'reference_expression_converter.dart';
part 'string_comparison_expression_converter.dart';
part 'sub_query_expression_converter.dart';
part 'tuple_expression_converter.dart';
part 'unary_expression_converter.dart';

class ExpressionConverterUtil {
  const ExpressionConverterUtil();

  ValueResponse<(String, EExpressionType)> parseExpression(
    Expression expression,
    Element element, {
    bool asExpression = true,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  }) {
    // TODO find a way to remove the EExpressionType
    return switch (expression) {
      BinaryExpression() => const BinaryExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      Parentheses() => const ParenthesesExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      Reference() => const ReferenceExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      ColonNamedVariable() => const ColonNamedVariableExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      // StringComparisonExpression() => "", // LIKE
      IsExpression() => const IsExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      IsNullExpression() => const IsNullExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      BetweenExpression() => const BetweenExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      InExpression() => const InExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      Tuple() => const TupleExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      Literal() => const LiteralExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      StringComparisonExpression() => const StringComparisonExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      FunctionExpression() => const FunctionExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      SubQuery() => const SubQueryExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      // CollateExpression must come before UnaryExpression because it extends it
      CollateExpression() => const CollateExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      UnaryExpression() => const UnaryExpressionConverter().parse(
          expression,
          element,
          asExpression: asExpression,
          parameters: parameters,
          selector: selector,
        ),
      // NumberedVariable() => "",
      _ => ValueResponse.error("Expression $expression is not supported", element),
    };
  }
}

sealed class ExpressionConverter<T extends Expression> {
  const ExpressionConverter();

  ///
  /// if [asExpression] is true [Reference] adds a selector in front and
  /// [ColonNamedVariable] wraps the variable in a [Variable] Object
  ValueResponse<(String, EExpressionType)> parse(
    T expression,
    Element element, {
    required bool asExpression,
    required List<ParameterElement> parameters,
    required TableSelector selector,
  });
}
