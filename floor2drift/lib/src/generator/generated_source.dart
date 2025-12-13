/// {@template GeneratedSource}
/// Representation of a generated source file in this library
/// {@endtemplate}
class GeneratedSource {
  /// The actual dart code in this source file
  final String code;

  /// Set of import directive this source file contains
  final Set<String> imports;

  /// Set of part directives this source file contains
  final Set<String> parts;

  /// {@macro GeneratedSource}
  const GeneratedSource({required this.code, this.imports = const {}, this.parts = const {}});

  /// {@macro GeneratedSource}
  /// Creates an empty object
  const GeneratedSource.empty()
      : code = "",
        imports = const {},
        parts = const {};

  /// {@macro copyWith}
  GeneratedSource copyWith({String? code, Set<String>? imports, Set<String>? parts}) {
    return GeneratedSource(code: code ?? this.code, imports: imports ?? this.imports, parts: parts ?? this.parts);
  }

  /// {macro GeneratedSource.add}
  GeneratedSource operator +(GeneratedSource other) {
    return _add(other);
  }

  /// {@template GeneratedSource.add}
  /// appends all of [other] fields to the current source file
  /// {@endtemplate}
  GeneratedSource add(GeneratedSource other) {
    return _add(other);
  }

  GeneratedSource _add(GeneratedSource other) {
    return copyWith(
      code: "$code\n\n${other.code}",
      imports: {...imports, ...other.imports},
      parts: {...parts, ...other.parts},
    );
  }

  ///return the fiel contents of this source field, that can be written to an file
  String toFileContent() {
    return "${imports.join("\n")}\n\n"
        "${parts.join("\n")}\n\n"
        "$code";
  }

  /// is this source file empty
  bool get isEmpty => code.isEmpty && imports.isEmpty && parts.isEmpty;

  /// is this source file not empty
  bool get isNotEmpty => isEmpty == false;
}
