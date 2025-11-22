import 'package:floor/floor.dart';

class ExampleBaseClass {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  const ExampleBaseClass({this.id});
}
