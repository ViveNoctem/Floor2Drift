import 'dart:typed_data';

import 'package:floor/floor.dart';

class NotUsedTypeConverter extends TypeConverter<Uint8List, Uint8List> {
  @override
  Uint8List decode(Uint8List databaseValue) {
    return databaseValue;
  }

  @override
  Uint8List encode(Uint8List value) {
    return value;
  }
}
