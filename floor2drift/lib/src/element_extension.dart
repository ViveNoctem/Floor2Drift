import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// General extension methods for [Element] class
extension ElementExtension on Element {
  /// cast this [Element] to [ClassElement] will throw [InvalidGenerationSource] if not an actual [ClassElement]
  ClassElement get toClassElement {
    if (this is! ClassElement) {
      throw InvalidGenerationSourceError('expected ClassElement', element: this);
    }
    return this as ClassElement;
  }

  /// returns the analyzer ASTNode for the current element
  AstNode? getNode() {
    final session = this.session;
    if (session == null) {
      return null;
    }

    final parsedLibrary = session.getParsedLibraryByElement(library!);

    if (parsedLibrary is! ParsedLibraryResult) {
      return null;
    }

    final declarationResult = parsedLibrary.getElementDeclaration(this);
    return declarationResult?.node;
  }
}
