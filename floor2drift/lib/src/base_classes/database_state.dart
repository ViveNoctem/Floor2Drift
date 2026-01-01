// ignore_for_file: deprecated_member_use_from_same_package

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor2drift/src/entity/class_state.dart';
import 'package:floor2drift/src/generator/base_dao_generator.dart';
import 'package:floor2drift/src/generator/dao_generator.dart';
import 'package:floor2drift/src/generator/database_generator.dart';
import 'package:floor2drift_annotation/floor2drift_annotation.dart';
import 'package:floor_annotation/floor_annotation.dart';

/// {@template DatabaseState}
/// Internal representation for the Floor [Database]
///
/// Contains
/// {@endtemplate
class DatabaseState {
  /// DartType of the Database, that is being converted
  final DartType databaseClass;

  /// All floor [Entity] Classes that will be converted
  ///
  /// Entities filtered out by classNameFilter are not added.
  final Set<ClassElement> entities;

  /// All superclasses of [entities] annotated with [convertBaseEntity]
  final Set<ClassElement> baseEntities;

  /// All [dao] classes that are defined in the fields of the [Database]
  ///
  /// Daos filtered out by classNameFilter are not added.
  final Set<ClassElement> daos;

  /// All superclasses of [daos] annotated with [convertBaseDao]
  final Set<ClassElement> baseDaos;

  /// All [TypeConverters] added at the Database level
  ///
  /// Will only contain "global" type converters. Not type converters only applicable for single classes/fields.
  final Set<TypeConverterState> typeConverters;

  /// Contains the version specified in the [Database] annotation
  final int schemaVersion;

  /// Contains the class name and path of all generated drift entities and base entities
  var driftClasses = <String, String>{};

  /// Contains the classnames and ClassElements of [entities], [baseEntities], [daos], [baseDaos], [typeConverters]
  ///
  /// Only used in the [DatabaseGenerator] where the classStates are not filled yet.
  @Deprecated("Use the entityClassStates instead")
  final floorClasses = <String, ClassElement>{};

  // TODO implement migration conversion
  // final List<Migration> migrations;

  // TODO maybe this can be remove
  /// Contains the [DartType] and [TypeConverterState] of the global type converters
  ///
  /// Is passed to the [DaoGenerator] and [BaseDaoGenerator] to check if an type converter is used for a specific field
  @Deprecated("Use the entityClassStates instead.")
  late final Map<DartType, TypeConverterState> typeConverterMap;

  /// class states of all (base-)entities used in the floor db
  Set<ClassState> entityClassStates = {};

  /// {@macro DatabaseState}
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
    typeConverterMap = {for (var entry in typeConverters) entry.fromType: entry};

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
