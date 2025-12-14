import 'dart:io';

import 'package:floor2drift/floor2drift.dart';
import 'package:floor2drift/src/helper/base_helper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'output_option_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<File>(),
  MockSpec<BaseHelper>(),
  MockSpec<IOSink>(),
])
void main() {
  late MockFile mockFile;
  late MockBaseHelper mockBaseHelper;
  late MockIOSink mockIOSink;

  setUp(() {
    mockFile = MockFile();
    mockBaseHelper = MockBaseHelper();
    mockIOSink = MockIOSink();

    when(mockFile.existsSync()).thenReturn(false);
    when(mockFile.path).thenReturn("test/path/to/file/");
    when(mockFile.openWrite()).thenReturn(mockIOSink);
  });

  group("writeFile", () {
    group("lineTerminator", () {
      test("windows", () {
        when(mockBaseHelper.getPlatformLineTerminator()).thenReturn("\r\n");

        final outputOptions = OutputOptions(
          fileSuffix: "",
          dryRun: false,
          baseHelper: mockBaseHelper,
        );

        final inputString = "this is\ntestmessage\n\n";
        final expectedString = "this is\r\ntestmessage\r\n\r\n";

        final result = outputOptions.writeFile(mockFile, inputString);

        expect(result, isTrue);
        verify(mockIOSink.write(expectedString)).called(1);
        verify(mockIOSink.close()).called(1);
        verifyNoMoreInteractions(mockIOSink);
      });

      test("linux", () {
        when(mockBaseHelper.getPlatformLineTerminator()).thenReturn("\n");

        final outputOptions = OutputOptions(
          fileSuffix: "",
          dryRun: false,
          baseHelper: mockBaseHelper,
        );

        final inputString = "this is\ntestmessage\n\n";
        final expectedString = "this is\ntestmessage\n\n";

        final result = outputOptions.writeFile(mockFile, inputString);

        expect(result, isTrue);
        verify(mockIOSink.write(expectedString)).called(1);
        verify(mockIOSink.close()).called(1);
        verifyNoMoreInteractions(mockIOSink);
      });
    });

    test("content didn't change", () {
      final inputString = "this is\ntestmessage\n\n";
      final existingContent = "this is\ntestmessage\n\n";

      when(mockFile.existsSync()).thenReturn(true);
      when(mockFile.readAsStringSync()).thenReturn(existingContent);

      final outputOptions = OutputOptions(
        fileSuffix: "",
        dryRun: false,
      );

      outputOptions.writeFile(mockFile, inputString);
      verifyZeroInteractions(mockIOSink);
    });

    test("dryRun", () {
      final outputOptions = OutputOptions(
        fileSuffix: "",
        dryRun: true,
      );

      final inputString = "this is\ntestmessage\n\n";

      final result = outputOptions.writeFile(mockFile, inputString);

      expect(result, isTrue);
      verifyZeroInteractions(mockIOSink);

      verify(mockFile.path).called(1);
      verifyNoMoreInteractions(mockFile);
    });
  });
}
