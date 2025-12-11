import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/entity/annotation_converter/classState.dart';

class DatabaseState {
  final DartType databaseClass;

  final Set<ClassElement> entities;
  final Set<ClassElement> baseEntities;
  final Set<ClassElement> daos;
  final Set<ClassElement> baseDaos;

  final Set<TypeConverterState> typeConverters;

  final int schemaVersion;

  /// contains all Generated Drift classes Names and their path
  /// at the moment only contains generated entities and base entities
  var driftClasses = <String, String>{};
  final floorClasses = <String, ClassElement>{};

  // TODO implement migration conversion
  // final List<Migration> migrations;

  // TODO maybe this can be remove
  late final Map<Element, TypeConverterState> typeConverterMap;

  /// class states of all (base-)entities used in the floor db
  Set<ClassState> entityClassStates = {};

  DatabaseState({
    required this.typeConverters,
    required this.databaseClass,
    required this.entities,
    required this.baseEntities,
    required this.daos,
    required this.baseDaos,
    required this.schemaVersion,
    // required this.migrations,
  }) {
    typeConverterMap = {for (var entry in typeConverters) entry.fromType.element!: entry};

    for (final entity in entities) {
      floorClasses[entity.name] = entity;
    }

    for (final baseEntity in baseEntities) {
      floorClasses[baseEntity.name] = baseEntity;
    }

    for (final dao in daos) {
      floorClasses[dao.name] = dao;
    }

    for (final baseDao in baseDaos) {
      floorClasses[baseDao.name] = baseDao;
    }

    for (final typeConverter in typeConverters) {
      floorClasses[typeConverter.classElement.name] = typeConverter.classElement;
    }
  }
}
