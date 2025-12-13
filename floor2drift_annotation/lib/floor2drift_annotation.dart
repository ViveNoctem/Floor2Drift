/// {@template ConvertBaseEntity}
/// If this annotations is added to a super class of a floor entity the class and its fields will be converted to a drift class.
/// {@endtemplate}
class ConvertBaseEntity {
  /// {@macro ConvertBaseEntity}
  const ConvertBaseEntity();
}

/// {@macro ConvertBaseEntity}
const convertBaseEntity = ConvertBaseEntity();

/// {@template ConvertBaseDao}
/// If this annotations is added to a super class of a floor dao the class and its queries will be converted to a drift class.
/// {@endtemplate}
class ConvertBaseDao {
  /// {@macro ConvertBaseDao}
  const ConvertBaseDao();
}

/// {@macro ConvertBaseDao}
const convertBaseDao = ConvertBaseDao();
