import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class ClassState {
  final DartType classType;
  final renamedFields = <String, String>{};
  final superElement = <Element>[];

  ClassState({required this.classType});
}
