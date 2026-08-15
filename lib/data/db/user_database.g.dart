// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// ignore_for_file: type=lint
class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ayahId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final int ayahId;
  final int createdAt;
  const Bookmark({
    required this.id,
    required this.ayahId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ayah_id'] = Variable<int>(ayahId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      ayahId: Value(ayahId),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ayahId': serializer.toJson<int>(ayahId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Bookmark copyWith({int? id, int? ayahId, int? createdAt}) => Bookmark(
    id: id ?? this.id,
    ayahId: ayahId ?? this.ayahId,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ayahId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.ayahId == this.ayahId &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<int> ayahId;
  final Value<int> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int ayahId,
    required int createdAt,
  }) : ayahId = Value(ayahId),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<int>? ayahId,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ayahId != null) 'ayah_id': ayahId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? ayahId,
    Value<int>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      ayahId: ayahId ?? this.ayahId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LastReadsTable extends LastReads
    with TableInfo<$LastReadsTable, LastRead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LastReadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (id = 0)',
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ayahId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'last_reads';
  @override
  VerificationContext validateIntegrity(
    Insertable<LastRead> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LastRead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LastRead(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LastReadsTable createAlias(String alias) {
    return $LastReadsTable(attachedDatabase, alias);
  }
}

class LastRead extends DataClass implements Insertable<LastRead> {
  final int id;
  final int ayahId;
  final int updatedAt;
  const LastRead({
    required this.id,
    required this.ayahId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ayah_id'] = Variable<int>(ayahId);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  LastReadsCompanion toCompanion(bool nullToAbsent) {
    return LastReadsCompanion(
      id: Value(id),
      ayahId: Value(ayahId),
      updatedAt: Value(updatedAt),
    );
  }

  factory LastRead.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LastRead(
      id: serializer.fromJson<int>(json['id']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ayahId': serializer.toJson<int>(ayahId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  LastRead copyWith({int? id, int? ayahId, int? updatedAt}) => LastRead(
    id: id ?? this.id,
    ayahId: ayahId ?? this.ayahId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LastRead copyWithCompanion(LastReadsCompanion data) {
    return LastRead(
      id: data.id.present ? data.id.value : this.id,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LastRead(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ayahId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LastRead &&
          other.id == this.id &&
          other.ayahId == this.ayahId &&
          other.updatedAt == this.updatedAt);
}

class LastReadsCompanion extends UpdateCompanion<LastRead> {
  final Value<int> id;
  final Value<int> ayahId;
  final Value<int> updatedAt;
  const LastReadsCompanion({
    this.id = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LastReadsCompanion.insert({
    this.id = const Value.absent(),
    required int ayahId,
    required int updatedAt,
  }) : ayahId = Value(ayahId),
       updatedAt = Value(updatedAt);
  static Insertable<LastRead> custom({
    Expression<int>? id,
    Expression<int>? ayahId,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ayahId != null) 'ayah_id': ayahId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LastReadsCompanion copyWith({
    Value<int>? id,
    Value<int>? ayahId,
    Value<int>? updatedAt,
  }) {
    return LastReadsCompanion(
      id: id ?? this.id,
      ayahId: ayahId ?? this.ayahId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastReadsCompanion(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecitersTable extends Reciters with TableInfo<$RecitersTable, Reciter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecitersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlTemplateMeta = const VerificationMeta(
    'urlTemplate',
  );
  @override
  late final GeneratedColumn<String> urlTemplate = GeneratedColumn<String>(
    'url_template',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, style, urlTemplate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reciters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reciter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    } else if (isInserting) {
      context.missing(_styleMeta);
    }
    if (data.containsKey('url_template')) {
      context.handle(
        _urlTemplateMeta,
        urlTemplate.isAcceptableOrUnknown(
          data['url_template']!,
          _urlTemplateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reciter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reciter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      )!,
      urlTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_template'],
      ),
    );
  }

  @override
  $RecitersTable createAlias(String alias) {
    return $RecitersTable(attachedDatabase, alias);
  }
}

class Reciter extends DataClass implements Insertable<Reciter> {
  final int id;
  final String name;
  final String style;

  /// Phase-2 audio seam: URL template with `{SSS}` (surah, 3-digit) and
  /// `{AAA}` (ayah, 3-digit) placeholders, e.g. everyayah.com.
  final String? urlTemplate;
  const Reciter({
    required this.id,
    required this.name,
    required this.style,
    this.urlTemplate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['style'] = Variable<String>(style);
    if (!nullToAbsent || urlTemplate != null) {
      map['url_template'] = Variable<String>(urlTemplate);
    }
    return map;
  }

  RecitersCompanion toCompanion(bool nullToAbsent) {
    return RecitersCompanion(
      id: Value(id),
      name: Value(name),
      style: Value(style),
      urlTemplate: urlTemplate == null && nullToAbsent
          ? const Value.absent()
          : Value(urlTemplate),
    );
  }

  factory Reciter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reciter(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      style: serializer.fromJson<String>(json['style']),
      urlTemplate: serializer.fromJson<String?>(json['urlTemplate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'style': serializer.toJson<String>(style),
      'urlTemplate': serializer.toJson<String?>(urlTemplate),
    };
  }

  Reciter copyWith({
    int? id,
    String? name,
    String? style,
    Value<String?> urlTemplate = const Value.absent(),
  }) => Reciter(
    id: id ?? this.id,
    name: name ?? this.name,
    style: style ?? this.style,
    urlTemplate: urlTemplate.present ? urlTemplate.value : this.urlTemplate,
  );
  Reciter copyWithCompanion(RecitersCompanion data) {
    return Reciter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      style: data.style.present ? data.style.value : this.style,
      urlTemplate: data.urlTemplate.present
          ? data.urlTemplate.value
          : this.urlTemplate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reciter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('style: $style, ')
          ..write('urlTemplate: $urlTemplate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, style, urlTemplate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reciter &&
          other.id == this.id &&
          other.name == this.name &&
          other.style == this.style &&
          other.urlTemplate == this.urlTemplate);
}

class RecitersCompanion extends UpdateCompanion<Reciter> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> style;
  final Value<String?> urlTemplate;
  const RecitersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.style = const Value.absent(),
    this.urlTemplate = const Value.absent(),
  });
  RecitersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String style,
    this.urlTemplate = const Value.absent(),
  }) : name = Value(name),
       style = Value(style);
  static Insertable<Reciter> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? style,
    Expression<String>? urlTemplate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (style != null) 'style': style,
      if (urlTemplate != null) 'url_template': urlTemplate,
    });
  }

  RecitersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? style,
    Value<String?>? urlTemplate,
  }) {
    return RecitersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      style: style ?? this.style,
      urlTemplate: urlTemplate ?? this.urlTemplate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (urlTemplate.present) {
      map['url_template'] = Variable<String>(urlTemplate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecitersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('style: $style, ')
          ..write('urlTemplate: $urlTemplate')
          ..write(')'))
        .toString();
  }
}

class $AyahAudioTable extends AyahAudio
    with TableInfo<$AyahAudioTable, AyahAudioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahAudioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterIdMeta = const VerificationMeta(
    'reciterId',
  );
  @override
  late final GeneratedColumn<int> reciterId = GeneratedColumn<int>(
    'reciter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathOrUrlMeta = const VerificationMeta(
    'filePathOrUrl',
  );
  @override
  late final GeneratedColumn<String> filePathOrUrl = GeneratedColumn<String>(
    'file_path_or_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<int> lastAccessedAt = GeneratedColumn<int>(
    'last_accessed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ayahId,
    reciterId,
    filePathOrUrl,
    durationMs,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah_audio';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahAudioData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('reciter_id')) {
      context.handle(
        _reciterIdMeta,
        reciterId.isAcceptableOrUnknown(data['reciter_id']!, _reciterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reciterIdMeta);
    }
    if (data.containsKey('file_path_or_url')) {
      context.handle(
        _filePathOrUrlMeta,
        filePathOrUrl.isAcceptableOrUnknown(
          data['file_path_or_url']!,
          _filePathOrUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_filePathOrUrlMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ayahId, reciterId},
  ];
  @override
  AyahAudioData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahAudioData(
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      reciterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reciter_id'],
      )!,
      filePathOrUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path_or_url'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed_at'],
      ),
    );
  }

  @override
  $AyahAudioTable createAlias(String alias) {
    return $AyahAudioTable(attachedDatabase, alias);
  }
}

class AyahAudioData extends DataClass implements Insertable<AyahAudioData> {
  final int ayahId;
  final int reciterId;
  final String filePathOrUrl;
  final int? durationMs;

  /// Phase-2 audio seam: last time this file was played (epoch seconds).
  final int? lastAccessedAt;
  const AyahAudioData({
    required this.ayahId,
    required this.reciterId,
    required this.filePathOrUrl,
    this.durationMs,
    this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ayah_id'] = Variable<int>(ayahId);
    map['reciter_id'] = Variable<int>(reciterId);
    map['file_path_or_url'] = Variable<String>(filePathOrUrl);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt);
    }
    return map;
  }

  AyahAudioCompanion toCompanion(bool nullToAbsent) {
    return AyahAudioCompanion(
      ayahId: Value(ayahId),
      reciterId: Value(reciterId),
      filePathOrUrl: Value(filePathOrUrl),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory AyahAudioData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahAudioData(
      ayahId: serializer.fromJson<int>(json['ayahId']),
      reciterId: serializer.fromJson<int>(json['reciterId']),
      filePathOrUrl: serializer.fromJson<String>(json['filePathOrUrl']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      lastAccessedAt: serializer.fromJson<int?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ayahId': serializer.toJson<int>(ayahId),
      'reciterId': serializer.toJson<int>(reciterId),
      'filePathOrUrl': serializer.toJson<String>(filePathOrUrl),
      'durationMs': serializer.toJson<int?>(durationMs),
      'lastAccessedAt': serializer.toJson<int?>(lastAccessedAt),
    };
  }

  AyahAudioData copyWith({
    int? ayahId,
    int? reciterId,
    String? filePathOrUrl,
    Value<int?> durationMs = const Value.absent(),
    Value<int?> lastAccessedAt = const Value.absent(),
  }) => AyahAudioData(
    ayahId: ayahId ?? this.ayahId,
    reciterId: reciterId ?? this.reciterId,
    filePathOrUrl: filePathOrUrl ?? this.filePathOrUrl,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    lastAccessedAt: lastAccessedAt.present
        ? lastAccessedAt.value
        : this.lastAccessedAt,
  );
  AyahAudioData copyWithCompanion(AyahAudioCompanion data) {
    return AyahAudioData(
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      reciterId: data.reciterId.present ? data.reciterId.value : this.reciterId,
      filePathOrUrl: data.filePathOrUrl.present
          ? data.filePathOrUrl.value
          : this.filePathOrUrl,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahAudioData(')
          ..write('ayahId: $ayahId, ')
          ..write('reciterId: $reciterId, ')
          ..write('filePathOrUrl: $filePathOrUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ayahId, reciterId, filePathOrUrl, durationMs, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahAudioData &&
          other.ayahId == this.ayahId &&
          other.reciterId == this.reciterId &&
          other.filePathOrUrl == this.filePathOrUrl &&
          other.durationMs == this.durationMs &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class AyahAudioCompanion extends UpdateCompanion<AyahAudioData> {
  final Value<int> ayahId;
  final Value<int> reciterId;
  final Value<String> filePathOrUrl;
  final Value<int?> durationMs;
  final Value<int?> lastAccessedAt;
  final Value<int> rowid;
  const AyahAudioCompanion({
    this.ayahId = const Value.absent(),
    this.reciterId = const Value.absent(),
    this.filePathOrUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyahAudioCompanion.insert({
    required int ayahId,
    required int reciterId,
    required String filePathOrUrl,
    this.durationMs = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ayahId = Value(ayahId),
       reciterId = Value(reciterId),
       filePathOrUrl = Value(filePathOrUrl);
  static Insertable<AyahAudioData> custom({
    Expression<int>? ayahId,
    Expression<int>? reciterId,
    Expression<String>? filePathOrUrl,
    Expression<int>? durationMs,
    Expression<int>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ayahId != null) 'ayah_id': ayahId,
      if (reciterId != null) 'reciter_id': reciterId,
      if (filePathOrUrl != null) 'file_path_or_url': filePathOrUrl,
      if (durationMs != null) 'duration_ms': durationMs,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyahAudioCompanion copyWith({
    Value<int>? ayahId,
    Value<int>? reciterId,
    Value<String>? filePathOrUrl,
    Value<int?>? durationMs,
    Value<int?>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return AyahAudioCompanion(
      ayahId: ayahId ?? this.ayahId,
      reciterId: reciterId ?? this.reciterId,
      filePathOrUrl: filePathOrUrl ?? this.filePathOrUrl,
      durationMs: durationMs ?? this.durationMs,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (reciterId.present) {
      map['reciter_id'] = Variable<int>(reciterId.value);
    }
    if (filePathOrUrl.present) {
      map['file_path_or_url'] = Variable<String>(filePathOrUrl.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahAudioCompanion(')
          ..write('ayahId: $ayahId, ')
          ..write('reciterId: $reciterId, ')
          ..write('filePathOrUrl: $filePathOrUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingLogTable extends ReadingLog
    with TableInfo<$ReadingLogTable, ReadingLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _epochDayMeta = const VerificationMeta(
    'epochDay',
  );
  @override
  late final GeneratedColumn<int> epochDay = GeneratedColumn<int>(
    'epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
    'juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, epochDay, juz, ayahId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('epoch_day')) {
      context.handle(
        _epochDayMeta,
        epochDay.isAcceptableOrUnknown(data['epoch_day']!, _epochDayMeta),
      );
    } else if (isInserting) {
      context.missing(_epochDayMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {epochDay, ayahId},
  ];
  @override
  ReadingLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      epochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}epoch_day'],
      )!,
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReadingLogTable createAlias(String alias) {
    return $ReadingLogTable(attachedDatabase, alias);
  }
}

class ReadingLogEntry extends DataClass implements Insertable<ReadingLogEntry> {
  final int id;
  final int epochDay;
  final int juz;
  final int ayahId;
  final int createdAt;
  const ReadingLogEntry({
    required this.id,
    required this.epochDay,
    required this.juz,
    required this.ayahId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['epoch_day'] = Variable<int>(epochDay);
    map['juz'] = Variable<int>(juz);
    map['ayah_id'] = Variable<int>(ayahId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ReadingLogCompanion toCompanion(bool nullToAbsent) {
    return ReadingLogCompanion(
      id: Value(id),
      epochDay: Value(epochDay),
      juz: Value(juz),
      ayahId: Value(ayahId),
      createdAt: Value(createdAt),
    );
  }

  factory ReadingLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingLogEntry(
      id: serializer.fromJson<int>(json['id']),
      epochDay: serializer.fromJson<int>(json['epochDay']),
      juz: serializer.fromJson<int>(json['juz']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'epochDay': serializer.toJson<int>(epochDay),
      'juz': serializer.toJson<int>(juz),
      'ayahId': serializer.toJson<int>(ayahId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ReadingLogEntry copyWith({
    int? id,
    int? epochDay,
    int? juz,
    int? ayahId,
    int? createdAt,
  }) => ReadingLogEntry(
    id: id ?? this.id,
    epochDay: epochDay ?? this.epochDay,
    juz: juz ?? this.juz,
    ayahId: ayahId ?? this.ayahId,
    createdAt: createdAt ?? this.createdAt,
  );
  ReadingLogEntry copyWithCompanion(ReadingLogCompanion data) {
    return ReadingLogEntry(
      id: data.id.present ? data.id.value : this.id,
      epochDay: data.epochDay.present ? data.epochDay.value : this.epochDay,
      juz: data.juz.present ? data.juz.value : this.juz,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogEntry(')
          ..write('id: $id, ')
          ..write('epochDay: $epochDay, ')
          ..write('juz: $juz, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, epochDay, juz, ayahId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingLogEntry &&
          other.id == this.id &&
          other.epochDay == this.epochDay &&
          other.juz == this.juz &&
          other.ayahId == this.ayahId &&
          other.createdAt == this.createdAt);
}

class ReadingLogCompanion extends UpdateCompanion<ReadingLogEntry> {
  final Value<int> id;
  final Value<int> epochDay;
  final Value<int> juz;
  final Value<int> ayahId;
  final Value<int> createdAt;
  const ReadingLogCompanion({
    this.id = const Value.absent(),
    this.epochDay = const Value.absent(),
    this.juz = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReadingLogCompanion.insert({
    this.id = const Value.absent(),
    required int epochDay,
    required int juz,
    required int ayahId,
    required int createdAt,
  }) : epochDay = Value(epochDay),
       juz = Value(juz),
       ayahId = Value(ayahId),
       createdAt = Value(createdAt);
  static Insertable<ReadingLogEntry> custom({
    Expression<int>? id,
    Expression<int>? epochDay,
    Expression<int>? juz,
    Expression<int>? ayahId,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (epochDay != null) 'epoch_day': epochDay,
      if (juz != null) 'juz': juz,
      if (ayahId != null) 'ayah_id': ayahId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReadingLogCompanion copyWith({
    Value<int>? id,
    Value<int>? epochDay,
    Value<int>? juz,
    Value<int>? ayahId,
    Value<int>? createdAt,
  }) {
    return ReadingLogCompanion(
      id: id ?? this.id,
      epochDay: epochDay ?? this.epochDay,
      juz: juz ?? this.juz,
      ayahId: ayahId ?? this.ayahId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (epochDay.present) {
      map['epoch_day'] = Variable<int>(epochDay.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogCompanion(')
          ..write('id: $id, ')
          ..write('epochDay: $epochDay, ')
          ..write('juz: $juz, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SajdaLogTable extends SajdaLog
    with TableInfo<$SajdaLogTable, SajdaLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SajdaLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ayahId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sajda_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<SajdaLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ayahId},
  ];
  @override
  SajdaLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SajdaLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SajdaLogTable createAlias(String alias) {
    return $SajdaLogTable(attachedDatabase, alias);
  }
}

class SajdaLogEntry extends DataClass implements Insertable<SajdaLogEntry> {
  final int id;
  final int ayahId;
  final int createdAt;
  const SajdaLogEntry({
    required this.id,
    required this.ayahId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ayah_id'] = Variable<int>(ayahId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SajdaLogCompanion toCompanion(bool nullToAbsent) {
    return SajdaLogCompanion(
      id: Value(id),
      ayahId: Value(ayahId),
      createdAt: Value(createdAt),
    );
  }

  factory SajdaLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SajdaLogEntry(
      id: serializer.fromJson<int>(json['id']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ayahId': serializer.toJson<int>(ayahId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SajdaLogEntry copyWith({int? id, int? ayahId, int? createdAt}) =>
      SajdaLogEntry(
        id: id ?? this.id,
        ayahId: ayahId ?? this.ayahId,
        createdAt: createdAt ?? this.createdAt,
      );
  SajdaLogEntry copyWithCompanion(SajdaLogCompanion data) {
    return SajdaLogEntry(
      id: data.id.present ? data.id.value : this.id,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SajdaLogEntry(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ayahId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SajdaLogEntry &&
          other.id == this.id &&
          other.ayahId == this.ayahId &&
          other.createdAt == this.createdAt);
}

class SajdaLogCompanion extends UpdateCompanion<SajdaLogEntry> {
  final Value<int> id;
  final Value<int> ayahId;
  final Value<int> createdAt;
  const SajdaLogCompanion({
    this.id = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SajdaLogCompanion.insert({
    this.id = const Value.absent(),
    required int ayahId,
    required int createdAt,
  }) : ayahId = Value(ayahId),
       createdAt = Value(createdAt);
  static Insertable<SajdaLogEntry> custom({
    Expression<int>? id,
    Expression<int>? ayahId,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ayahId != null) 'ayah_id': ayahId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SajdaLogCompanion copyWith({
    Value<int>? id,
    Value<int>? ayahId,
    Value<int>? createdAt,
  }) {
    return SajdaLogCompanion(
      id: id ?? this.id,
      ayahId: ayahId ?? this.ayahId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SajdaLogCompanion(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $KhatamTargetsTable extends KhatamTargets
    with TableInfo<$KhatamTargetsTable, KhatamTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KhatamTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (id = 0)',
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<int> targetDate = GeneratedColumn<int>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, targetDate, startDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'khatam_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<KhatamTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KhatamTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KhatamTarget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_date'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $KhatamTargetsTable createAlias(String alias) {
    return $KhatamTargetsTable(attachedDatabase, alias);
  }
}

class KhatamTarget extends DataClass implements Insertable<KhatamTarget> {
  final int id;
  final int? targetDate;
  final int startDate;
  final int createdAt;
  const KhatamTarget({
    required this.id,
    this.targetDate,
    required this.startDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<int>(targetDate);
    }
    map['start_date'] = Variable<int>(startDate);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  KhatamTargetsCompanion toCompanion(bool nullToAbsent) {
    return KhatamTargetsCompanion(
      id: Value(id),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      startDate: Value(startDate),
      createdAt: Value(createdAt),
    );
  }

  factory KhatamTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KhatamTarget(
      id: serializer.fromJson<int>(json['id']),
      targetDate: serializer.fromJson<int?>(json['targetDate']),
      startDate: serializer.fromJson<int>(json['startDate']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetDate': serializer.toJson<int?>(targetDate),
      'startDate': serializer.toJson<int>(startDate),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  KhatamTarget copyWith({
    int? id,
    Value<int?> targetDate = const Value.absent(),
    int? startDate,
    int? createdAt,
  }) => KhatamTarget(
    id: id ?? this.id,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    startDate: startDate ?? this.startDate,
    createdAt: createdAt ?? this.createdAt,
  );
  KhatamTarget copyWithCompanion(KhatamTargetsCompanion data) {
    return KhatamTarget(
      id: data.id.present ? data.id.value : this.id,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KhatamTarget(')
          ..write('id: $id, ')
          ..write('targetDate: $targetDate, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, targetDate, startDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KhatamTarget &&
          other.id == this.id &&
          other.targetDate == this.targetDate &&
          other.startDate == this.startDate &&
          other.createdAt == this.createdAt);
}

class KhatamTargetsCompanion extends UpdateCompanion<KhatamTarget> {
  final Value<int> id;
  final Value<int?> targetDate;
  final Value<int> startDate;
  final Value<int> createdAt;
  const KhatamTargetsCompanion({
    this.id = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  KhatamTargetsCompanion.insert({
    this.id = const Value.absent(),
    this.targetDate = const Value.absent(),
    required int startDate,
    required int createdAt,
  }) : startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<KhatamTarget> custom({
    Expression<int>? id,
    Expression<int>? targetDate,
    Expression<int>? startDate,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetDate != null) 'target_date': targetDate,
      if (startDate != null) 'start_date': startDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  KhatamTargetsCompanion copyWith({
    Value<int>? id,
    Value<int?>? targetDate,
    Value<int>? startDate,
    Value<int>? createdAt,
  }) {
    return KhatamTargetsCompanion(
      id: id ?? this.id,
      targetDate: targetDate ?? this.targetDate,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<int>(targetDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KhatamTargetsCompanion(')
          ..write('id: $id, ')
          ..write('targetDate: $targetDate, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SurahPositionsTable extends SurahPositions
    with TableInfo<$SurahPositionsTable, SurahPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [surahId, ayahId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surah_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurahPosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahId};
  @override
  SurahPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahPosition(
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SurahPositionsTable createAlias(String alias) {
    return $SurahPositionsTable(attachedDatabase, alias);
  }
}

class SurahPosition extends DataClass implements Insertable<SurahPosition> {
  final int surahId;
  final int ayahId;
  final int updatedAt;
  const SurahPosition({
    required this.surahId,
    required this.ayahId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_id'] = Variable<int>(ayahId);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SurahPositionsCompanion toCompanion(bool nullToAbsent) {
    return SurahPositionsCompanion(
      surahId: Value(surahId),
      ayahId: Value(ayahId),
      updatedAt: Value(updatedAt),
    );
  }

  factory SurahPosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahPosition(
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahId': serializer.toJson<int>(surahId),
      'ayahId': serializer.toJson<int>(ayahId),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SurahPosition copyWith({int? surahId, int? ayahId, int? updatedAt}) =>
      SurahPosition(
        surahId: surahId ?? this.surahId,
        ayahId: ayahId ?? this.ayahId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SurahPosition copyWithCompanion(SurahPositionsCompanion data) {
    return SurahPosition(
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahPosition(')
          ..write('surahId: $surahId, ')
          ..write('ayahId: $ayahId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(surahId, ayahId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahPosition &&
          other.surahId == this.surahId &&
          other.ayahId == this.ayahId &&
          other.updatedAt == this.updatedAt);
}

class SurahPositionsCompanion extends UpdateCompanion<SurahPosition> {
  final Value<int> surahId;
  final Value<int> ayahId;
  final Value<int> updatedAt;
  const SurahPositionsCompanion({
    this.surahId = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SurahPositionsCompanion.insert({
    this.surahId = const Value.absent(),
    required int ayahId,
    required int updatedAt,
  }) : ayahId = Value(ayahId),
       updatedAt = Value(updatedAt);
  static Insertable<SurahPosition> custom({
    Expression<int>? surahId,
    Expression<int>? ayahId,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (surahId != null) 'surah_id': surahId,
      if (ayahId != null) 'ayah_id': ayahId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SurahPositionsCompanion copyWith({
    Value<int>? surahId,
    Value<int>? ayahId,
    Value<int>? updatedAt,
  }) {
    return SurahPositionsCompanion(
      surahId: surahId ?? this.surahId,
      ayahId: ayahId ?? this.ayahId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahPositionsCompanion(')
          ..write('surahId: $surahId, ')
          ..write('ayahId: $ayahId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DoaBookmarksTable extends DoaBookmarks
    with TableInfo<$DoaBookmarksTable, DoaBookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoaBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _doaIdMeta = const VerificationMeta('doaId');
  @override
  late final GeneratedColumn<String> doaId = GeneratedColumn<String>(
    'doa_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [doaId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doa_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoaBookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('doa_id')) {
      context.handle(
        _doaIdMeta,
        doaId.isAcceptableOrUnknown(data['doa_id']!, _doaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_doaIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {doaId};
  @override
  DoaBookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoaBookmark(
      doaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doa_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DoaBookmarksTable createAlias(String alias) {
    return $DoaBookmarksTable(attachedDatabase, alias);
  }
}

class DoaBookmark extends DataClass implements Insertable<DoaBookmark> {
  final String doaId;
  final int createdAt;
  const DoaBookmark({required this.doaId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['doa_id'] = Variable<String>(doaId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DoaBookmarksCompanion toCompanion(bool nullToAbsent) {
    return DoaBookmarksCompanion(
      doaId: Value(doaId),
      createdAt: Value(createdAt),
    );
  }

  factory DoaBookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoaBookmark(
      doaId: serializer.fromJson<String>(json['doaId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'doaId': serializer.toJson<String>(doaId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DoaBookmark copyWith({String? doaId, int? createdAt}) => DoaBookmark(
    doaId: doaId ?? this.doaId,
    createdAt: createdAt ?? this.createdAt,
  );
  DoaBookmark copyWithCompanion(DoaBookmarksCompanion data) {
    return DoaBookmark(
      doaId: data.doaId.present ? data.doaId.value : this.doaId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoaBookmark(')
          ..write('doaId: $doaId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(doaId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoaBookmark &&
          other.doaId == this.doaId &&
          other.createdAt == this.createdAt);
}

class DoaBookmarksCompanion extends UpdateCompanion<DoaBookmark> {
  final Value<String> doaId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DoaBookmarksCompanion({
    this.doaId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoaBookmarksCompanion.insert({
    required String doaId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : doaId = Value(doaId),
       createdAt = Value(createdAt);
  static Insertable<DoaBookmark> custom({
    Expression<String>? doaId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (doaId != null) 'doa_id': doaId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoaBookmarksCompanion copyWith({
    Value<String>? doaId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DoaBookmarksCompanion(
      doaId: doaId ?? this.doaId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (doaId.present) {
      map['doa_id'] = Variable<String>(doaId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoaBookmarksCompanion(')
          ..write('doaId: $doaId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $LastReadsTable lastReads = $LastReadsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $RecitersTable reciters = $RecitersTable(this);
  late final $AyahAudioTable ayahAudio = $AyahAudioTable(this);
  late final $ReadingLogTable readingLog = $ReadingLogTable(this);
  late final $SajdaLogTable sajdaLog = $SajdaLogTable(this);
  late final $KhatamTargetsTable khatamTargets = $KhatamTargetsTable(this);
  late final $SurahPositionsTable surahPositions = $SurahPositionsTable(this);
  late final $DoaBookmarksTable doaBookmarks = $DoaBookmarksTable(this);
  late final Index idxBookmarksAyah = Index(
    'idx_bookmarks_ayah',
    'CREATE INDEX idx_bookmarks_ayah ON bookmarks (ayah_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarks,
    lastReads,
    appMeta,
    reciters,
    ayahAudio,
    readingLog,
    sajdaLog,
    khatamTargets,
    surahPositions,
    doaBookmarks,
    idxBookmarksAyah,
  ];
}

typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      required int ayahId,
      required int createdAt,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<int> ayahId,
      Value<int> createdAt,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$UserDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$UserDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ayahId,
                required int createdAt,
              }) => BookmarksCompanion.insert(
                id: id,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$UserDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $$LastReadsTableCreateCompanionBuilder =
    LastReadsCompanion Function({
      Value<int> id,
      required int ayahId,
      required int updatedAt,
    });
typedef $$LastReadsTableUpdateCompanionBuilder =
    LastReadsCompanion Function({
      Value<int> id,
      Value<int> ayahId,
      Value<int> updatedAt,
    });

class $$LastReadsTableFilterComposer
    extends Composer<_$UserDatabase, $LastReadsTable> {
  $$LastReadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LastReadsTableOrderingComposer
    extends Composer<_$UserDatabase, $LastReadsTable> {
  $$LastReadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LastReadsTableAnnotationComposer
    extends Composer<_$UserDatabase, $LastReadsTable> {
  $$LastReadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LastReadsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $LastReadsTable,
          LastRead,
          $$LastReadsTableFilterComposer,
          $$LastReadsTableOrderingComposer,
          $$LastReadsTableAnnotationComposer,
          $$LastReadsTableCreateCompanionBuilder,
          $$LastReadsTableUpdateCompanionBuilder,
          (LastRead, BaseReferences<_$UserDatabase, $LastReadsTable, LastRead>),
          LastRead,
          PrefetchHooks Function()
        > {
  $$LastReadsTableTableManager(_$UserDatabase db, $LastReadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LastReadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LastReadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LastReadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => LastReadsCompanion(
                id: id,
                ayahId: ayahId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ayahId,
                required int updatedAt,
              }) => LastReadsCompanion.insert(
                id: id,
                ayahId: ayahId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LastReadsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $LastReadsTable,
      LastRead,
      $$LastReadsTableFilterComposer,
      $$LastReadsTableOrderingComposer,
      $$LastReadsTableAnnotationComposer,
      $$LastReadsTableCreateCompanionBuilder,
      $$LastReadsTableUpdateCompanionBuilder,
      (LastRead, BaseReferences<_$UserDatabase, $LastReadsTable, LastRead>),
      LastRead,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$UserDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$UserDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$UserDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$UserDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$UserDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$UserDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$RecitersTableCreateCompanionBuilder =
    RecitersCompanion Function({
      Value<int> id,
      required String name,
      required String style,
      Value<String?> urlTemplate,
    });
typedef $$RecitersTableUpdateCompanionBuilder =
    RecitersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> style,
      Value<String?> urlTemplate,
    });

class $$RecitersTableFilterComposer
    extends Composer<_$UserDatabase, $RecitersTable> {
  $$RecitersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get urlTemplate => $composableBuilder(
    column: $table.urlTemplate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecitersTableOrderingComposer
    extends Composer<_$UserDatabase, $RecitersTable> {
  $$RecitersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get urlTemplate => $composableBuilder(
    column: $table.urlTemplate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecitersTableAnnotationComposer
    extends Composer<_$UserDatabase, $RecitersTable> {
  $$RecitersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<String> get urlTemplate => $composableBuilder(
    column: $table.urlTemplate,
    builder: (column) => column,
  );
}

class $$RecitersTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $RecitersTable,
          Reciter,
          $$RecitersTableFilterComposer,
          $$RecitersTableOrderingComposer,
          $$RecitersTableAnnotationComposer,
          $$RecitersTableCreateCompanionBuilder,
          $$RecitersTableUpdateCompanionBuilder,
          (Reciter, BaseReferences<_$UserDatabase, $RecitersTable, Reciter>),
          Reciter,
          PrefetchHooks Function()
        > {
  $$RecitersTableTableManager(_$UserDatabase db, $RecitersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecitersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecitersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecitersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> style = const Value.absent(),
                Value<String?> urlTemplate = const Value.absent(),
              }) => RecitersCompanion(
                id: id,
                name: name,
                style: style,
                urlTemplate: urlTemplate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String style,
                Value<String?> urlTemplate = const Value.absent(),
              }) => RecitersCompanion.insert(
                id: id,
                name: name,
                style: style,
                urlTemplate: urlTemplate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecitersTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $RecitersTable,
      Reciter,
      $$RecitersTableFilterComposer,
      $$RecitersTableOrderingComposer,
      $$RecitersTableAnnotationComposer,
      $$RecitersTableCreateCompanionBuilder,
      $$RecitersTableUpdateCompanionBuilder,
      (Reciter, BaseReferences<_$UserDatabase, $RecitersTable, Reciter>),
      Reciter,
      PrefetchHooks Function()
    >;
typedef $$AyahAudioTableCreateCompanionBuilder =
    AyahAudioCompanion Function({
      required int ayahId,
      required int reciterId,
      required String filePathOrUrl,
      Value<int?> durationMs,
      Value<int?> lastAccessedAt,
      Value<int> rowid,
    });
typedef $$AyahAudioTableUpdateCompanionBuilder =
    AyahAudioCompanion Function({
      Value<int> ayahId,
      Value<int> reciterId,
      Value<String> filePathOrUrl,
      Value<int?> durationMs,
      Value<int?> lastAccessedAt,
      Value<int> rowid,
    });

class $$AyahAudioTableFilterComposer
    extends Composer<_$UserDatabase, $AyahAudioTable> {
  $$AyahAudioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePathOrUrl => $composableBuilder(
    column: $table.filePathOrUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AyahAudioTableOrderingComposer
    extends Composer<_$UserDatabase, $AyahAudioTable> {
  $$AyahAudioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reciterId => $composableBuilder(
    column: $table.reciterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePathOrUrl => $composableBuilder(
    column: $table.filePathOrUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AyahAudioTableAnnotationComposer
    extends Composer<_$UserDatabase, $AyahAudioTable> {
  $$AyahAudioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get reciterId =>
      $composableBuilder(column: $table.reciterId, builder: (column) => column);

  GeneratedColumn<String> get filePathOrUrl => $composableBuilder(
    column: $table.filePathOrUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$AyahAudioTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $AyahAudioTable,
          AyahAudioData,
          $$AyahAudioTableFilterComposer,
          $$AyahAudioTableOrderingComposer,
          $$AyahAudioTableAnnotationComposer,
          $$AyahAudioTableCreateCompanionBuilder,
          $$AyahAudioTableUpdateCompanionBuilder,
          (
            AyahAudioData,
            BaseReferences<_$UserDatabase, $AyahAudioTable, AyahAudioData>,
          ),
          AyahAudioData,
          PrefetchHooks Function()
        > {
  $$AyahAudioTableTableManager(_$UserDatabase db, $AyahAudioTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahAudioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahAudioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahAudioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> ayahId = const Value.absent(),
                Value<int> reciterId = const Value.absent(),
                Value<String> filePathOrUrl = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyahAudioCompanion(
                ayahId: ayahId,
                reciterId: reciterId,
                filePathOrUrl: filePathOrUrl,
                durationMs: durationMs,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int ayahId,
                required int reciterId,
                required String filePathOrUrl,
                Value<int?> durationMs = const Value.absent(),
                Value<int?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyahAudioCompanion.insert(
                ayahId: ayahId,
                reciterId: reciterId,
                filePathOrUrl: filePathOrUrl,
                durationMs: durationMs,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AyahAudioTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $AyahAudioTable,
      AyahAudioData,
      $$AyahAudioTableFilterComposer,
      $$AyahAudioTableOrderingComposer,
      $$AyahAudioTableAnnotationComposer,
      $$AyahAudioTableCreateCompanionBuilder,
      $$AyahAudioTableUpdateCompanionBuilder,
      (
        AyahAudioData,
        BaseReferences<_$UserDatabase, $AyahAudioTable, AyahAudioData>,
      ),
      AyahAudioData,
      PrefetchHooks Function()
    >;
typedef $$ReadingLogTableCreateCompanionBuilder =
    ReadingLogCompanion Function({
      Value<int> id,
      required int epochDay,
      required int juz,
      required int ayahId,
      required int createdAt,
    });
typedef $$ReadingLogTableUpdateCompanionBuilder =
    ReadingLogCompanion Function({
      Value<int> id,
      Value<int> epochDay,
      Value<int> juz,
      Value<int> ayahId,
      Value<int> createdAt,
    });

class $$ReadingLogTableFilterComposer
    extends Composer<_$UserDatabase, $ReadingLogTable> {
  $$ReadingLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get epochDay => $composableBuilder(
    column: $table.epochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingLogTableOrderingComposer
    extends Composer<_$UserDatabase, $ReadingLogTable> {
  $$ReadingLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get epochDay => $composableBuilder(
    column: $table.epochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingLogTableAnnotationComposer
    extends Composer<_$UserDatabase, $ReadingLogTable> {
  $$ReadingLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get epochDay =>
      $composableBuilder(column: $table.epochDay, builder: (column) => column);

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReadingLogTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ReadingLogTable,
          ReadingLogEntry,
          $$ReadingLogTableFilterComposer,
          $$ReadingLogTableOrderingComposer,
          $$ReadingLogTableAnnotationComposer,
          $$ReadingLogTableCreateCompanionBuilder,
          $$ReadingLogTableUpdateCompanionBuilder,
          (
            ReadingLogEntry,
            BaseReferences<_$UserDatabase, $ReadingLogTable, ReadingLogEntry>,
          ),
          ReadingLogEntry,
          PrefetchHooks Function()
        > {
  $$ReadingLogTableTableManager(_$UserDatabase db, $ReadingLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> epochDay = const Value.absent(),
                Value<int> juz = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => ReadingLogCompanion(
                id: id,
                epochDay: epochDay,
                juz: juz,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int epochDay,
                required int juz,
                required int ayahId,
                required int createdAt,
              }) => ReadingLogCompanion.insert(
                id: id,
                epochDay: epochDay,
                juz: juz,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingLogTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ReadingLogTable,
      ReadingLogEntry,
      $$ReadingLogTableFilterComposer,
      $$ReadingLogTableOrderingComposer,
      $$ReadingLogTableAnnotationComposer,
      $$ReadingLogTableCreateCompanionBuilder,
      $$ReadingLogTableUpdateCompanionBuilder,
      (
        ReadingLogEntry,
        BaseReferences<_$UserDatabase, $ReadingLogTable, ReadingLogEntry>,
      ),
      ReadingLogEntry,
      PrefetchHooks Function()
    >;
typedef $$SajdaLogTableCreateCompanionBuilder =
    SajdaLogCompanion Function({
      Value<int> id,
      required int ayahId,
      required int createdAt,
    });
typedef $$SajdaLogTableUpdateCompanionBuilder =
    SajdaLogCompanion Function({
      Value<int> id,
      Value<int> ayahId,
      Value<int> createdAt,
    });

class $$SajdaLogTableFilterComposer
    extends Composer<_$UserDatabase, $SajdaLogTable> {
  $$SajdaLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SajdaLogTableOrderingComposer
    extends Composer<_$UserDatabase, $SajdaLogTable> {
  $$SajdaLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SajdaLogTableAnnotationComposer
    extends Composer<_$UserDatabase, $SajdaLogTable> {
  $$SajdaLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SajdaLogTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SajdaLogTable,
          SajdaLogEntry,
          $$SajdaLogTableFilterComposer,
          $$SajdaLogTableOrderingComposer,
          $$SajdaLogTableAnnotationComposer,
          $$SajdaLogTableCreateCompanionBuilder,
          $$SajdaLogTableUpdateCompanionBuilder,
          (
            SajdaLogEntry,
            BaseReferences<_$UserDatabase, $SajdaLogTable, SajdaLogEntry>,
          ),
          SajdaLogEntry,
          PrefetchHooks Function()
        > {
  $$SajdaLogTableTableManager(_$UserDatabase db, $SajdaLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SajdaLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SajdaLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SajdaLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => SajdaLogCompanion(
                id: id,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ayahId,
                required int createdAt,
              }) => SajdaLogCompanion.insert(
                id: id,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SajdaLogTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SajdaLogTable,
      SajdaLogEntry,
      $$SajdaLogTableFilterComposer,
      $$SajdaLogTableOrderingComposer,
      $$SajdaLogTableAnnotationComposer,
      $$SajdaLogTableCreateCompanionBuilder,
      $$SajdaLogTableUpdateCompanionBuilder,
      (
        SajdaLogEntry,
        BaseReferences<_$UserDatabase, $SajdaLogTable, SajdaLogEntry>,
      ),
      SajdaLogEntry,
      PrefetchHooks Function()
    >;
typedef $$KhatamTargetsTableCreateCompanionBuilder =
    KhatamTargetsCompanion Function({
      Value<int> id,
      Value<int?> targetDate,
      required int startDate,
      required int createdAt,
    });
typedef $$KhatamTargetsTableUpdateCompanionBuilder =
    KhatamTargetsCompanion Function({
      Value<int> id,
      Value<int?> targetDate,
      Value<int> startDate,
      Value<int> createdAt,
    });

class $$KhatamTargetsTableFilterComposer
    extends Composer<_$UserDatabase, $KhatamTargetsTable> {
  $$KhatamTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KhatamTargetsTableOrderingComposer
    extends Composer<_$UserDatabase, $KhatamTargetsTable> {
  $$KhatamTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KhatamTargetsTableAnnotationComposer
    extends Composer<_$UserDatabase, $KhatamTargetsTable> {
  $$KhatamTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$KhatamTargetsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $KhatamTargetsTable,
          KhatamTarget,
          $$KhatamTargetsTableFilterComposer,
          $$KhatamTargetsTableOrderingComposer,
          $$KhatamTargetsTableAnnotationComposer,
          $$KhatamTargetsTableCreateCompanionBuilder,
          $$KhatamTargetsTableUpdateCompanionBuilder,
          (
            KhatamTarget,
            BaseReferences<_$UserDatabase, $KhatamTargetsTable, KhatamTarget>,
          ),
          KhatamTarget,
          PrefetchHooks Function()
        > {
  $$KhatamTargetsTableTableManager(_$UserDatabase db, $KhatamTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KhatamTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KhatamTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KhatamTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> targetDate = const Value.absent(),
                Value<int> startDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => KhatamTargetsCompanion(
                id: id,
                targetDate: targetDate,
                startDate: startDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> targetDate = const Value.absent(),
                required int startDate,
                required int createdAt,
              }) => KhatamTargetsCompanion.insert(
                id: id,
                targetDate: targetDate,
                startDate: startDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KhatamTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $KhatamTargetsTable,
      KhatamTarget,
      $$KhatamTargetsTableFilterComposer,
      $$KhatamTargetsTableOrderingComposer,
      $$KhatamTargetsTableAnnotationComposer,
      $$KhatamTargetsTableCreateCompanionBuilder,
      $$KhatamTargetsTableUpdateCompanionBuilder,
      (
        KhatamTarget,
        BaseReferences<_$UserDatabase, $KhatamTargetsTable, KhatamTarget>,
      ),
      KhatamTarget,
      PrefetchHooks Function()
    >;
typedef $$SurahPositionsTableCreateCompanionBuilder =
    SurahPositionsCompanion Function({
      Value<int> surahId,
      required int ayahId,
      required int updatedAt,
    });
typedef $$SurahPositionsTableUpdateCompanionBuilder =
    SurahPositionsCompanion Function({
      Value<int> surahId,
      Value<int> ayahId,
      Value<int> updatedAt,
    });

class $$SurahPositionsTableFilterComposer
    extends Composer<_$UserDatabase, $SurahPositionsTable> {
  $$SurahPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SurahPositionsTableOrderingComposer
    extends Composer<_$UserDatabase, $SurahPositionsTable> {
  $$SurahPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurahPositionsTableAnnotationComposer
    extends Composer<_$UserDatabase, $SurahPositionsTable> {
  $$SurahPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SurahPositionsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SurahPositionsTable,
          SurahPosition,
          $$SurahPositionsTableFilterComposer,
          $$SurahPositionsTableOrderingComposer,
          $$SurahPositionsTableAnnotationComposer,
          $$SurahPositionsTableCreateCompanionBuilder,
          $$SurahPositionsTableUpdateCompanionBuilder,
          (
            SurahPosition,
            BaseReferences<_$UserDatabase, $SurahPositionsTable, SurahPosition>,
          ),
          SurahPosition,
          PrefetchHooks Function()
        > {
  $$SurahPositionsTableTableManager(
    _$UserDatabase db,
    $SurahPositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> surahId = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => SurahPositionsCompanion(
                surahId: surahId,
                ayahId: ayahId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> surahId = const Value.absent(),
                required int ayahId,
                required int updatedAt,
              }) => SurahPositionsCompanion.insert(
                surahId: surahId,
                ayahId: ayahId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SurahPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SurahPositionsTable,
      SurahPosition,
      $$SurahPositionsTableFilterComposer,
      $$SurahPositionsTableOrderingComposer,
      $$SurahPositionsTableAnnotationComposer,
      $$SurahPositionsTableCreateCompanionBuilder,
      $$SurahPositionsTableUpdateCompanionBuilder,
      (
        SurahPosition,
        BaseReferences<_$UserDatabase, $SurahPositionsTable, SurahPosition>,
      ),
      SurahPosition,
      PrefetchHooks Function()
    >;
typedef $$DoaBookmarksTableCreateCompanionBuilder =
    DoaBookmarksCompanion Function({
      required String doaId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$DoaBookmarksTableUpdateCompanionBuilder =
    DoaBookmarksCompanion Function({
      Value<String> doaId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$DoaBookmarksTableFilterComposer
    extends Composer<_$UserDatabase, $DoaBookmarksTable> {
  $$DoaBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get doaId => $composableBuilder(
    column: $table.doaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DoaBookmarksTableOrderingComposer
    extends Composer<_$UserDatabase, $DoaBookmarksTable> {
  $$DoaBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get doaId => $composableBuilder(
    column: $table.doaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DoaBookmarksTableAnnotationComposer
    extends Composer<_$UserDatabase, $DoaBookmarksTable> {
  $$DoaBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get doaId =>
      $composableBuilder(column: $table.doaId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DoaBookmarksTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $DoaBookmarksTable,
          DoaBookmark,
          $$DoaBookmarksTableFilterComposer,
          $$DoaBookmarksTableOrderingComposer,
          $$DoaBookmarksTableAnnotationComposer,
          $$DoaBookmarksTableCreateCompanionBuilder,
          $$DoaBookmarksTableUpdateCompanionBuilder,
          (
            DoaBookmark,
            BaseReferences<_$UserDatabase, $DoaBookmarksTable, DoaBookmark>,
          ),
          DoaBookmark,
          PrefetchHooks Function()
        > {
  $$DoaBookmarksTableTableManager(_$UserDatabase db, $DoaBookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoaBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoaBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoaBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> doaId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoaBookmarksCompanion(
                doaId: doaId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String doaId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DoaBookmarksCompanion.insert(
                doaId: doaId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DoaBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $DoaBookmarksTable,
      DoaBookmark,
      $$DoaBookmarksTableFilterComposer,
      $$DoaBookmarksTableOrderingComposer,
      $$DoaBookmarksTableAnnotationComposer,
      $$DoaBookmarksTableCreateCompanionBuilder,
      $$DoaBookmarksTableUpdateCompanionBuilder,
      (
        DoaBookmark,
        BaseReferences<_$UserDatabase, $DoaBookmarksTable, DoaBookmark>,
      ),
      DoaBookmark,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$LastReadsTableTableManager get lastReads =>
      $$LastReadsTableTableManager(_db, _db.lastReads);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$RecitersTableTableManager get reciters =>
      $$RecitersTableTableManager(_db, _db.reciters);
  $$AyahAudioTableTableManager get ayahAudio =>
      $$AyahAudioTableTableManager(_db, _db.ayahAudio);
  $$ReadingLogTableTableManager get readingLog =>
      $$ReadingLogTableTableManager(_db, _db.readingLog);
  $$SajdaLogTableTableManager get sajdaLog =>
      $$SajdaLogTableTableManager(_db, _db.sajdaLog);
  $$KhatamTargetsTableTableManager get khatamTargets =>
      $$KhatamTargetsTableTableManager(_db, _db.khatamTargets);
  $$SurahPositionsTableTableManager get surahPositions =>
      $$SurahPositionsTableTableManager(_db, _db.surahPositions);
  $$DoaBookmarksTableTableManager get doaBookmarks =>
      $$DoaBookmarksTableTableManager(_db, _db.doaBookmarks);
}
