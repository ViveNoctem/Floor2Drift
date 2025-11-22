library;

import 'package:floor/floor.dart';

// export 'entity_packagesuffix.dart';

@entity
class ExampleUser2 {
  @primaryKey
  final int? id;
  final String userName;
  final String password;

  const ExampleUser2({
    required this.id,
    required this.userName,
    required this.password,
  });
}
