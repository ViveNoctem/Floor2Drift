import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/sql/expression_converter/expression_converter.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:source_span/source_span.dart' show FileSpan;
import 'package:sqlparser/sqlparser.dart';
import 'package:test/test.dart';

import '../mocks/mock_function_parameters.dart';
import '../mocks/mock_literal.dart';
import 'expression_converter_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Element>(),
  MockSpec<FileSpan>(),
  MockSpec<ParameterElement>(),
  MockSpec<EnumElement>(),
  MockSpec<DartType>(),
  MockSpec<ExpressionConverterUtil>(),
])
void main() {
  late Element mockElement;
  late TableSelector selector;
  late List<ParameterElement> mockParameters;
  late MockParameterElement mockParameter;
  late Element mockParameterElement;
  late MockExpressionConverterUtil mockExpressionConverterUtil;
  late MockDartType mockParameterType;
  const String mockParameterName = "test";
  const String mockParameterTypeName = "temp";

  setUp(() {
    mockElement = MockElement();

    selector = TableSelectorDao([], {}, selector: "s");

    mockParameter = MockParameterElement();
    mockParameterElement = MockElement();
    mockParameterType = MockDartType();

    mockExpressionConverterUtil = MockExpressionConverterUtil();

    mockParameters = [mockParameter];

    when(mockParameter.name).thenReturn(mockParameterName);
    when(mockParameter.type).thenReturn(mockParameterType);
    when(mockParameterType.element).thenReturn(mockParameterElement);
    when(mockParameterElement.name).thenReturn(mockParameterTypeName);
  });

  group("ColonNamedVariable", () {
    test(("default"), () {
      final expression = ColonNamedVariable.synthetic(":test");

      final result = ColonNamedVariableExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("test"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test(("as expression"), () {
      final expression = ColonNamedVariable.synthetic(":test");

      final result = ColonNamedVariableExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(test)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test(("list as expression"), () {
      const String mockParameterTypeName = "List";
      when(mockParameterElement.name).thenReturn(mockParameterTypeName);

      final expression = ColonNamedVariable.synthetic(":test");

      final result = ColonNamedVariableExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "List not supported in ColonNamedVariable as Expression");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test(("list as expression"), () {
      const String mockParameterTypeName = "List";
      when(mockParameterElement.name).thenReturn(mockParameterTypeName);

      final expression = ColonNamedVariable.synthetic(":test");

      final result = ColonNamedVariableExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("...test"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test(("enum"), () {
      final expression = ColonNamedVariable.synthetic(":test");

      mockParameterElement = MockEnumElement();

      when(mockParameterType.element).thenReturn(mockParameterElement);
      when(mockParameterElement.name).thenReturn(mockParameterTypeName);

      final result = ColonNamedVariableExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("test.index"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test(("enum as expression"), () {
      final expression = ColonNamedVariable.synthetic(":test");

      mockParameterElement = MockEnumElement();

      when(mockParameterType.element).thenReturn(mockParameterElement);
      when(mockParameterElement.name).thenReturn(mockParameterTypeName);

      final result = ColonNamedVariableExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(test.index)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test(("parameter not found"), () {
      final expression = ColonNamedVariable.synthetic(":test2");

      final result = ColonNamedVariableExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "Parameter test2 can't be found in the mockParametert");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("reference", () {
    test("default", () {
      final expression = Reference(columnName: "test");

      final result = ReferenceExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("test"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("as Expression", () {
      final expression = Reference(columnName: "test");

      final result = ReferenceExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.test"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });
  });

  group("literal", () {
    test("NullLiteral", () {
      final expression = NullLiteral();

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      // TODO is null correct?
      // TODO when is a NullLiteral used?
      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("null"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("NumericLiteral Int", () {
      final expression = NumericLiteral(5);

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("5"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("NumericLiteral Float", () {
      final expression = NumericLiteral(7.5);

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("7.5"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("BooleanLiteral", () {
      final expression = BooleanLiteral(false);

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("false"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("BooleanLiteral as expression", () {
      final expression = BooleanLiteral(true);

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(true)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("StringLiteral", () {
      final expression = StringLiteral("testliteral");

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("\"testliteral\""));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("TimeConstantLiteral", () {
      final expression = TimeConstantLiteral(TimeConstantKind.currentTime);

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "TimeConstantLiteral is not supported");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("custom literal", () {
      final expression = MockLiteral("mockliteral");

      final result = LiteralExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "custom created literals are not supported");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("IS NOT NULL", () {
    test("reference", () {
      final reference = Reference(columnName: "test");
      final expression = IsNullExpression(reference, false);

      final result = IsNullExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("test.isNull()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("not null", () {
      final reference = Reference(columnName: "test");
      final expression = IsNullExpression(reference, true);

      final result = IsNullExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("test.isNotNull()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("negated only null", () {
      final reference = NullLiteral();
      final expression = IsNullExpression(reference, true);

      final result = IsNullExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("false"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("only null", () {
      final reference = NullLiteral();
      final expression = IsNullExpression(reference, false);

      final result = IsNullExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("true"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("error parsing expression", () {
      final reference = MockLiteral("test");
      final expression = IsNullExpression(reference, true);

      final result = IsNullExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("IS", () {
    test("reference", () {
      final left = Reference(columnName: "test");
      final right = NumericLiteral(1);
      final expression = IsExpression(false, left, right);

      final result = IsExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("test.isValue(1)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("reference negated", () {
      final left = Reference(columnName: "test");
      final right = NumericLiteral(1);
      final expression = IsExpression(true, left, right);

      final result = IsExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("test.isNotValue(1)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("as expression", () {
      final left = Reference(columnName: "test");
      final right = StringLiteral("stringLiteral");
      final expression = IsExpression(false, left, right);

      final result = IsExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.test.isExp(Variable(\"stringLiteral\"))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("as expression negated", () {
      final left = Reference(columnName: "test");
      final right = StringLiteral("stringLiteral");
      final expression = IsExpression(true, left, right);

      final result = IsExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.test.isNotExp(Variable(\"stringLiteral\"))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("is null", () {
      final left = ColonNamedVariable.synthetic(":test");
      final right = NullLiteral();
      final expression = IsExpression(true, left, right);

      final result = IsExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(test).isNotNull()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("error while parsing right", () {
      final left = ColonNamedVariable.synthetic(":test");
      final right = MockLiteral("test");
      final expression = IsExpression(true, left, right);

      final result = IsExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing right expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("error while parsing right", () {
      final left = MockLiteral("test");
      final right = ColonNamedVariable.synthetic(":test");
      final expression = IsExpression(true, left, right);

      final result = IsExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing right expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("BETWEEN", () {
    test("default", () {
      final check = NumericLiteral(5);
      final lower = NumericLiteral(8);
      final upper = NumericLiteral(0.5);
      final expression = BetweenExpression(not: false, check: check, lower: lower, upper: upper);

      final result = BetweenExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(5).isBetweenValues(8, 0.5)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("negated", () {
      final check = NumericLiteral(5);
      final lower = NumericLiteral(8);
      final upper = NumericLiteral(0.5);
      final expression = BetweenExpression(not: true, check: check, lower: lower, upper: upper);

      final result = BetweenExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(5).isBetweenValues(8, 0.5, not: true)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("as expression", () {
      final check = NumericLiteral(5);
      final lower = NumericLiteral(8);
      final upper = NumericLiteral(0.5);
      final expression = BetweenExpression(not: false, check: check, lower: lower, upper: upper);

      final result = BetweenExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(5).isBetween(Variable(8), Variable(0.5))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("as expression negated", () {
      final check = NumericLiteral(5);
      final lower = NumericLiteral(8);
      final upper = NumericLiteral(0.5);
      final expression = BetweenExpression(not: true, check: check, lower: lower, upper: upper);

      final result = BetweenExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(5).isBetween(Variable(8), Variable(0.5), not: true)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("parsing check expression failed", () {
      final check = MockLiteral(5);
      final lower = NumericLiteral(8);
      final upper = NumericLiteral(0.5);
      final expression = BetweenExpression(not: true, check: check, lower: lower, upper: upper);

      final result = BetweenExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing check expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("parsing left expression failed", () {
      final check = NumericLiteral(5);
      final lower = MockLiteral(8);
      final upper = NumericLiteral(0.5);
      final expression = BetweenExpression(not: true, check: check, lower: lower, upper: upper);

      final result = BetweenExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing lower expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("parsing check expression failed", () {
      final check = NumericLiteral(5);
      final lower = NumericLiteral(8);
      final upper = MockLiteral(0.5);
      final expression = BetweenExpression(not: true, check: check, lower: lower, upper: upper);

      final result = BetweenExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing upper expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("IN", () {
    test("reference in numeric", () {
      final left = Reference(columnName: "id");
      final inside = Tuple(expressions: [NumericLiteral(5), NumericLiteral(6)]);
      final expression = InExpression(left: left, inside: inside, not: false);

      final result = InExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.isIn([5, 6])"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("colonNamedVariable in numeric", () {
      final left = ColonNamedVariable.synthetic(":test");
      final inside = Tuple(expressions: [NumericLiteral(9.9), NumericLiteral(28)]);
      final expression = InExpression(left: left, inside: inside, not: false);

      final result = InExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(test).isIn([9.9, 28])"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("colonNamedVariable in numeric", () {
      final left = Reference(columnName: "id");
      final inside = Tuple(expressions: [ColonNamedVariable.synthetic(":test"), NumericLiteral(28)]);
      final expression = InExpression(left: left, inside: inside, not: false);

      final result = InExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.isIn([test, 28])"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("negated", () {
      final left = ColonNamedVariable.synthetic(":test");
      final inside = Tuple(expressions: [NumericLiteral(99), NumericLiteral(5)]);
      final expression = InExpression(left: left, inside: inside, not: true);

      final result = InExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(test).isNotIn([99, 5])"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("error while parsing left expression", () {
      final left = MockLiteral("temp");
      final inside = Tuple(expressions: [NumericLiteral(99), NumericLiteral(5)]);
      final expression = InExpression(left: left, inside: inside, not: true);

      final result = InExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing left expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("error while parsing inside expression", () {
      final left = ColonNamedVariable.synthetic(":test");
      final inside = Tuple(expressions: [MockLiteral("temp")]);
      final expression = InExpression(left: left, inside: inside, not: true);

      final result = InExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing inside expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("parentheses", () {
    test("String like String", () {
      final left = StringLiteral("temp");
      final right = StringLiteral("%test%");

      final inside = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );
      final expression = Parentheses(inside);

      final result = ParenthesesExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("(Variable(\"temp\").like(\"%test%\"))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("error parsing inside expression", () {
      final inside = MockLiteral("temp");
      final expression = Parentheses(inside);

      final result = ParenthesesExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing inside expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("LIKE", () {
    test("reference like String", () {
      final left = Reference(columnName: "id");
      final right = StringLiteral("%test%");

      final expression = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );

      final result = StringComparisonExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.like(\"%test%\")"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("reference like String as expression", () {
      final left = Reference(columnName: "id");
      final right = StringLiteral("%test%");

      final expression = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );

      final result = StringComparisonExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.likeExp(Variable(\"%test%\"))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("reference like colonNamedVariable", () {
      final left = Reference(columnName: "id");
      final right = ColonNamedVariable.synthetic(":test");

      final expression = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );
      final result = StringComparisonExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.like(test)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("reference like colonNamedVariable as expression", () {
      final left = Reference(columnName: "id");
      final right = ColonNamedVariable.synthetic(":test");

      final expression = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );

      final result = StringComparisonExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.likeExp(Variable(test))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("reference like colonNamedVariable as expression", () {
      final left = Reference(columnName: "id");
      final right = ColonNamedVariable.synthetic(":test");

      final expression = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );

      final result = StringComparisonExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.likeExp(Variable(test))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("error parsing left expression", () {
      final left = MockLiteral("temp");
      final right = ColonNamedVariable.synthetic(":test");

      final expression = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );

      final result = StringComparisonExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing left expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("error parsing right expression", () {
      final left = Reference(columnName: "id");
      final right = MockLiteral("test");

      final expression = StringComparisonExpression(
        left: left,
        operator: Token(TokenType.like, MockFileSpan()),
        right: right,
      );

      final result = StringComparisonExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing right expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("function", () {
    test("count id", () {
      // final parameters = StarFunctionParameter();
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")], distinct: false);
      final name = "COUNT";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.count()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("count id distinct", () {
      // final parameters = StarFunctionParameter();
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")], distinct: true);
      final name = "COUNT";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.count(distinct: true)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("count *", () {
      final parameters = StarFunctionParameter();
      final name = "COUNT";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("countAll()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("avg test", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")]);
      final name = "AVG";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.avg()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("sum test", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")]);
      final name = "SUM";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.sum()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("max test", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")]);
      final name = "MAX";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.max()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("min test", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")]);
      final name = "MIN";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.min()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("total test", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")]);
      final name = "TOTAL";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.total()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("groupConcat without separator", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")]);
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.groupConcat()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("stringAgg without separator", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")]);
      final name = "string_agg";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.groupConcat()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("groupConcat with separator", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id"), StringLiteral(",")]);
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.groupConcat(separator: \",\")"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("groupConcat distinct without separator", () {
      final parameters = ExprFunctionParameters(parameters: [Reference(columnName: "id")], distinct: true);
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.groupConcat(distinct: true)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("groupConcat distinct with separator", () {
      final parameters = ExprFunctionParameters(
        parameters: [Reference(columnName: "id"), StringLiteral(",")],
        distinct: true,
      );
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.groupConcat(distinct: true, separator: \",\")"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("error parsing inside expression", () {
      final parameters = ExprFunctionParameters(parameters: [MockLiteral("id"), StringLiteral(",")], distinct: true);
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing inside expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("error parsing separator expression", () {
      final parameters = ExprFunctionParameters(
        parameters: [Reference(columnName: "id"), MockLiteral(",")],
        distinct: true,
      );
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing separator expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("error parsing function name", () {
      final parameters = ExprFunctionParameters(
        parameters: [Reference(columnName: "id"), MockLiteral(",")],
        distinct: true,
      );
      final name = "temp";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing function name expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("StarFunctionParameter only supported for count", () {
      final parameters = StarFunctionParameter();
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "StarFunctionParameter only supported for count expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("first parameter required for ExprFunctionParameter", () {
      final parameters = ExprFunctionParameters();
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "first parameter required for ExprFunctionParameter");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("doesn't suppport MockFunctionParameter", () {
      final parameters = MockFunctionParameters();
      final name = "group_concat";
      final expression = FunctionExpression(name: name, parameters: parameters);

      final result = FunctionExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "v");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });

  group("binary expression", () {
    test("reference equal reference", () {
      Expression left = Reference(columnName: "id");
      Token operator = Token(TokenType.equal, MockFileSpan());
      Expression right = Reference(columnName: "test");

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.equals(test)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("reference equal reference as expression", () {
      Expression left = Reference(columnName: "id");
      Token operator = Token(TokenType.equal, MockFileSpan());
      Expression right = Reference(columnName: "test");

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("s.id.equalsExp(s.test)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("literal equal literal", () {
      Expression left = StringLiteral("id");
      Token operator = Token(TokenType.equal, MockFileSpan());
      Expression right = StringLiteral("test");

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(\"id\").equals(\"test\")"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("literal equal literal as expression", () {
      Expression left = StringLiteral("id");
      Token operator = Token(TokenType.equal, MockFileSpan());
      Expression right = StringLiteral("test");

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(\"id\").equalsExp(Variable(\"test\"))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("colonNamedReference equal colonNamedReference", () {
      Expression left = ColonNamedVariable.synthetic(":test");
      Token operator = Token(TokenType.equal, MockFileSpan());
      Expression right = ColonNamedVariable.synthetic(":test");

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(test).equals(test)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("colonNamedReference equal colonNamedReference as expression", () {
      Expression left = ColonNamedVariable.synthetic(":test");
      Token operator = Token(TokenType.equal, MockFileSpan());
      Expression right = ColonNamedVariable.synthetic(":test");

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(test).equalsExp(Variable(test))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("less", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.less, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isSmallerThanValue(2)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("less as expression", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.less, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isSmallerThan(Variable(2))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("lessEqual", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.lessEqual, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isSmallerOrEqualValue(2)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("lessEqual as expression", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.lessEqual, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isSmallerOrEqual(Variable(2))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("more", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.more, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isBiggerThanValue(2)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("more as expression", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.more, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isBiggerThan(Variable(2))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("moreEqual", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.moreEqual, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isBiggerOrEqualValue(2)"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("moreEqual as expression", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.moreEqual, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).isBiggerOrEqual(Variable(2))"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("exclamationEqual", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.exclamationEqual, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).equals(2).not()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("exclamationEqual as expression", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.exclamationEqual, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).equalsExp(Variable(2)).not()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("lessMore", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.lessMore, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).equals(2).not()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("lessMore as expression", () {
      Expression left = NumericLiteral(1);
      Token operator = Token(TokenType.lessMore, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(result.data.$1, equals("Variable(1).equalsExp(Variable(2)).not()"));
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("and", () {
      Expression left = BinaryExpression(NumericLiteral(1), Token(TokenType.equal, MockFileSpan()), NumericLiteral(5));
      Token operator = Token(TokenType.and, MockFileSpan());
      Expression right = BinaryExpression(
        NumericLiteral(8),
        Token(TokenType.lessEqual, MockFileSpan()),
        NumericLiteral(55),
      );

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(
            result.data.$1,
            equals("Variable(1).equalsExp(Variable(5)) & Variable(8).isSmallerOrEqual(Variable(55))"),
          );
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("or", () {
      Expression left = BinaryExpression(NumericLiteral(1), Token(TokenType.equal, MockFileSpan()), NumericLiteral(5));
      Token operator = Token(TokenType.or, MockFileSpan());
      Expression right = BinaryExpression(
        NumericLiteral(8),
        Token(TokenType.lessEqual, MockFileSpan()),
        NumericLiteral(55),
      );

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: true,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(
            result.data.$1,
            equals("Variable(1).equalsExp(Variable(5)) | Variable(8).isSmallerOrEqual(Variable(55))"),
          );
        case ValueError<(String, EExpressionType)>():
          expect(false, isTrue, reason: result.error);
      }
    });

    test("error parsing left expression", () {
      Expression left = MockLiteral(1);
      Token operator = Token(TokenType.moreEqual, MockFileSpan());
      Expression right = NumericLiteral(2);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing left expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("error parsing right expression", () {
      Expression left = NumericLiteral(2);
      Token operator = Token(TokenType.moreEqual, MockFileSpan());
      Expression right = MockLiteral(1);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing right expression expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });

    test("error parsing token", () {
      Expression left = NumericLiteral(2);
      Token operator = Token(TokenType.into, MockFileSpan());
      Expression right = NumericLiteral(1);

      final expression = BinaryExpression(left, operator, right);

      final result = BinaryExpressionConverter().parse(
        expression,
        mockElement,
        asExpression: false,
        parameters: mockParameters,
        selector: selector,
      );

      switch (result) {
        case ValueData<(String, EExpressionType)>():
          expect(false, isTrue, reason: "error parsing token expected");
        case ValueError<(String, EExpressionType)>():
          break;
      }
    });
  });
}
