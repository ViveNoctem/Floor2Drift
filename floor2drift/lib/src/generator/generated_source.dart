class GeneratedSource {
  final String code;
  final Set<String> imports;
  final Set<String> parts;

  const GeneratedSource({required this.code, this.imports = const {}, this.parts = const {}});

  const GeneratedSource.empty() : code = "", imports = const {}, parts = const {};

  GeneratedSource copyWith({String? code, Set<String>? imports, Set<String>? parts}) {
    return GeneratedSource(code: code ?? this.code, imports: imports ?? this.imports, parts: parts ?? this.parts);
  }

  GeneratedSource operator +(GeneratedSource other) {
    return _add(other);
  }

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

  String toFileContent() {
    return "${imports.join("\n")}\n\n"
        "${parts.join("\n")}\n\n"
        "$code";
  }

  bool get isEmpty => code.isEmpty && imports.isEmpty && parts.isEmpty;

  bool get isNotEmpty => isEmpty == false;
}
