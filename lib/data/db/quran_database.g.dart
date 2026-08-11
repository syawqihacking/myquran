// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_database.dart';

// ignore_for_file: type=lint
class $SurahsTable extends Surahs with TableInfo<$SurahsTable, Surah> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameLatinMeta = const VerificationMeta(
    'nameLatin',
  );
  @override
  late final GeneratedColumn<String> nameLatin = GeneratedColumn<String>(
    'name_latin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameIndonesianMeta = const VerificationMeta(
    'nameIndonesian',
  );
  @override
  late final GeneratedColumn<String> nameIndonesian = GeneratedColumn<String>(
    'name_indonesian',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revelationTypeMeta = const VerificationMeta(
    'revelationType',
  );
  @override
  late final GeneratedColumn<int> revelationType = GeneratedColumn<int>(
    'revelation_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahCountMeta = const VerificationMeta(
    'ayahCount',
  );
  @override
  late final GeneratedColumn<int> ayahCount = GeneratedColumn<int>(
    'ayah_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstJuzMeta = const VerificationMeta(
    'firstJuz',
  );
  @override
  late final GeneratedColumn<int> firstJuz = GeneratedColumn<int>(
    'first_juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstPageMeta = const VerificationMeta(
    'firstPage',
  );
  @override
  late final GeneratedColumn<int> firstPage = GeneratedColumn<int>(
    'first_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasBismillahMeta = const VerificationMeta(
    'hasBismillah',
  );
  @override
  late final GeneratedColumn<int> hasBismillah = GeneratedColumn<int>(
    'has_bismillah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameArabic,
    nameLatin,
    nameIndonesian,
    revelationType,
    ayahCount,
    firstJuz,
    firstPage,
    hasBismillah,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Surah> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_latin')) {
      context.handle(
        _nameLatinMeta,
        nameLatin.isAcceptableOrUnknown(data['name_latin']!, _nameLatinMeta),
      );
    } else if (isInserting) {
      context.missing(_nameLatinMeta);
    }
    if (data.containsKey('name_indonesian')) {
      context.handle(
        _nameIndonesianMeta,
        nameIndonesian.isAcceptableOrUnknown(
          data['name_indonesian']!,
          _nameIndonesianMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameIndonesianMeta);
    }
    if (data.containsKey('revelation_type')) {
      context.handle(
        _revelationTypeMeta,
        revelationType.isAcceptableOrUnknown(
          data['revelation_type']!,
          _revelationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revelationTypeMeta);
    }
    if (data.containsKey('ayah_count')) {
      context.handle(
        _ayahCountMeta,
        ayahCount.isAcceptableOrUnknown(data['ayah_count']!, _ayahCountMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahCountMeta);
    }
    if (data.containsKey('first_juz')) {
      context.handle(
        _firstJuzMeta,
        firstJuz.isAcceptableOrUnknown(data['first_juz']!, _firstJuzMeta),
      );
    } else if (isInserting) {
      context.missing(_firstJuzMeta);
    }
    if (data.containsKey('first_page')) {
      context.handle(
        _firstPageMeta,
        firstPage.isAcceptableOrUnknown(data['first_page']!, _firstPageMeta),
      );
    } else if (isInserting) {
      context.missing(_firstPageMeta);
    }
    if (data.containsKey('has_bismillah')) {
      context.handle(
        _hasBismillahMeta,
        hasBismillah.isAcceptableOrUnknown(
          data['has_bismillah']!,
          _hasBismillahMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasBismillahMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Surah map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Surah(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameLatin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_latin'],
      )!,
      nameIndonesian: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_indonesian'],
      )!,
      revelationType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revelation_type'],
      )!,
      ayahCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_count'],
      )!,
      firstJuz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_juz'],
      )!,
      firstPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_page'],
      )!,
      hasBismillah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}has_bismillah'],
      )!,
    );
  }

  @override
  $SurahsTable createAlias(String alias) {
    return $SurahsTable(attachedDatabase, alias);
  }
}

class Surah extends DataClass implements Insertable<Surah> {
  final int id;
  final String nameArabic;
  final String nameLatin;
  final String nameIndonesian;
  final int revelationType;
  final int ayahCount;
  final int firstJuz;
  final int firstPage;
  final int hasBismillah;
  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameLatin,
    required this.nameIndonesian,
    required this.revelationType,
    required this.ayahCount,
    required this.firstJuz,
    required this.firstPage,
    required this.hasBismillah,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_latin'] = Variable<String>(nameLatin);
    map['name_indonesian'] = Variable<String>(nameIndonesian);
    map['revelation_type'] = Variable<int>(revelationType);
    map['ayah_count'] = Variable<int>(ayahCount);
    map['first_juz'] = Variable<int>(firstJuz);
    map['first_page'] = Variable<int>(firstPage);
    map['has_bismillah'] = Variable<int>(hasBismillah);
    return map;
  }

  SurahsCompanion toCompanion(bool nullToAbsent) {
    return SurahsCompanion(
      id: Value(id),
      nameArabic: Value(nameArabic),
      nameLatin: Value(nameLatin),
      nameIndonesian: Value(nameIndonesian),
      revelationType: Value(revelationType),
      ayahCount: Value(ayahCount),
      firstJuz: Value(firstJuz),
      firstPage: Value(firstPage),
      hasBismillah: Value(hasBismillah),
    );
  }

  factory Surah.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Surah(
      id: serializer.fromJson<int>(json['id']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameLatin: serializer.fromJson<String>(json['nameLatin']),
      nameIndonesian: serializer.fromJson<String>(json['nameIndonesian']),
      revelationType: serializer.fromJson<int>(json['revelationType']),
      ayahCount: serializer.fromJson<int>(json['ayahCount']),
      firstJuz: serializer.fromJson<int>(json['firstJuz']),
      firstPage: serializer.fromJson<int>(json['firstPage']),
      hasBismillah: serializer.fromJson<int>(json['hasBismillah']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameLatin': serializer.toJson<String>(nameLatin),
      'nameIndonesian': serializer.toJson<String>(nameIndonesian),
      'revelationType': serializer.toJson<int>(revelationType),
      'ayahCount': serializer.toJson<int>(ayahCount),
      'firstJuz': serializer.toJson<int>(firstJuz),
      'firstPage': serializer.toJson<int>(firstPage),
      'hasBismillah': serializer.toJson<int>(hasBismillah),
    };
  }

  Surah copyWith({
    int? id,
    String? nameArabic,
    String? nameLatin,
    String? nameIndonesian,
    int? revelationType,
    int? ayahCount,
    int? firstJuz,
    int? firstPage,
    int? hasBismillah,
  }) => Surah(
    id: id ?? this.id,
    nameArabic: nameArabic ?? this.nameArabic,
    nameLatin: nameLatin ?? this.nameLatin,
    nameIndonesian: nameIndonesian ?? this.nameIndonesian,
    revelationType: revelationType ?? this.revelationType,
    ayahCount: ayahCount ?? this.ayahCount,
    firstJuz: firstJuz ?? this.firstJuz,
    firstPage: firstPage ?? this.firstPage,
    hasBismillah: hasBismillah ?? this.hasBismillah,
  );
  Surah copyWithCompanion(SurahsCompanion data) {
    return Surah(
      id: data.id.present ? data.id.value : this.id,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameLatin: data.nameLatin.present ? data.nameLatin.value : this.nameLatin,
      nameIndonesian: data.nameIndonesian.present
          ? data.nameIndonesian.value
          : this.nameIndonesian,
      revelationType: data.revelationType.present
          ? data.revelationType.value
          : this.revelationType,
      ayahCount: data.ayahCount.present ? data.ayahCount.value : this.ayahCount,
      firstJuz: data.firstJuz.present ? data.firstJuz.value : this.firstJuz,
      firstPage: data.firstPage.present ? data.firstPage.value : this.firstPage,
      hasBismillah: data.hasBismillah.present
          ? data.hasBismillah.value
          : this.hasBismillah,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Surah(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameLatin: $nameLatin, ')
          ..write('nameIndonesian: $nameIndonesian, ')
          ..write('revelationType: $revelationType, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('firstJuz: $firstJuz, ')
          ..write('firstPage: $firstPage, ')
          ..write('hasBismillah: $hasBismillah')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nameArabic,
    nameLatin,
    nameIndonesian,
    revelationType,
    ayahCount,
    firstJuz,
    firstPage,
    hasBismillah,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Surah &&
          other.id == this.id &&
          other.nameArabic == this.nameArabic &&
          other.nameLatin == this.nameLatin &&
          other.nameIndonesian == this.nameIndonesian &&
          other.revelationType == this.revelationType &&
          other.ayahCount == this.ayahCount &&
          other.firstJuz == this.firstJuz &&
          other.firstPage == this.firstPage &&
          other.hasBismillah == this.hasBismillah);
}

class SurahsCompanion extends UpdateCompanion<Surah> {
  final Value<int> id;
  final Value<String> nameArabic;
  final Value<String> nameLatin;
  final Value<String> nameIndonesian;
  final Value<int> revelationType;
  final Value<int> ayahCount;
  final Value<int> firstJuz;
  final Value<int> firstPage;
  final Value<int> hasBismillah;
  const SurahsCompanion({
    this.id = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameLatin = const Value.absent(),
    this.nameIndonesian = const Value.absent(),
    this.revelationType = const Value.absent(),
    this.ayahCount = const Value.absent(),
    this.firstJuz = const Value.absent(),
    this.firstPage = const Value.absent(),
    this.hasBismillah = const Value.absent(),
  });
  SurahsCompanion.insert({
    this.id = const Value.absent(),
    required String nameArabic,
    required String nameLatin,
    required String nameIndonesian,
    required int revelationType,
    required int ayahCount,
    required int firstJuz,
    required int firstPage,
    required int hasBismillah,
  }) : nameArabic = Value(nameArabic),
       nameLatin = Value(nameLatin),
       nameIndonesian = Value(nameIndonesian),
       revelationType = Value(revelationType),
       ayahCount = Value(ayahCount),
       firstJuz = Value(firstJuz),
       firstPage = Value(firstPage),
       hasBismillah = Value(hasBismillah);
  static Insertable<Surah> custom({
    Expression<int>? id,
    Expression<String>? nameArabic,
    Expression<String>? nameLatin,
    Expression<String>? nameIndonesian,
    Expression<int>? revelationType,
    Expression<int>? ayahCount,
    Expression<int>? firstJuz,
    Expression<int>? firstPage,
    Expression<int>? hasBismillah,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameLatin != null) 'name_latin': nameLatin,
      if (nameIndonesian != null) 'name_indonesian': nameIndonesian,
      if (revelationType != null) 'revelation_type': revelationType,
      if (ayahCount != null) 'ayah_count': ayahCount,
      if (firstJuz != null) 'first_juz': firstJuz,
      if (firstPage != null) 'first_page': firstPage,
      if (hasBismillah != null) 'has_bismillah': hasBismillah,
    });
  }

  SurahsCompanion copyWith({
    Value<int>? id,
    Value<String>? nameArabic,
    Value<String>? nameLatin,
    Value<String>? nameIndonesian,
    Value<int>? revelationType,
    Value<int>? ayahCount,
    Value<int>? firstJuz,
    Value<int>? firstPage,
    Value<int>? hasBismillah,
  }) {
    return SurahsCompanion(
      id: id ?? this.id,
      nameArabic: nameArabic ?? this.nameArabic,
      nameLatin: nameLatin ?? this.nameLatin,
      nameIndonesian: nameIndonesian ?? this.nameIndonesian,
      revelationType: revelationType ?? this.revelationType,
      ayahCount: ayahCount ?? this.ayahCount,
      firstJuz: firstJuz ?? this.firstJuz,
      firstPage: firstPage ?? this.firstPage,
      hasBismillah: hasBismillah ?? this.hasBismillah,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameLatin.present) {
      map['name_latin'] = Variable<String>(nameLatin.value);
    }
    if (nameIndonesian.present) {
      map['name_indonesian'] = Variable<String>(nameIndonesian.value);
    }
    if (revelationType.present) {
      map['revelation_type'] = Variable<int>(revelationType.value);
    }
    if (ayahCount.present) {
      map['ayah_count'] = Variable<int>(ayahCount.value);
    }
    if (firstJuz.present) {
      map['first_juz'] = Variable<int>(firstJuz.value);
    }
    if (firstPage.present) {
      map['first_page'] = Variable<int>(firstPage.value);
    }
    if (hasBismillah.present) {
      map['has_bismillah'] = Variable<int>(hasBismillah.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahsCompanion(')
          ..write('id: $id, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameLatin: $nameLatin, ')
          ..write('nameIndonesian: $nameIndonesian, ')
          ..write('revelationType: $revelationType, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('firstJuz: $firstJuz, ')
          ..write('firstPage: $firstPage, ')
          ..write('hasBismillah: $hasBismillah')
          ..write(')'))
        .toString();
  }
}

class $AyahsTable extends Ayahs with TableInfo<$AyahsTable, Ayah> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textUthmaniMeta = const VerificationMeta(
    'textUthmani',
  );
  @override
  late final GeneratedColumn<String> textUthmani = GeneratedColumn<String>(
    'text_uthmani',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sajdaMeta = const VerificationMeta('sajda');
  @override
  late final GeneratedColumn<int> sajda = GeneratedColumn<int>(
    'sajda',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahId,
    ayahNumber,
    textUthmani,
    translation,
    juz,
    page,
    sajda,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ayah> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('text_uthmani')) {
      context.handle(
        _textUthmaniMeta,
        textUthmani.isAcceptableOrUnknown(
          data['text_uthmani']!,
          _textUthmaniMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textUthmaniMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('sajda')) {
      context.handle(
        _sajdaMeta,
        sajda.isAcceptableOrUnknown(data['sajda']!, _sajdaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {surahId, ayahNumber},
  ];
  @override
  Ayah map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ayah(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      textUthmani: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_uthmani'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      sajda: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sajda'],
      )!,
    );
  }

  @override
  $AyahsTable createAlias(String alias) {
    return $AyahsTable(attachedDatabase, alias);
  }
}

class Ayah extends DataClass implements Insertable<Ayah> {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String textUthmani;
  final String translation;
  final int juz;
  final int page;
  final int sajda;
  const Ayah({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textUthmani,
    required this.translation,
    required this.juz,
    required this.page,
    required this.sajda,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['text_uthmani'] = Variable<String>(textUthmani);
    map['translation'] = Variable<String>(translation);
    map['juz'] = Variable<int>(juz);
    map['page'] = Variable<int>(page);
    map['sajda'] = Variable<int>(sajda);
    return map;
  }

  AyahsCompanion toCompanion(bool nullToAbsent) {
    return AyahsCompanion(
      id: Value(id),
      surahId: Value(surahId),
      ayahNumber: Value(ayahNumber),
      textUthmani: Value(textUthmani),
      translation: Value(translation),
      juz: Value(juz),
      page: Value(page),
      sajda: Value(sajda),
    );
  }

  factory Ayah.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ayah(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      textUthmani: serializer.fromJson<String>(json['textUthmani']),
      translation: serializer.fromJson<String>(json['translation']),
      juz: serializer.fromJson<int>(json['juz']),
      page: serializer.fromJson<int>(json['page']),
      sajda: serializer.fromJson<int>(json['sajda']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'textUthmani': serializer.toJson<String>(textUthmani),
      'translation': serializer.toJson<String>(translation),
      'juz': serializer.toJson<int>(juz),
      'page': serializer.toJson<int>(page),
      'sajda': serializer.toJson<int>(sajda),
    };
  }

  Ayah copyWith({
    int? id,
    int? surahId,
    int? ayahNumber,
    String? textUthmani,
    String? translation,
    int? juz,
    int? page,
    int? sajda,
  }) => Ayah(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    textUthmani: textUthmani ?? this.textUthmani,
    translation: translation ?? this.translation,
    juz: juz ?? this.juz,
    page: page ?? this.page,
    sajda: sajda ?? this.sajda,
  );
  Ayah copyWithCompanion(AyahsCompanion data) {
    return Ayah(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      textUthmani: data.textUthmani.present
          ? data.textUthmani.value
          : this.textUthmani,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      juz: data.juz.present ? data.juz.value : this.juz,
      page: data.page.present ? data.page.value : this.page,
      sajda: data.sajda.present ? data.sajda.value : this.sajda,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ayah(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('translation: $translation, ')
          ..write('juz: $juz, ')
          ..write('page: $page, ')
          ..write('sajda: $sajda')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surahId,
    ayahNumber,
    textUthmani,
    translation,
    juz,
    page,
    sajda,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ayah &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.ayahNumber == this.ayahNumber &&
          other.textUthmani == this.textUthmani &&
          other.translation == this.translation &&
          other.juz == this.juz &&
          other.page == this.page &&
          other.sajda == this.sajda);
}

class AyahsCompanion extends UpdateCompanion<Ayah> {
  final Value<int> id;
  final Value<int> surahId;
  final Value<int> ayahNumber;
  final Value<String> textUthmani;
  final Value<String> translation;
  final Value<int> juz;
  final Value<int> page;
  final Value<int> sajda;
  const AyahsCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.translation = const Value.absent(),
    this.juz = const Value.absent(),
    this.page = const Value.absent(),
    this.sajda = const Value.absent(),
  });
  AyahsCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required int ayahNumber,
    required String textUthmani,
    required String translation,
    required int juz,
    required int page,
    this.sajda = const Value.absent(),
  }) : surahId = Value(surahId),
       ayahNumber = Value(ayahNumber),
       textUthmani = Value(textUthmani),
       translation = Value(translation),
       juz = Value(juz),
       page = Value(page);
  static Insertable<Ayah> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<int>? ayahNumber,
    Expression<String>? textUthmani,
    Expression<String>? translation,
    Expression<int>? juz,
    Expression<int>? page,
    Expression<int>? sajda,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (textUthmani != null) 'text_uthmani': textUthmani,
      if (translation != null) 'translation': translation,
      if (juz != null) 'juz': juz,
      if (page != null) 'page': page,
      if (sajda != null) 'sajda': sajda,
    });
  }

  AyahsCompanion copyWith({
    Value<int>? id,
    Value<int>? surahId,
    Value<int>? ayahNumber,
    Value<String>? textUthmani,
    Value<String>? translation,
    Value<int>? juz,
    Value<int>? page,
    Value<int>? sajda,
  }) {
    return AyahsCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      textUthmani: textUthmani ?? this.textUthmani,
      translation: translation ?? this.translation,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      sajda: sajda ?? this.sajda,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (textUthmani.present) {
      map['text_uthmani'] = Variable<String>(textUthmani.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (sajda.present) {
      map['sajda'] = Variable<int>(sajda.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahsCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('translation: $translation, ')
          ..write('juz: $juz, ')
          ..write('page: $page, ')
          ..write('sajda: $sajda')
          ..write(')'))
        .toString();
  }
}

class $TafsirsTable extends Tafsirs with TableInfo<$TafsirsTable, Tafsir> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TafsirsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textShortMeta = const VerificationMeta(
    'textShort',
  );
  @override
  late final GeneratedColumn<String> textShort = GeneratedColumn<String>(
    'text_short',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textLongMeta = const VerificationMeta(
    'textLong',
  );
  @override
  late final GeneratedColumn<String> textLong = GeneratedColumn<String>(
    'text_long',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ayahId, textShort, textLong];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tafsir';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tafsir> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    }
    if (data.containsKey('text_short')) {
      context.handle(
        _textShortMeta,
        textShort.isAcceptableOrUnknown(data['text_short']!, _textShortMeta),
      );
    } else if (isInserting) {
      context.missing(_textShortMeta);
    }
    if (data.containsKey('text_long')) {
      context.handle(
        _textLongMeta,
        textLong.isAcceptableOrUnknown(data['text_long']!, _textLongMeta),
      );
    } else if (isInserting) {
      context.missing(_textLongMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ayahId};
  @override
  Tafsir map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tafsir(
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      textShort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_short'],
      )!,
      textLong: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_long'],
      )!,
    );
  }

  @override
  $TafsirsTable createAlias(String alias) {
    return $TafsirsTable(attachedDatabase, alias);
  }
}

class Tafsir extends DataClass implements Insertable<Tafsir> {
  final int ayahId;
  final String textShort;
  final String textLong;
  const Tafsir({
    required this.ayahId,
    required this.textShort,
    required this.textLong,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ayah_id'] = Variable<int>(ayahId);
    map['text_short'] = Variable<String>(textShort);
    map['text_long'] = Variable<String>(textLong);
    return map;
  }

  TafsirsCompanion toCompanion(bool nullToAbsent) {
    return TafsirsCompanion(
      ayahId: Value(ayahId),
      textShort: Value(textShort),
      textLong: Value(textLong),
    );
  }

  factory Tafsir.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tafsir(
      ayahId: serializer.fromJson<int>(json['ayahId']),
      textShort: serializer.fromJson<String>(json['textShort']),
      textLong: serializer.fromJson<String>(json['textLong']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ayahId': serializer.toJson<int>(ayahId),
      'textShort': serializer.toJson<String>(textShort),
      'textLong': serializer.toJson<String>(textLong),
    };
  }

  Tafsir copyWith({int? ayahId, String? textShort, String? textLong}) => Tafsir(
    ayahId: ayahId ?? this.ayahId,
    textShort: textShort ?? this.textShort,
    textLong: textLong ?? this.textLong,
  );
  Tafsir copyWithCompanion(TafsirsCompanion data) {
    return Tafsir(
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      textShort: data.textShort.present ? data.textShort.value : this.textShort,
      textLong: data.textLong.present ? data.textLong.value : this.textLong,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tafsir(')
          ..write('ayahId: $ayahId, ')
          ..write('textShort: $textShort, ')
          ..write('textLong: $textLong')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ayahId, textShort, textLong);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tafsir &&
          other.ayahId == this.ayahId &&
          other.textShort == this.textShort &&
          other.textLong == this.textLong);
}

class TafsirsCompanion extends UpdateCompanion<Tafsir> {
  final Value<int> ayahId;
  final Value<String> textShort;
  final Value<String> textLong;
  const TafsirsCompanion({
    this.ayahId = const Value.absent(),
    this.textShort = const Value.absent(),
    this.textLong = const Value.absent(),
  });
  TafsirsCompanion.insert({
    this.ayahId = const Value.absent(),
    required String textShort,
    required String textLong,
  }) : textShort = Value(textShort),
       textLong = Value(textLong);
  static Insertable<Tafsir> custom({
    Expression<int>? ayahId,
    Expression<String>? textShort,
    Expression<String>? textLong,
  }) {
    return RawValuesInsertable({
      if (ayahId != null) 'ayah_id': ayahId,
      if (textShort != null) 'text_short': textShort,
      if (textLong != null) 'text_long': textLong,
    });
  }

  TafsirsCompanion copyWith({
    Value<int>? ayahId,
    Value<String>? textShort,
    Value<String>? textLong,
  }) {
    return TafsirsCompanion(
      ayahId: ayahId ?? this.ayahId,
      textShort: textShort ?? this.textShort,
      textLong: textLong ?? this.textLong,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (textShort.present) {
      map['text_short'] = Variable<String>(textShort.value);
    }
    if (textLong.present) {
      map['text_long'] = Variable<String>(textLong.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TafsirsCompanion(')
          ..write('ayahId: $ayahId, ')
          ..write('textShort: $textShort, ')
          ..write('textLong: $textLong')
          ..write(')'))
        .toString();
  }
}

abstract class _$QuranDatabase extends GeneratedDatabase {
  _$QuranDatabase(QueryExecutor e) : super(e);
  $QuranDatabaseManager get managers => $QuranDatabaseManager(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $AyahsTable ayahs = $AyahsTable(this);
  late final $TafsirsTable tafsirs = $TafsirsTable(this);
  late final Index idxAyahsJuz = Index(
    'idx_ayahs_juz',
    'CREATE INDEX idx_ayahs_juz ON ayahs (juz)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    surahs,
    ayahs,
    tafsirs,
    idxAyahsJuz,
  ];
}

typedef $$SurahsTableCreateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> id,
      required String nameArabic,
      required String nameLatin,
      required String nameIndonesian,
      required int revelationType,
      required int ayahCount,
      required int firstJuz,
      required int firstPage,
      required int hasBismillah,
    });
typedef $$SurahsTableUpdateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> id,
      Value<String> nameArabic,
      Value<String> nameLatin,
      Value<String> nameIndonesian,
      Value<int> revelationType,
      Value<int> ayahCount,
      Value<int> firstJuz,
      Value<int> firstPage,
      Value<int> hasBismillah,
    });

class $$SurahsTableFilterComposer
    extends Composer<_$QuranDatabase, $SurahsTable> {
  $$SurahsTableFilterComposer({
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

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameLatin => $composableBuilder(
    column: $table.nameLatin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameIndonesian => $composableBuilder(
    column: $table.nameIndonesian,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstJuz => $composableBuilder(
    column: $table.firstJuz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstPage => $composableBuilder(
    column: $table.firstPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hasBismillah => $composableBuilder(
    column: $table.hasBismillah,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SurahsTableOrderingComposer
    extends Composer<_$QuranDatabase, $SurahsTable> {
  $$SurahsTableOrderingComposer({
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

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameLatin => $composableBuilder(
    column: $table.nameLatin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameIndonesian => $composableBuilder(
    column: $table.nameIndonesian,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstJuz => $composableBuilder(
    column: $table.firstJuz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstPage => $composableBuilder(
    column: $table.firstPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hasBismillah => $composableBuilder(
    column: $table.hasBismillah,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurahsTableAnnotationComposer
    extends Composer<_$QuranDatabase, $SurahsTable> {
  $$SurahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameLatin =>
      $composableBuilder(column: $table.nameLatin, builder: (column) => column);

  GeneratedColumn<String> get nameIndonesian => $composableBuilder(
    column: $table.nameIndonesian,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revelationType => $composableBuilder(
    column: $table.revelationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahCount =>
      $composableBuilder(column: $table.ayahCount, builder: (column) => column);

  GeneratedColumn<int> get firstJuz =>
      $composableBuilder(column: $table.firstJuz, builder: (column) => column);

  GeneratedColumn<int> get firstPage =>
      $composableBuilder(column: $table.firstPage, builder: (column) => column);

  GeneratedColumn<int> get hasBismillah => $composableBuilder(
    column: $table.hasBismillah,
    builder: (column) => column,
  );
}

class $$SurahsTableTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          $SurahsTable,
          Surah,
          $$SurahsTableFilterComposer,
          $$SurahsTableOrderingComposer,
          $$SurahsTableAnnotationComposer,
          $$SurahsTableCreateCompanionBuilder,
          $$SurahsTableUpdateCompanionBuilder,
          (Surah, BaseReferences<_$QuranDatabase, $SurahsTable, Surah>),
          Surah,
          PrefetchHooks Function()
        > {
  $$SurahsTableTableManager(_$QuranDatabase db, $SurahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameLatin = const Value.absent(),
                Value<String> nameIndonesian = const Value.absent(),
                Value<int> revelationType = const Value.absent(),
                Value<int> ayahCount = const Value.absent(),
                Value<int> firstJuz = const Value.absent(),
                Value<int> firstPage = const Value.absent(),
                Value<int> hasBismillah = const Value.absent(),
              }) => SurahsCompanion(
                id: id,
                nameArabic: nameArabic,
                nameLatin: nameLatin,
                nameIndonesian: nameIndonesian,
                revelationType: revelationType,
                ayahCount: ayahCount,
                firstJuz: firstJuz,
                firstPage: firstPage,
                hasBismillah: hasBismillah,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nameArabic,
                required String nameLatin,
                required String nameIndonesian,
                required int revelationType,
                required int ayahCount,
                required int firstJuz,
                required int firstPage,
                required int hasBismillah,
              }) => SurahsCompanion.insert(
                id: id,
                nameArabic: nameArabic,
                nameLatin: nameLatin,
                nameIndonesian: nameIndonesian,
                revelationType: revelationType,
                ayahCount: ayahCount,
                firstJuz: firstJuz,
                firstPage: firstPage,
                hasBismillah: hasBismillah,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SurahsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      $SurahsTable,
      Surah,
      $$SurahsTableFilterComposer,
      $$SurahsTableOrderingComposer,
      $$SurahsTableAnnotationComposer,
      $$SurahsTableCreateCompanionBuilder,
      $$SurahsTableUpdateCompanionBuilder,
      (Surah, BaseReferences<_$QuranDatabase, $SurahsTable, Surah>),
      Surah,
      PrefetchHooks Function()
    >;
typedef $$AyahsTableCreateCompanionBuilder =
    AyahsCompanion Function({
      Value<int> id,
      required int surahId,
      required int ayahNumber,
      required String textUthmani,
      required String translation,
      required int juz,
      required int page,
      Value<int> sajda,
    });
typedef $$AyahsTableUpdateCompanionBuilder =
    AyahsCompanion Function({
      Value<int> id,
      Value<int> surahId,
      Value<int> ayahNumber,
      Value<String> textUthmani,
      Value<String> translation,
      Value<int> juz,
      Value<int> page,
      Value<int> sajda,
    });

class $$AyahsTableFilterComposer
    extends Composer<_$QuranDatabase, $AyahsTable> {
  $$AyahsTableFilterComposer({
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

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AyahsTableOrderingComposer
    extends Composer<_$QuranDatabase, $AyahsTable> {
  $$AyahsTableOrderingComposer({
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

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AyahsTableAnnotationComposer
    extends Composer<_$QuranDatabase, $AyahsTable> {
  $$AyahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get sajda =>
      $composableBuilder(column: $table.sajda, builder: (column) => column);
}

class $$AyahsTableTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          $AyahsTable,
          Ayah,
          $$AyahsTableFilterComposer,
          $$AyahsTableOrderingComposer,
          $$AyahsTableAnnotationComposer,
          $$AyahsTableCreateCompanionBuilder,
          $$AyahsTableUpdateCompanionBuilder,
          (Ayah, BaseReferences<_$QuranDatabase, $AyahsTable, Ayah>),
          Ayah,
          PrefetchHooks Function()
        > {
  $$AyahsTableTableManager(_$QuranDatabase db, $AyahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> textUthmani = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<int> juz = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> sajda = const Value.absent(),
              }) => AyahsCompanion(
                id: id,
                surahId: surahId,
                ayahNumber: ayahNumber,
                textUthmani: textUthmani,
                translation: translation,
                juz: juz,
                page: page,
                sajda: sajda,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahId,
                required int ayahNumber,
                required String textUthmani,
                required String translation,
                required int juz,
                required int page,
                Value<int> sajda = const Value.absent(),
              }) => AyahsCompanion.insert(
                id: id,
                surahId: surahId,
                ayahNumber: ayahNumber,
                textUthmani: textUthmani,
                translation: translation,
                juz: juz,
                page: page,
                sajda: sajda,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AyahsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      $AyahsTable,
      Ayah,
      $$AyahsTableFilterComposer,
      $$AyahsTableOrderingComposer,
      $$AyahsTableAnnotationComposer,
      $$AyahsTableCreateCompanionBuilder,
      $$AyahsTableUpdateCompanionBuilder,
      (Ayah, BaseReferences<_$QuranDatabase, $AyahsTable, Ayah>),
      Ayah,
      PrefetchHooks Function()
    >;
typedef $$TafsirsTableCreateCompanionBuilder =
    TafsirsCompanion Function({
      Value<int> ayahId,
      required String textShort,
      required String textLong,
    });
typedef $$TafsirsTableUpdateCompanionBuilder =
    TafsirsCompanion Function({
      Value<int> ayahId,
      Value<String> textShort,
      Value<String> textLong,
    });

class $$TafsirsTableFilterComposer
    extends Composer<_$QuranDatabase, $TafsirsTable> {
  $$TafsirsTableFilterComposer({
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

  ColumnFilters<String> get textShort => $composableBuilder(
    column: $table.textShort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textLong => $composableBuilder(
    column: $table.textLong,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TafsirsTableOrderingComposer
    extends Composer<_$QuranDatabase, $TafsirsTable> {
  $$TafsirsTableOrderingComposer({
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

  ColumnOrderings<String> get textShort => $composableBuilder(
    column: $table.textShort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textLong => $composableBuilder(
    column: $table.textLong,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TafsirsTableAnnotationComposer
    extends Composer<_$QuranDatabase, $TafsirsTable> {
  $$TafsirsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<String> get textShort =>
      $composableBuilder(column: $table.textShort, builder: (column) => column);

  GeneratedColumn<String> get textLong =>
      $composableBuilder(column: $table.textLong, builder: (column) => column);
}

class $$TafsirsTableTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          $TafsirsTable,
          Tafsir,
          $$TafsirsTableFilterComposer,
          $$TafsirsTableOrderingComposer,
          $$TafsirsTableAnnotationComposer,
          $$TafsirsTableCreateCompanionBuilder,
          $$TafsirsTableUpdateCompanionBuilder,
          (Tafsir, BaseReferences<_$QuranDatabase, $TafsirsTable, Tafsir>),
          Tafsir,
          PrefetchHooks Function()
        > {
  $$TafsirsTableTableManager(_$QuranDatabase db, $TafsirsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TafsirsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TafsirsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TafsirsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> ayahId = const Value.absent(),
                Value<String> textShort = const Value.absent(),
                Value<String> textLong = const Value.absent(),
              }) => TafsirsCompanion(
                ayahId: ayahId,
                textShort: textShort,
                textLong: textLong,
              ),
          createCompanionCallback:
              ({
                Value<int> ayahId = const Value.absent(),
                required String textShort,
                required String textLong,
              }) => TafsirsCompanion.insert(
                ayahId: ayahId,
                textShort: textShort,
                textLong: textLong,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TafsirsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      $TafsirsTable,
      Tafsir,
      $$TafsirsTableFilterComposer,
      $$TafsirsTableOrderingComposer,
      $$TafsirsTableAnnotationComposer,
      $$TafsirsTableCreateCompanionBuilder,
      $$TafsirsTableUpdateCompanionBuilder,
      (Tafsir, BaseReferences<_$QuranDatabase, $TafsirsTable, Tafsir>),
      Tafsir,
      PrefetchHooks Function()
    >;

class $QuranDatabaseManager {
  final _$QuranDatabase _db;
  $QuranDatabaseManager(this._db);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$AyahsTableTableManager get ayahs =>
      $$AyahsTableTableManager(_db, _db.ayahs);
  $$TafsirsTableTableManager get tafsirs =>
      $$TafsirsTableTableManager(_db, _db.tafsirs);
}
