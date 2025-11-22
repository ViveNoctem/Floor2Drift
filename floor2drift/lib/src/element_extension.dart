import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

extension ElementExtension on Element {
  ClassElement get toClassElement {
    if (this is! ClassElement) {
      throw InvalidGenerationSourceError('expected ClassElement', element: this);
    }
    return this as ClassElement;
  }
}
