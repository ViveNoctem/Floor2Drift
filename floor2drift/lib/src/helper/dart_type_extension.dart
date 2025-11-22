import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

extension DartTypeExtension on DartType {
  bool get isEnum {
    final localElement = element;

    if (localElement == null) {
      throw InvalidGenerationSource("Element could not be resolved");
    }

    return TypeChecker.fromRuntime(Enum).isSuperOf(localElement);
  }
}
