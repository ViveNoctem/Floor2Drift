import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:floor2drift/src/enum/enums.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../flutter_test/mocks/mock_interface_type.dart';

void main() {
  late MockInterfaceType mockTypeArgument;
  setUp(() {
    mockTypeArgument = MockInterfaceType(
      nullabilitySuffix: NullabilitySuffix.none,
      isDartCoreList: false,
      isDartAsyncFuture: false,
      isDartAsyncStream: false,
      typeArguments: const [],
    );
  });

  group("Test mainType", () {
    late MockInterfaceType mockDartType;

    setUp(() {
      mockDartType = MockInterfaceType(
        nullabilitySuffix: NullabilitySuffix.none,
        isDartCoreList: false,
        isDartAsyncFuture: false,
        isDartAsyncStream: false,
        typeArguments: [mockTypeArgument],
      );
    });

    test("isDartCoreList", () {
      mockDartType.isDartCoreList = true;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.list));
    });

    test("isDartAsyncFuture", () {
      mockDartType.isDartAsyncFuture = true;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.future));
    });

    test("isDartAsyncStream", () {
      mockDartType.isDartAsyncStream = true;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.stream));
    });

    test("isUnkownType", () {
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.unknown));
    });

    test("nullability question", () {
      mockTypeArgument.nullabilitySuffix = NullabilitySuffix.none;
      mockDartType.nullabilitySuffix = NullabilitySuffix.question;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.unknown));
      expect(result.nullable, isTrue);
    });

    test("nullability none", () {
      mockTypeArgument.nullabilitySuffix = NullabilitySuffix.question;
      mockDartType.nullabilitySuffix = NullabilitySuffix.none;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.unknown));
      expect(result.nullable, isFalse);
    });
  });

  group("Test typeArgumentType", () {
    late MockInterfaceType mockDartType;

    setUp(() {
      mockDartType = MockInterfaceType(
        nullabilitySuffix: NullabilitySuffix.none,
        isDartCoreList: false,
        isDartAsyncFuture: false,
        isDartAsyncStream: false,
        typeArguments: [mockTypeArgument],
      );
    });

    test("isDartCoreList", () {
      mockDartType.isDartCoreList = true;
      mockTypeArgument.isDartCoreList = true;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.list));
      expect(result.firstTypeArgument, EType.list);
    });

    test("isDartAsyncFuture", () {
      mockDartType.isDartCoreList = true;
      mockTypeArgument.isDartAsyncFuture = true;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.list));
      expect(result.firstTypeArgument, EType.future);
    });

    test("isDartAsyncStream", () {
      mockDartType.isDartCoreList = true;
      mockTypeArgument.isDartAsyncStream = true;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.list));
      expect(result.firstTypeArgument, EType.stream);
    });

    test("isUnkownType", () {
      mockDartType.isDartCoreList = true;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.list));
      expect(result.firstTypeArgument, EType.unknown);
    });

    test("nullability question", () {
      mockDartType.isDartCoreList = true;
      mockDartType.nullabilitySuffix = NullabilitySuffix.none;
      mockTypeArgument.nullabilitySuffix = NullabilitySuffix.question;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.list));
      expect(result.firstTypeArgument, EType.unknown);
      expect(result.nullable, isTrue);
    });

    test("nullability none", () {
      mockDartType.isDartCoreList = true;
      mockDartType.nullabilitySuffix = NullabilitySuffix.question;
      mockTypeArgument.nullabilitySuffix = NullabilitySuffix.none;
      final result = const BaseHelper().getTypeSpecification(mockDartType);

      expect(result.type, equals(EType.list));
      expect(result.firstTypeArgument, EType.unknown);
      expect(result.nullable, isFalse);
    });
  });
}
