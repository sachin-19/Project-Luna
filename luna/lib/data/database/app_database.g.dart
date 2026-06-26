// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgCycleDaysMeta = const VerificationMeta(
    'avgCycleDays',
  );
  @override
  late final GeneratedColumn<int> avgCycleDays = GeneratedColumn<int>(
    'avg_cycle_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(28),
  );
  static const VerificationMeta _avgPeriodDaysMeta = const VerificationMeta(
    'avgPeriodDays',
  );
  @override
  late final GeneratedColumn<int> avgPeriodDays = GeneratedColumn<int>(
    'avg_period_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _cycleLengthKnownMeta = const VerificationMeta(
    'cycleLengthKnown',
  );
  @override
  late final GeneratedColumn<bool> cycleLengthKnown = GeneratedColumn<bool>(
    'cycle_length_known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cycle_length_known" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onHormonalContraceptionMeta =
      const VerificationMeta('onHormonalContraception');
  @override
  late final GeneratedColumn<bool> onHormonalContraception =
      GeneratedColumn<bool>(
        'on_hormonal_contraception',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("on_hormonal_contraception" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _hasPcosMeta = const VerificationMeta(
    'hasPcos',
  );
  @override
  late final GeneratedColumn<bool> hasPcos = GeneratedColumn<bool>(
    'has_pcos',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_pcos" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasEndoMeta = const VerificationMeta(
    'hasEndo',
  );
  @override
  late final GeneratedColumn<bool> hasEndo = GeneratedColumn<bool>(
    'has_endo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_endo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trackingGoalsMeta = const VerificationMeta(
    'trackingGoals',
  );
  @override
  late final GeneratedColumn<String> trackingGoals = GeneratedColumn<String>(
    'tracking_goals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commonSymptomsMeta = const VerificationMeta(
    'commonSymptoms',
  );
  @override
  late final GeneratedColumn<String> commonSymptoms = GeneratedColumn<String>(
    'common_symptoms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baselineStressMeta = const VerificationMeta(
    'baselineStress',
  );
  @override
  late final GeneratedColumn<int> baselineStress = GeneratedColumn<int>(
    'baseline_stress',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseFrequencyMeta = const VerificationMeta(
    'exerciseFrequency',
  );
  @override
  late final GeneratedColumn<String> exerciseFrequency =
      GeneratedColumn<String>(
        'exercise_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _preferredLanguageMeta = const VerificationMeta(
    'preferredLanguage',
  );
  @override
  late final GeneratedColumn<String> preferredLanguage =
      GeneratedColumn<String>(
        'preferred_language',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('en'),
      );
  static const VerificationMeta _themeBrightnessMeta = const VerificationMeta(
    'themeBrightness',
  );
  @override
  late final GeneratedColumn<String> themeBrightness = GeneratedColumn<String>(
    'theme_brightness',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dark'),
  );
  static const VerificationMeta _cloudSyncEnabledMeta = const VerificationMeta(
    'cloudSyncEnabled',
  );
  @override
  late final GeneratedColumn<bool> cloudSyncEnabled = GeneratedColumn<bool>(
    'cloud_sync_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cloud_sync_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationsPeriodMeta =
      const VerificationMeta('notificationsPeriod');
  @override
  late final GeneratedColumn<bool> notificationsPeriod = GeneratedColumn<bool>(
    'notifications_period',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_period" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationsOvulationMeta =
      const VerificationMeta('notificationsOvulation');
  @override
  late final GeneratedColumn<bool> notificationsOvulation =
      GeneratedColumn<bool>(
        'notifications_ovulation',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_ovulation" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _notificationsDailyCheckinMeta =
      const VerificationMeta('notificationsDailyCheckin');
  @override
  late final GeneratedColumn<bool> notificationsDailyCheckin =
      GeneratedColumn<bool>(
        'notifications_daily_checkin',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_daily_checkin" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _notificationLeadDaysMeta =
      const VerificationMeta('notificationLeadDays');
  @override
  late final GeneratedColumn<int> notificationLeadDays = GeneratedColumn<int>(
    'notification_lead_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    birthYear,
    avgCycleDays,
    avgPeriodDays,
    cycleLengthKnown,
    onHormonalContraception,
    hasPcos,
    hasEndo,
    trackingGoals,
    commonSymptoms,
    baselineStress,
    exerciseFrequency,
    preferredLanguage,
    themeBrightness,
    cloudSyncEnabled,
    notificationsPeriod,
    notificationsOvulation,
    notificationsDailyCheckin,
    notificationLeadDays,
    onboarded,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    } else if (isInserting) {
      context.missing(_birthYearMeta);
    }
    if (data.containsKey('avg_cycle_days')) {
      context.handle(
        _avgCycleDaysMeta,
        avgCycleDays.isAcceptableOrUnknown(
          data['avg_cycle_days']!,
          _avgCycleDaysMeta,
        ),
      );
    }
    if (data.containsKey('avg_period_days')) {
      context.handle(
        _avgPeriodDaysMeta,
        avgPeriodDays.isAcceptableOrUnknown(
          data['avg_period_days']!,
          _avgPeriodDaysMeta,
        ),
      );
    }
    if (data.containsKey('cycle_length_known')) {
      context.handle(
        _cycleLengthKnownMeta,
        cycleLengthKnown.isAcceptableOrUnknown(
          data['cycle_length_known']!,
          _cycleLengthKnownMeta,
        ),
      );
    }
    if (data.containsKey('on_hormonal_contraception')) {
      context.handle(
        _onHormonalContraceptionMeta,
        onHormonalContraception.isAcceptableOrUnknown(
          data['on_hormonal_contraception']!,
          _onHormonalContraceptionMeta,
        ),
      );
    }
    if (data.containsKey('has_pcos')) {
      context.handle(
        _hasPcosMeta,
        hasPcos.isAcceptableOrUnknown(data['has_pcos']!, _hasPcosMeta),
      );
    }
    if (data.containsKey('has_endo')) {
      context.handle(
        _hasEndoMeta,
        hasEndo.isAcceptableOrUnknown(data['has_endo']!, _hasEndoMeta),
      );
    }
    if (data.containsKey('tracking_goals')) {
      context.handle(
        _trackingGoalsMeta,
        trackingGoals.isAcceptableOrUnknown(
          data['tracking_goals']!,
          _trackingGoalsMeta,
        ),
      );
    }
    if (data.containsKey('common_symptoms')) {
      context.handle(
        _commonSymptomsMeta,
        commonSymptoms.isAcceptableOrUnknown(
          data['common_symptoms']!,
          _commonSymptomsMeta,
        ),
      );
    }
    if (data.containsKey('baseline_stress')) {
      context.handle(
        _baselineStressMeta,
        baselineStress.isAcceptableOrUnknown(
          data['baseline_stress']!,
          _baselineStressMeta,
        ),
      );
    }
    if (data.containsKey('exercise_frequency')) {
      context.handle(
        _exerciseFrequencyMeta,
        exerciseFrequency.isAcceptableOrUnknown(
          data['exercise_frequency']!,
          _exerciseFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('preferred_language')) {
      context.handle(
        _preferredLanguageMeta,
        preferredLanguage.isAcceptableOrUnknown(
          data['preferred_language']!,
          _preferredLanguageMeta,
        ),
      );
    }
    if (data.containsKey('theme_brightness')) {
      context.handle(
        _themeBrightnessMeta,
        themeBrightness.isAcceptableOrUnknown(
          data['theme_brightness']!,
          _themeBrightnessMeta,
        ),
      );
    }
    if (data.containsKey('cloud_sync_enabled')) {
      context.handle(
        _cloudSyncEnabledMeta,
        cloudSyncEnabled.isAcceptableOrUnknown(
          data['cloud_sync_enabled']!,
          _cloudSyncEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notifications_period')) {
      context.handle(
        _notificationsPeriodMeta,
        notificationsPeriod.isAcceptableOrUnknown(
          data['notifications_period']!,
          _notificationsPeriodMeta,
        ),
      );
    }
    if (data.containsKey('notifications_ovulation')) {
      context.handle(
        _notificationsOvulationMeta,
        notificationsOvulation.isAcceptableOrUnknown(
          data['notifications_ovulation']!,
          _notificationsOvulationMeta,
        ),
      );
    }
    if (data.containsKey('notifications_daily_checkin')) {
      context.handle(
        _notificationsDailyCheckinMeta,
        notificationsDailyCheckin.isAcceptableOrUnknown(
          data['notifications_daily_checkin']!,
          _notificationsDailyCheckinMeta,
        ),
      );
    }
    if (data.containsKey('notification_lead_days')) {
      context.handle(
        _notificationLeadDaysMeta,
        notificationLeadDays.isAcceptableOrUnknown(
          data['notification_lead_days']!,
          _notificationLeadDaysMeta,
        ),
      );
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
      );
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
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      )!,
      avgCycleDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cycle_days'],
      )!,
      avgPeriodDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_period_days'],
      )!,
      cycleLengthKnown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cycle_length_known'],
      )!,
      onHormonalContraception: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}on_hormonal_contraception'],
      )!,
      hasPcos: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_pcos'],
      )!,
      hasEndo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_endo'],
      )!,
      trackingGoals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_goals'],
      ),
      commonSymptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_symptoms'],
      ),
      baselineStress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baseline_stress'],
      ),
      exerciseFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_frequency'],
      ),
      preferredLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_language'],
      )!,
      themeBrightness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_brightness'],
      )!,
      cloudSyncEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cloud_sync_enabled'],
      )!,
      notificationsPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_period'],
      )!,
      notificationsOvulation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_ovulation'],
      )!,
      notificationsDailyCheckin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_daily_checkin'],
      )!,
      notificationLeadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_lead_days'],
      )!,
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final int id;
  final String displayName;
  final int birthYear;
  final int avgCycleDays;
  final int avgPeriodDays;
  final bool cycleLengthKnown;
  final bool onHormonalContraception;
  final bool hasPcos;
  final bool hasEndo;
  final String? trackingGoals;
  final String? commonSymptoms;
  final int? baselineStress;
  final String? exerciseFrequency;
  final String preferredLanguage;
  final String themeBrightness;
  final bool cloudSyncEnabled;
  final bool notificationsPeriod;
  final bool notificationsOvulation;
  final bool notificationsDailyCheckin;
  final int notificationLeadDays;
  final bool onboarded;
  final int createdAt;
  const UserRow({
    required this.id,
    required this.displayName,
    required this.birthYear,
    required this.avgCycleDays,
    required this.avgPeriodDays,
    required this.cycleLengthKnown,
    required this.onHormonalContraception,
    required this.hasPcos,
    required this.hasEndo,
    this.trackingGoals,
    this.commonSymptoms,
    this.baselineStress,
    this.exerciseFrequency,
    required this.preferredLanguage,
    required this.themeBrightness,
    required this.cloudSyncEnabled,
    required this.notificationsPeriod,
    required this.notificationsOvulation,
    required this.notificationsDailyCheckin,
    required this.notificationLeadDays,
    required this.onboarded,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['birth_year'] = Variable<int>(birthYear);
    map['avg_cycle_days'] = Variable<int>(avgCycleDays);
    map['avg_period_days'] = Variable<int>(avgPeriodDays);
    map['cycle_length_known'] = Variable<bool>(cycleLengthKnown);
    map['on_hormonal_contraception'] = Variable<bool>(onHormonalContraception);
    map['has_pcos'] = Variable<bool>(hasPcos);
    map['has_endo'] = Variable<bool>(hasEndo);
    if (!nullToAbsent || trackingGoals != null) {
      map['tracking_goals'] = Variable<String>(trackingGoals);
    }
    if (!nullToAbsent || commonSymptoms != null) {
      map['common_symptoms'] = Variable<String>(commonSymptoms);
    }
    if (!nullToAbsent || baselineStress != null) {
      map['baseline_stress'] = Variable<int>(baselineStress);
    }
    if (!nullToAbsent || exerciseFrequency != null) {
      map['exercise_frequency'] = Variable<String>(exerciseFrequency);
    }
    map['preferred_language'] = Variable<String>(preferredLanguage);
    map['theme_brightness'] = Variable<String>(themeBrightness);
    map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled);
    map['notifications_period'] = Variable<bool>(notificationsPeriod);
    map['notifications_ovulation'] = Variable<bool>(notificationsOvulation);
    map['notifications_daily_checkin'] = Variable<bool>(
      notificationsDailyCheckin,
    );
    map['notification_lead_days'] = Variable<int>(notificationLeadDays);
    map['onboarded'] = Variable<bool>(onboarded);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      displayName: Value(displayName),
      birthYear: Value(birthYear),
      avgCycleDays: Value(avgCycleDays),
      avgPeriodDays: Value(avgPeriodDays),
      cycleLengthKnown: Value(cycleLengthKnown),
      onHormonalContraception: Value(onHormonalContraception),
      hasPcos: Value(hasPcos),
      hasEndo: Value(hasEndo),
      trackingGoals: trackingGoals == null && nullToAbsent
          ? const Value.absent()
          : Value(trackingGoals),
      commonSymptoms: commonSymptoms == null && nullToAbsent
          ? const Value.absent()
          : Value(commonSymptoms),
      baselineStress: baselineStress == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineStress),
      exerciseFrequency: exerciseFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseFrequency),
      preferredLanguage: Value(preferredLanguage),
      themeBrightness: Value(themeBrightness),
      cloudSyncEnabled: Value(cloudSyncEnabled),
      notificationsPeriod: Value(notificationsPeriod),
      notificationsOvulation: Value(notificationsOvulation),
      notificationsDailyCheckin: Value(notificationsDailyCheckin),
      notificationLeadDays: Value(notificationLeadDays),
      onboarded: Value(onboarded),
      createdAt: Value(createdAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      birthYear: serializer.fromJson<int>(json['birthYear']),
      avgCycleDays: serializer.fromJson<int>(json['avgCycleDays']),
      avgPeriodDays: serializer.fromJson<int>(json['avgPeriodDays']),
      cycleLengthKnown: serializer.fromJson<bool>(json['cycleLengthKnown']),
      onHormonalContraception: serializer.fromJson<bool>(
        json['onHormonalContraception'],
      ),
      hasPcos: serializer.fromJson<bool>(json['hasPcos']),
      hasEndo: serializer.fromJson<bool>(json['hasEndo']),
      trackingGoals: serializer.fromJson<String?>(json['trackingGoals']),
      commonSymptoms: serializer.fromJson<String?>(json['commonSymptoms']),
      baselineStress: serializer.fromJson<int?>(json['baselineStress']),
      exerciseFrequency: serializer.fromJson<String?>(
        json['exerciseFrequency'],
      ),
      preferredLanguage: serializer.fromJson<String>(json['preferredLanguage']),
      themeBrightness: serializer.fromJson<String>(json['themeBrightness']),
      cloudSyncEnabled: serializer.fromJson<bool>(json['cloudSyncEnabled']),
      notificationsPeriod: serializer.fromJson<bool>(
        json['notificationsPeriod'],
      ),
      notificationsOvulation: serializer.fromJson<bool>(
        json['notificationsOvulation'],
      ),
      notificationsDailyCheckin: serializer.fromJson<bool>(
        json['notificationsDailyCheckin'],
      ),
      notificationLeadDays: serializer.fromJson<int>(
        json['notificationLeadDays'],
      ),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'birthYear': serializer.toJson<int>(birthYear),
      'avgCycleDays': serializer.toJson<int>(avgCycleDays),
      'avgPeriodDays': serializer.toJson<int>(avgPeriodDays),
      'cycleLengthKnown': serializer.toJson<bool>(cycleLengthKnown),
      'onHormonalContraception': serializer.toJson<bool>(
        onHormonalContraception,
      ),
      'hasPcos': serializer.toJson<bool>(hasPcos),
      'hasEndo': serializer.toJson<bool>(hasEndo),
      'trackingGoals': serializer.toJson<String?>(trackingGoals),
      'commonSymptoms': serializer.toJson<String?>(commonSymptoms),
      'baselineStress': serializer.toJson<int?>(baselineStress),
      'exerciseFrequency': serializer.toJson<String?>(exerciseFrequency),
      'preferredLanguage': serializer.toJson<String>(preferredLanguage),
      'themeBrightness': serializer.toJson<String>(themeBrightness),
      'cloudSyncEnabled': serializer.toJson<bool>(cloudSyncEnabled),
      'notificationsPeriod': serializer.toJson<bool>(notificationsPeriod),
      'notificationsOvulation': serializer.toJson<bool>(notificationsOvulation),
      'notificationsDailyCheckin': serializer.toJson<bool>(
        notificationsDailyCheckin,
      ),
      'notificationLeadDays': serializer.toJson<int>(notificationLeadDays),
      'onboarded': serializer.toJson<bool>(onboarded),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  UserRow copyWith({
    int? id,
    String? displayName,
    int? birthYear,
    int? avgCycleDays,
    int? avgPeriodDays,
    bool? cycleLengthKnown,
    bool? onHormonalContraception,
    bool? hasPcos,
    bool? hasEndo,
    Value<String?> trackingGoals = const Value.absent(),
    Value<String?> commonSymptoms = const Value.absent(),
    Value<int?> baselineStress = const Value.absent(),
    Value<String?> exerciseFrequency = const Value.absent(),
    String? preferredLanguage,
    String? themeBrightness,
    bool? cloudSyncEnabled,
    bool? notificationsPeriod,
    bool? notificationsOvulation,
    bool? notificationsDailyCheckin,
    int? notificationLeadDays,
    bool? onboarded,
    int? createdAt,
  }) => UserRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    birthYear: birthYear ?? this.birthYear,
    avgCycleDays: avgCycleDays ?? this.avgCycleDays,
    avgPeriodDays: avgPeriodDays ?? this.avgPeriodDays,
    cycleLengthKnown: cycleLengthKnown ?? this.cycleLengthKnown,
    onHormonalContraception:
        onHormonalContraception ?? this.onHormonalContraception,
    hasPcos: hasPcos ?? this.hasPcos,
    hasEndo: hasEndo ?? this.hasEndo,
    trackingGoals: trackingGoals.present
        ? trackingGoals.value
        : this.trackingGoals,
    commonSymptoms: commonSymptoms.present
        ? commonSymptoms.value
        : this.commonSymptoms,
    baselineStress: baselineStress.present
        ? baselineStress.value
        : this.baselineStress,
    exerciseFrequency: exerciseFrequency.present
        ? exerciseFrequency.value
        : this.exerciseFrequency,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    themeBrightness: themeBrightness ?? this.themeBrightness,
    cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
    notificationsPeriod: notificationsPeriod ?? this.notificationsPeriod,
    notificationsOvulation:
        notificationsOvulation ?? this.notificationsOvulation,
    notificationsDailyCheckin:
        notificationsDailyCheckin ?? this.notificationsDailyCheckin,
    notificationLeadDays: notificationLeadDays ?? this.notificationLeadDays,
    onboarded: onboarded ?? this.onboarded,
    createdAt: createdAt ?? this.createdAt,
  );
  UserRow copyWithCompanion(UsersTableCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      avgCycleDays: data.avgCycleDays.present
          ? data.avgCycleDays.value
          : this.avgCycleDays,
      avgPeriodDays: data.avgPeriodDays.present
          ? data.avgPeriodDays.value
          : this.avgPeriodDays,
      cycleLengthKnown: data.cycleLengthKnown.present
          ? data.cycleLengthKnown.value
          : this.cycleLengthKnown,
      onHormonalContraception: data.onHormonalContraception.present
          ? data.onHormonalContraception.value
          : this.onHormonalContraception,
      hasPcos: data.hasPcos.present ? data.hasPcos.value : this.hasPcos,
      hasEndo: data.hasEndo.present ? data.hasEndo.value : this.hasEndo,
      trackingGoals: data.trackingGoals.present
          ? data.trackingGoals.value
          : this.trackingGoals,
      commonSymptoms: data.commonSymptoms.present
          ? data.commonSymptoms.value
          : this.commonSymptoms,
      baselineStress: data.baselineStress.present
          ? data.baselineStress.value
          : this.baselineStress,
      exerciseFrequency: data.exerciseFrequency.present
          ? data.exerciseFrequency.value
          : this.exerciseFrequency,
      preferredLanguage: data.preferredLanguage.present
          ? data.preferredLanguage.value
          : this.preferredLanguage,
      themeBrightness: data.themeBrightness.present
          ? data.themeBrightness.value
          : this.themeBrightness,
      cloudSyncEnabled: data.cloudSyncEnabled.present
          ? data.cloudSyncEnabled.value
          : this.cloudSyncEnabled,
      notificationsPeriod: data.notificationsPeriod.present
          ? data.notificationsPeriod.value
          : this.notificationsPeriod,
      notificationsOvulation: data.notificationsOvulation.present
          ? data.notificationsOvulation.value
          : this.notificationsOvulation,
      notificationsDailyCheckin: data.notificationsDailyCheckin.present
          ? data.notificationsDailyCheckin.value
          : this.notificationsDailyCheckin,
      notificationLeadDays: data.notificationLeadDays.present
          ? data.notificationLeadDays.value
          : this.notificationLeadDays,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthYear: $birthYear, ')
          ..write('avgCycleDays: $avgCycleDays, ')
          ..write('avgPeriodDays: $avgPeriodDays, ')
          ..write('cycleLengthKnown: $cycleLengthKnown, ')
          ..write('onHormonalContraception: $onHormonalContraception, ')
          ..write('hasPcos: $hasPcos, ')
          ..write('hasEndo: $hasEndo, ')
          ..write('trackingGoals: $trackingGoals, ')
          ..write('commonSymptoms: $commonSymptoms, ')
          ..write('baselineStress: $baselineStress, ')
          ..write('exerciseFrequency: $exerciseFrequency, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('themeBrightness: $themeBrightness, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled, ')
          ..write('notificationsPeriod: $notificationsPeriod, ')
          ..write('notificationsOvulation: $notificationsOvulation, ')
          ..write('notificationsDailyCheckin: $notificationsDailyCheckin, ')
          ..write('notificationLeadDays: $notificationLeadDays, ')
          ..write('onboarded: $onboarded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    displayName,
    birthYear,
    avgCycleDays,
    avgPeriodDays,
    cycleLengthKnown,
    onHormonalContraception,
    hasPcos,
    hasEndo,
    trackingGoals,
    commonSymptoms,
    baselineStress,
    exerciseFrequency,
    preferredLanguage,
    themeBrightness,
    cloudSyncEnabled,
    notificationsPeriod,
    notificationsOvulation,
    notificationsDailyCheckin,
    notificationLeadDays,
    onboarded,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.birthYear == this.birthYear &&
          other.avgCycleDays == this.avgCycleDays &&
          other.avgPeriodDays == this.avgPeriodDays &&
          other.cycleLengthKnown == this.cycleLengthKnown &&
          other.onHormonalContraception == this.onHormonalContraception &&
          other.hasPcos == this.hasPcos &&
          other.hasEndo == this.hasEndo &&
          other.trackingGoals == this.trackingGoals &&
          other.commonSymptoms == this.commonSymptoms &&
          other.baselineStress == this.baselineStress &&
          other.exerciseFrequency == this.exerciseFrequency &&
          other.preferredLanguage == this.preferredLanguage &&
          other.themeBrightness == this.themeBrightness &&
          other.cloudSyncEnabled == this.cloudSyncEnabled &&
          other.notificationsPeriod == this.notificationsPeriod &&
          other.notificationsOvulation == this.notificationsOvulation &&
          other.notificationsDailyCheckin == this.notificationsDailyCheckin &&
          other.notificationLeadDays == this.notificationLeadDays &&
          other.onboarded == this.onboarded &&
          other.createdAt == this.createdAt);
}

class UsersTableCompanion extends UpdateCompanion<UserRow> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<int> birthYear;
  final Value<int> avgCycleDays;
  final Value<int> avgPeriodDays;
  final Value<bool> cycleLengthKnown;
  final Value<bool> onHormonalContraception;
  final Value<bool> hasPcos;
  final Value<bool> hasEndo;
  final Value<String?> trackingGoals;
  final Value<String?> commonSymptoms;
  final Value<int?> baselineStress;
  final Value<String?> exerciseFrequency;
  final Value<String> preferredLanguage;
  final Value<String> themeBrightness;
  final Value<bool> cloudSyncEnabled;
  final Value<bool> notificationsPeriod;
  final Value<bool> notificationsOvulation;
  final Value<bool> notificationsDailyCheckin;
  final Value<int> notificationLeadDays;
  final Value<bool> onboarded;
  final Value<int> createdAt;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.avgCycleDays = const Value.absent(),
    this.avgPeriodDays = const Value.absent(),
    this.cycleLengthKnown = const Value.absent(),
    this.onHormonalContraception = const Value.absent(),
    this.hasPcos = const Value.absent(),
    this.hasEndo = const Value.absent(),
    this.trackingGoals = const Value.absent(),
    this.commonSymptoms = const Value.absent(),
    this.baselineStress = const Value.absent(),
    this.exerciseFrequency = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.themeBrightness = const Value.absent(),
    this.cloudSyncEnabled = const Value.absent(),
    this.notificationsPeriod = const Value.absent(),
    this.notificationsOvulation = const Value.absent(),
    this.notificationsDailyCheckin = const Value.absent(),
    this.notificationLeadDays = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersTableCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required int birthYear,
    this.avgCycleDays = const Value.absent(),
    this.avgPeriodDays = const Value.absent(),
    this.cycleLengthKnown = const Value.absent(),
    this.onHormonalContraception = const Value.absent(),
    this.hasPcos = const Value.absent(),
    this.hasEndo = const Value.absent(),
    this.trackingGoals = const Value.absent(),
    this.commonSymptoms = const Value.absent(),
    this.baselineStress = const Value.absent(),
    this.exerciseFrequency = const Value.absent(),
    this.preferredLanguage = const Value.absent(),
    this.themeBrightness = const Value.absent(),
    this.cloudSyncEnabled = const Value.absent(),
    this.notificationsPeriod = const Value.absent(),
    this.notificationsOvulation = const Value.absent(),
    this.notificationsDailyCheckin = const Value.absent(),
    this.notificationLeadDays = const Value.absent(),
    this.onboarded = const Value.absent(),
    required int createdAt,
  }) : displayName = Value(displayName),
       birthYear = Value(birthYear),
       createdAt = Value(createdAt);
  static Insertable<UserRow> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<int>? birthYear,
    Expression<int>? avgCycleDays,
    Expression<int>? avgPeriodDays,
    Expression<bool>? cycleLengthKnown,
    Expression<bool>? onHormonalContraception,
    Expression<bool>? hasPcos,
    Expression<bool>? hasEndo,
    Expression<String>? trackingGoals,
    Expression<String>? commonSymptoms,
    Expression<int>? baselineStress,
    Expression<String>? exerciseFrequency,
    Expression<String>? preferredLanguage,
    Expression<String>? themeBrightness,
    Expression<bool>? cloudSyncEnabled,
    Expression<bool>? notificationsPeriod,
    Expression<bool>? notificationsOvulation,
    Expression<bool>? notificationsDailyCheckin,
    Expression<int>? notificationLeadDays,
    Expression<bool>? onboarded,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (birthYear != null) 'birth_year': birthYear,
      if (avgCycleDays != null) 'avg_cycle_days': avgCycleDays,
      if (avgPeriodDays != null) 'avg_period_days': avgPeriodDays,
      if (cycleLengthKnown != null) 'cycle_length_known': cycleLengthKnown,
      if (onHormonalContraception != null)
        'on_hormonal_contraception': onHormonalContraception,
      if (hasPcos != null) 'has_pcos': hasPcos,
      if (hasEndo != null) 'has_endo': hasEndo,
      if (trackingGoals != null) 'tracking_goals': trackingGoals,
      if (commonSymptoms != null) 'common_symptoms': commonSymptoms,
      if (baselineStress != null) 'baseline_stress': baselineStress,
      if (exerciseFrequency != null) 'exercise_frequency': exerciseFrequency,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (themeBrightness != null) 'theme_brightness': themeBrightness,
      if (cloudSyncEnabled != null) 'cloud_sync_enabled': cloudSyncEnabled,
      if (notificationsPeriod != null)
        'notifications_period': notificationsPeriod,
      if (notificationsOvulation != null)
        'notifications_ovulation': notificationsOvulation,
      if (notificationsDailyCheckin != null)
        'notifications_daily_checkin': notificationsDailyCheckin,
      if (notificationLeadDays != null)
        'notification_lead_days': notificationLeadDays,
      if (onboarded != null) 'onboarded': onboarded,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersTableCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<int>? birthYear,
    Value<int>? avgCycleDays,
    Value<int>? avgPeriodDays,
    Value<bool>? cycleLengthKnown,
    Value<bool>? onHormonalContraception,
    Value<bool>? hasPcos,
    Value<bool>? hasEndo,
    Value<String?>? trackingGoals,
    Value<String?>? commonSymptoms,
    Value<int?>? baselineStress,
    Value<String?>? exerciseFrequency,
    Value<String>? preferredLanguage,
    Value<String>? themeBrightness,
    Value<bool>? cloudSyncEnabled,
    Value<bool>? notificationsPeriod,
    Value<bool>? notificationsOvulation,
    Value<bool>? notificationsDailyCheckin,
    Value<int>? notificationLeadDays,
    Value<bool>? onboarded,
    Value<int>? createdAt,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      birthYear: birthYear ?? this.birthYear,
      avgCycleDays: avgCycleDays ?? this.avgCycleDays,
      avgPeriodDays: avgPeriodDays ?? this.avgPeriodDays,
      cycleLengthKnown: cycleLengthKnown ?? this.cycleLengthKnown,
      onHormonalContraception:
          onHormonalContraception ?? this.onHormonalContraception,
      hasPcos: hasPcos ?? this.hasPcos,
      hasEndo: hasEndo ?? this.hasEndo,
      trackingGoals: trackingGoals ?? this.trackingGoals,
      commonSymptoms: commonSymptoms ?? this.commonSymptoms,
      baselineStress: baselineStress ?? this.baselineStress,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      themeBrightness: themeBrightness ?? this.themeBrightness,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      notificationsPeriod: notificationsPeriod ?? this.notificationsPeriod,
      notificationsOvulation:
          notificationsOvulation ?? this.notificationsOvulation,
      notificationsDailyCheckin:
          notificationsDailyCheckin ?? this.notificationsDailyCheckin,
      notificationLeadDays: notificationLeadDays ?? this.notificationLeadDays,
      onboarded: onboarded ?? this.onboarded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (avgCycleDays.present) {
      map['avg_cycle_days'] = Variable<int>(avgCycleDays.value);
    }
    if (avgPeriodDays.present) {
      map['avg_period_days'] = Variable<int>(avgPeriodDays.value);
    }
    if (cycleLengthKnown.present) {
      map['cycle_length_known'] = Variable<bool>(cycleLengthKnown.value);
    }
    if (onHormonalContraception.present) {
      map['on_hormonal_contraception'] = Variable<bool>(
        onHormonalContraception.value,
      );
    }
    if (hasPcos.present) {
      map['has_pcos'] = Variable<bool>(hasPcos.value);
    }
    if (hasEndo.present) {
      map['has_endo'] = Variable<bool>(hasEndo.value);
    }
    if (trackingGoals.present) {
      map['tracking_goals'] = Variable<String>(trackingGoals.value);
    }
    if (commonSymptoms.present) {
      map['common_symptoms'] = Variable<String>(commonSymptoms.value);
    }
    if (baselineStress.present) {
      map['baseline_stress'] = Variable<int>(baselineStress.value);
    }
    if (exerciseFrequency.present) {
      map['exercise_frequency'] = Variable<String>(exerciseFrequency.value);
    }
    if (preferredLanguage.present) {
      map['preferred_language'] = Variable<String>(preferredLanguage.value);
    }
    if (themeBrightness.present) {
      map['theme_brightness'] = Variable<String>(themeBrightness.value);
    }
    if (cloudSyncEnabled.present) {
      map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled.value);
    }
    if (notificationsPeriod.present) {
      map['notifications_period'] = Variable<bool>(notificationsPeriod.value);
    }
    if (notificationsOvulation.present) {
      map['notifications_ovulation'] = Variable<bool>(
        notificationsOvulation.value,
      );
    }
    if (notificationsDailyCheckin.present) {
      map['notifications_daily_checkin'] = Variable<bool>(
        notificationsDailyCheckin.value,
      );
    }
    if (notificationLeadDays.present) {
      map['notification_lead_days'] = Variable<int>(notificationLeadDays.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('birthYear: $birthYear, ')
          ..write('avgCycleDays: $avgCycleDays, ')
          ..write('avgPeriodDays: $avgPeriodDays, ')
          ..write('cycleLengthKnown: $cycleLengthKnown, ')
          ..write('onHormonalContraception: $onHormonalContraception, ')
          ..write('hasPcos: $hasPcos, ')
          ..write('hasEndo: $hasEndo, ')
          ..write('trackingGoals: $trackingGoals, ')
          ..write('commonSymptoms: $commonSymptoms, ')
          ..write('baselineStress: $baselineStress, ')
          ..write('exerciseFrequency: $exerciseFrequency, ')
          ..write('preferredLanguage: $preferredLanguage, ')
          ..write('themeBrightness: $themeBrightness, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled, ')
          ..write('notificationsPeriod: $notificationsPeriod, ')
          ..write('notificationsOvulation: $notificationsOvulation, ')
          ..write('notificationsDailyCheckin: $notificationsDailyCheckin, ')
          ..write('notificationLeadDays: $notificationLeadDays, ')
          ..write('onboarded: $onboarded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CycleEntriesTableTable extends CycleEntriesTable
    with TableInfo<$CycleEntriesTableTable, CycleEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleEntriesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cycleLengthMeta = const VerificationMeta(
    'cycleLength',
  );
  @override
  late final GeneratedColumn<int> cycleLength = GeneratedColumn<int>(
    'cycle_length',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodLengthMeta = const VerificationMeta(
    'periodLength',
  );
  @override
  late final GeneratedColumn<int> periodLength = GeneratedColumn<int>(
    'period_length',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSeededMeta = const VerificationMeta(
    'isSeeded',
  );
  @override
  late final GeneratedColumn<bool> isSeeded = GeneratedColumn<bool>(
    'is_seeded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_seeded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    startDate,
    endDate,
    cycleLength,
    periodLength,
    notes,
    isSeeded,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CycleEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('cycle_length')) {
      context.handle(
        _cycleLengthMeta,
        cycleLength.isAcceptableOrUnknown(
          data['cycle_length']!,
          _cycleLengthMeta,
        ),
      );
    }
    if (data.containsKey('period_length')) {
      context.handle(
        _periodLengthMeta,
        periodLength.isAcceptableOrUnknown(
          data['period_length']!,
          _periodLengthMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_seeded')) {
      context.handle(
        _isSeededMeta,
        isSeeded.isAcceptableOrUnknown(data['is_seeded']!, _isSeededMeta),
      );
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
  CycleEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      cycleLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_length'],
      ),
      periodLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_length'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isSeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_seeded'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CycleEntriesTableTable createAlias(String alias) {
    return $CycleEntriesTableTable(attachedDatabase, alias);
  }
}

class CycleEntryRow extends DataClass implements Insertable<CycleEntryRow> {
  final int id;
  final String startDate;
  final String? endDate;
  final int? cycleLength;
  final int? periodLength;
  final String? notes;
  final bool isSeeded;
  final int createdAt;
  const CycleEntryRow({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.notes,
    required this.isSeeded,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || cycleLength != null) {
      map['cycle_length'] = Variable<int>(cycleLength);
    }
    if (!nullToAbsent || periodLength != null) {
      map['period_length'] = Variable<int>(periodLength);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_seeded'] = Variable<bool>(isSeeded);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CycleEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return CycleEntriesTableCompanion(
      id: Value(id),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      cycleLength: cycleLength == null && nullToAbsent
          ? const Value.absent()
          : Value(cycleLength),
      periodLength: periodLength == null && nullToAbsent
          ? const Value.absent()
          : Value(periodLength),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isSeeded: Value(isSeeded),
      createdAt: Value(createdAt),
    );
  }

  factory CycleEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleEntryRow(
      id: serializer.fromJson<int>(json['id']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      cycleLength: serializer.fromJson<int?>(json['cycleLength']),
      periodLength: serializer.fromJson<int?>(json['periodLength']),
      notes: serializer.fromJson<String?>(json['notes']),
      isSeeded: serializer.fromJson<bool>(json['isSeeded']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'cycleLength': serializer.toJson<int?>(cycleLength),
      'periodLength': serializer.toJson<int?>(periodLength),
      'notes': serializer.toJson<String?>(notes),
      'isSeeded': serializer.toJson<bool>(isSeeded),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CycleEntryRow copyWith({
    int? id,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    Value<int?> cycleLength = const Value.absent(),
    Value<int?> periodLength = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isSeeded,
    int? createdAt,
  }) => CycleEntryRow(
    id: id ?? this.id,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    cycleLength: cycleLength.present ? cycleLength.value : this.cycleLength,
    periodLength: periodLength.present ? periodLength.value : this.periodLength,
    notes: notes.present ? notes.value : this.notes,
    isSeeded: isSeeded ?? this.isSeeded,
    createdAt: createdAt ?? this.createdAt,
  );
  CycleEntryRow copyWithCompanion(CycleEntriesTableCompanion data) {
    return CycleEntryRow(
      id: data.id.present ? data.id.value : this.id,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      cycleLength: data.cycleLength.present
          ? data.cycleLength.value
          : this.cycleLength,
      periodLength: data.periodLength.present
          ? data.periodLength.value
          : this.periodLength,
      notes: data.notes.present ? data.notes.value : this.notes,
      isSeeded: data.isSeeded.present ? data.isSeeded.value : this.isSeeded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleEntryRow(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodLength: $periodLength, ')
          ..write('notes: $notes, ')
          ..write('isSeeded: $isSeeded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startDate,
    endDate,
    cycleLength,
    periodLength,
    notes,
    isSeeded,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleEntryRow &&
          other.id == this.id &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.cycleLength == this.cycleLength &&
          other.periodLength == this.periodLength &&
          other.notes == this.notes &&
          other.isSeeded == this.isSeeded &&
          other.createdAt == this.createdAt);
}

class CycleEntriesTableCompanion extends UpdateCompanion<CycleEntryRow> {
  final Value<int> id;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<int?> cycleLength;
  final Value<int?> periodLength;
  final Value<String?> notes;
  final Value<bool> isSeeded;
  final Value<int> createdAt;
  const CycleEntriesTableCompanion({
    this.id = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSeeded = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CycleEntriesTableCompanion.insert({
    this.id = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    this.cycleLength = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSeeded = const Value.absent(),
    required int createdAt,
  }) : startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<CycleEntryRow> custom({
    Expression<int>? id,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? cycleLength,
    Expression<int>? periodLength,
    Expression<String>? notes,
    Expression<bool>? isSeeded,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (cycleLength != null) 'cycle_length': cycleLength,
      if (periodLength != null) 'period_length': periodLength,
      if (notes != null) 'notes': notes,
      if (isSeeded != null) 'is_seeded': isSeeded,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CycleEntriesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<int?>? cycleLength,
    Value<int?>? periodLength,
    Value<String?>? notes,
    Value<bool>? isSeeded,
    Value<int>? createdAt,
  }) {
    return CycleEntriesTableCompanion(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      notes: notes ?? this.notes,
      isSeeded: isSeeded ?? this.isSeeded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (cycleLength.present) {
      map['cycle_length'] = Variable<int>(cycleLength.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isSeeded.present) {
      map['is_seeded'] = Variable<bool>(isSeeded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('cycleLength: $cycleLength, ')
          ..write('periodLength: $periodLength, ')
          ..write('notes: $notes, ')
          ..write('isSeeded: $isSeeded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PeriodDayLogsTableTable extends PeriodDayLogsTable
    with TableInfo<$PeriodDayLogsTableTable, PeriodDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodDayLogsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cycleEntryIdMeta = const VerificationMeta(
    'cycleEntryId',
  );
  @override
  late final GeneratedColumn<int> cycleEntryId = GeneratedColumn<int>(
    'cycle_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cycle_entries (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flowMeta = const VerificationMeta('flow');
  @override
  late final GeneratedColumn<String> flow = GeneratedColumn<String>(
    'flow',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cycleEntryId, date, flow];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_day_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_entry_id')) {
      context.handle(
        _cycleEntryIdMeta,
        cycleEntryId.isAcceptableOrUnknown(
          data['cycle_entry_id']!,
          _cycleEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cycleEntryIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('flow')) {
      context.handle(
        _flowMeta,
        flow.isAcceptableOrUnknown(data['flow']!, _flowMeta),
      );
    } else if (isInserting) {
      context.missing(_flowMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cycleEntryId, date},
  ];
  @override
  PeriodDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodDayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_entry_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      flow: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flow'],
      )!,
    );
  }

  @override
  $PeriodDayLogsTableTable createAlias(String alias) {
    return $PeriodDayLogsTableTable(attachedDatabase, alias);
  }
}

class PeriodDayRow extends DataClass implements Insertable<PeriodDayRow> {
  final int id;
  final int cycleEntryId;
  final String date;
  final String flow;
  const PeriodDayRow({
    required this.id,
    required this.cycleEntryId,
    required this.date,
    required this.flow,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cycle_entry_id'] = Variable<int>(cycleEntryId);
    map['date'] = Variable<String>(date);
    map['flow'] = Variable<String>(flow);
    return map;
  }

  PeriodDayLogsTableCompanion toCompanion(bool nullToAbsent) {
    return PeriodDayLogsTableCompanion(
      id: Value(id),
      cycleEntryId: Value(cycleEntryId),
      date: Value(date),
      flow: Value(flow),
    );
  }

  factory PeriodDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodDayRow(
      id: serializer.fromJson<int>(json['id']),
      cycleEntryId: serializer.fromJson<int>(json['cycleEntryId']),
      date: serializer.fromJson<String>(json['date']),
      flow: serializer.fromJson<String>(json['flow']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleEntryId': serializer.toJson<int>(cycleEntryId),
      'date': serializer.toJson<String>(date),
      'flow': serializer.toJson<String>(flow),
    };
  }

  PeriodDayRow copyWith({
    int? id,
    int? cycleEntryId,
    String? date,
    String? flow,
  }) => PeriodDayRow(
    id: id ?? this.id,
    cycleEntryId: cycleEntryId ?? this.cycleEntryId,
    date: date ?? this.date,
    flow: flow ?? this.flow,
  );
  PeriodDayRow copyWithCompanion(PeriodDayLogsTableCompanion data) {
    return PeriodDayRow(
      id: data.id.present ? data.id.value : this.id,
      cycleEntryId: data.cycleEntryId.present
          ? data.cycleEntryId.value
          : this.cycleEntryId,
      date: data.date.present ? data.date.value : this.date,
      flow: data.flow.present ? data.flow.value : this.flow,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodDayRow(')
          ..write('id: $id, ')
          ..write('cycleEntryId: $cycleEntryId, ')
          ..write('date: $date, ')
          ..write('flow: $flow')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cycleEntryId, date, flow);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodDayRow &&
          other.id == this.id &&
          other.cycleEntryId == this.cycleEntryId &&
          other.date == this.date &&
          other.flow == this.flow);
}

class PeriodDayLogsTableCompanion extends UpdateCompanion<PeriodDayRow> {
  final Value<int> id;
  final Value<int> cycleEntryId;
  final Value<String> date;
  final Value<String> flow;
  const PeriodDayLogsTableCompanion({
    this.id = const Value.absent(),
    this.cycleEntryId = const Value.absent(),
    this.date = const Value.absent(),
    this.flow = const Value.absent(),
  });
  PeriodDayLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required int cycleEntryId,
    required String date,
    required String flow,
  }) : cycleEntryId = Value(cycleEntryId),
       date = Value(date),
       flow = Value(flow);
  static Insertable<PeriodDayRow> custom({
    Expression<int>? id,
    Expression<int>? cycleEntryId,
    Expression<String>? date,
    Expression<String>? flow,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleEntryId != null) 'cycle_entry_id': cycleEntryId,
      if (date != null) 'date': date,
      if (flow != null) 'flow': flow,
    });
  }

  PeriodDayLogsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? cycleEntryId,
    Value<String>? date,
    Value<String>? flow,
  }) {
    return PeriodDayLogsTableCompanion(
      id: id ?? this.id,
      cycleEntryId: cycleEntryId ?? this.cycleEntryId,
      date: date ?? this.date,
      flow: flow ?? this.flow,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleEntryId.present) {
      map['cycle_entry_id'] = Variable<int>(cycleEntryId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (flow.present) {
      map['flow'] = Variable<String>(flow.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodDayLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('cycleEntryId: $cycleEntryId, ')
          ..write('date: $date, ')
          ..write('flow: $flow')
          ..write(')'))
        .toString();
  }
}

class $SymptomLogsTableTable extends SymptomLogsTable
    with TableInfo<$SymptomLogsTableTable, SymptomRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomLogsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symptomMeta = const VerificationMeta(
    'symptom',
  );
  @override
  late final GeneratedColumn<String> symptom = GeneratedColumn<String>(
    'symptom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    date,
    symptom,
    severity,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SymptomRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('symptom')) {
      context.handle(
        _symptomMeta,
        symptom.isAcceptableOrUnknown(data['symptom']!, _symptomMeta),
      );
    } else if (isInserting) {
      context.missing(_symptomMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
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
    {date, symptom},
  ];
  @override
  SymptomRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      symptom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptom'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SymptomLogsTableTable createAlias(String alias) {
    return $SymptomLogsTableTable(attachedDatabase, alias);
  }
}

class SymptomRow extends DataClass implements Insertable<SymptomRow> {
  final int id;
  final String date;
  final String symptom;
  final int severity;
  final String? notes;
  final int createdAt;
  const SymptomRow({
    required this.id,
    required this.date,
    required this.symptom,
    required this.severity,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['symptom'] = Variable<String>(symptom);
    map['severity'] = Variable<int>(severity);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SymptomLogsTableCompanion toCompanion(bool nullToAbsent) {
    return SymptomLogsTableCompanion(
      id: Value(id),
      date: Value(date),
      symptom: Value(symptom),
      severity: Value(severity),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory SymptomRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      symptom: serializer.fromJson<String>(json['symptom']),
      severity: serializer.fromJson<int>(json['severity']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'symptom': serializer.toJson<String>(symptom),
      'severity': serializer.toJson<int>(severity),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SymptomRow copyWith({
    int? id,
    String? date,
    String? symptom,
    int? severity,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
  }) => SymptomRow(
    id: id ?? this.id,
    date: date ?? this.date,
    symptom: symptom ?? this.symptom,
    severity: severity ?? this.severity,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  SymptomRow copyWithCompanion(SymptomLogsTableCompanion data) {
    return SymptomRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      symptom: data.symptom.present ? data.symptom.value : this.symptom,
      severity: data.severity.present ? data.severity.value : this.severity,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('symptom: $symptom, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, symptom, severity, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.symptom == this.symptom &&
          other.severity == this.severity &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SymptomLogsTableCompanion extends UpdateCompanion<SymptomRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> symptom;
  final Value<int> severity;
  final Value<String?> notes;
  final Value<int> createdAt;
  const SymptomLogsTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.symptom = const Value.absent(),
    this.severity = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SymptomLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String symptom,
    required int severity,
    this.notes = const Value.absent(),
    required int createdAt,
  }) : date = Value(date),
       symptom = Value(symptom),
       severity = Value(severity),
       createdAt = Value(createdAt);
  static Insertable<SymptomRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? symptom,
    Expression<int>? severity,
    Expression<String>? notes,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (symptom != null) 'symptom': symptom,
      if (severity != null) 'severity': severity,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SymptomLogsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? symptom,
    Value<int>? severity,
    Value<String?>? notes,
    Value<int>? createdAt,
  }) {
    return SymptomLogsTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (symptom.present) {
      map['symptom'] = Variable<String>(symptom.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('symptom: $symptom, ')
          ..write('severity: $severity, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MoodLogsTableTable extends MoodLogsTable
    with TableInfo<$MoodLogsTableTable, MoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodLogsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyLevelMeta = const VerificationMeta(
    'energyLevel',
  );
  @override
  late final GeneratedColumn<int> energyLevel = GeneratedColumn<int>(
    'energy_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    date,
    mood,
    energyLevel,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('energy_level')) {
      context.handle(
        _energyLevelMeta,
        energyLevel.isAcceptableOrUnknown(
          data['energy_level']!,
          _energyLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_energyLevelMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
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
    {date},
  ];
  @override
  MoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      )!,
      energyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy_level'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MoodLogsTableTable createAlias(String alias) {
    return $MoodLogsTableTable(attachedDatabase, alias);
  }
}

class MoodRow extends DataClass implements Insertable<MoodRow> {
  final int id;
  final String date;
  final String mood;
  final int energyLevel;
  final String? notes;
  final int createdAt;
  const MoodRow({
    required this.id,
    required this.date,
    required this.mood,
    required this.energyLevel,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['mood'] = Variable<String>(mood);
    map['energy_level'] = Variable<int>(energyLevel);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MoodLogsTableCompanion toCompanion(bool nullToAbsent) {
    return MoodLogsTableCompanion(
      id: Value(id),
      date: Value(date),
      mood: Value(mood),
      energyLevel: Value(energyLevel),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      mood: serializer.fromJson<String>(json['mood']),
      energyLevel: serializer.fromJson<int>(json['energyLevel']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'mood': serializer.toJson<String>(mood),
      'energyLevel': serializer.toJson<int>(energyLevel),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  MoodRow copyWith({
    int? id,
    String? date,
    String? mood,
    int? energyLevel,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
  }) => MoodRow(
    id: id ?? this.id,
    date: date ?? this.date,
    mood: mood ?? this.mood,
    energyLevel: energyLevel ?? this.energyLevel,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MoodRow copyWithCompanion(MoodLogsTableCompanion data) {
    return MoodRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      mood: data.mood.present ? data.mood.value : this.mood,
      energyLevel: data.energyLevel.present
          ? data.energyLevel.value
          : this.energyLevel,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, mood, energyLevel, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.mood == this.mood &&
          other.energyLevel == this.energyLevel &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MoodLogsTableCompanion extends UpdateCompanion<MoodRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> mood;
  final Value<int> energyLevel;
  final Value<String?> notes;
  final Value<int> createdAt;
  const MoodLogsTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.mood = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MoodLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String mood,
    required int energyLevel,
    this.notes = const Value.absent(),
    required int createdAt,
  }) : date = Value(date),
       mood = Value(mood),
       energyLevel = Value(energyLevel),
       createdAt = Value(createdAt);
  static Insertable<MoodRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? mood,
    Expression<int>? energyLevel,
    Expression<String>? notes,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (mood != null) 'mood': mood,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MoodLogsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? mood,
    Value<int>? energyLevel,
    Value<String?>? notes,
    Value<int>? createdAt,
  }) {
    return MoodLogsTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<int>(energyLevel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HealthNotesTableTable extends HealthNotesTable
    with TableInfo<$HealthNotesTableTable, HealthNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthNotesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [id, date, content, tags, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
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
  HealthNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HealthNotesTableTable createAlias(String alias) {
    return $HealthNotesTableTable(attachedDatabase, alias);
  }
}

class HealthNoteRow extends DataClass implements Insertable<HealthNoteRow> {
  final int id;
  final String date;
  final String content;
  final String? tags;
  final int createdAt;
  const HealthNoteRow({
    required this.id,
    required this.date,
    required this.content,
    this.tags,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  HealthNotesTableCompanion toCompanion(bool nullToAbsent) {
    return HealthNotesTableCompanion(
      id: Value(id),
      date: Value(date),
      content: Value(content),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      createdAt: Value(createdAt),
    );
  }

  factory HealthNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthNoteRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      content: serializer.fromJson<String>(json['content']),
      tags: serializer.fromJson<String?>(json['tags']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'content': serializer.toJson<String>(content),
      'tags': serializer.toJson<String?>(tags),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  HealthNoteRow copyWith({
    int? id,
    String? date,
    String? content,
    Value<String?> tags = const Value.absent(),
    int? createdAt,
  }) => HealthNoteRow(
    id: id ?? this.id,
    date: date ?? this.date,
    content: content ?? this.content,
    tags: tags.present ? tags.value : this.tags,
    createdAt: createdAt ?? this.createdAt,
  );
  HealthNoteRow copyWithCompanion(HealthNotesTableCompanion data) {
    return HealthNoteRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      content: data.content.present ? data.content.value : this.content,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthNoteRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('content: $content, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, content, tags, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthNoteRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.content == this.content &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt);
}

class HealthNotesTableCompanion extends UpdateCompanion<HealthNoteRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> content;
  final Value<String?> tags;
  final Value<int> createdAt;
  const HealthNotesTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.content = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HealthNotesTableCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String content,
    this.tags = const Value.absent(),
    required int createdAt,
  }) : date = Value(date),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<HealthNoteRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? content,
    Expression<String>? tags,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (content != null) 'content': content,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HealthNotesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? content,
    Value<String?>? tags,
    Value<int>? createdAt,
  }) {
    return HealthNotesTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthNotesTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('content: $content, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AiInsightsCacheTableTable extends AiInsightsCacheTable
    with TableInfo<$AiInsightsCacheTableTable, AiInsightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiInsightsCacheTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cycleEntryIdMeta = const VerificationMeta(
    'cycleEntryId',
  );
  @override
  late final GeneratedColumn<int> cycleEntryId = GeneratedColumn<int>(
    'cycle_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insightTypeMeta = const VerificationMeta(
    'insightType',
  );
  @override
  late final GeneratedColumn<String> insightType = GeneratedColumn<String>(
    'insight_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<int> generatedAt = GeneratedColumn<int>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isStaleMeta = const VerificationMeta(
    'isStale',
  );
  @override
  late final GeneratedColumn<bool> isStale = GeneratedColumn<bool>(
    'is_stale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_stale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cycleEntryId,
    insightType,
    content,
    generatedAt,
    isStale,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_insights_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiInsightRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cycle_entry_id')) {
      context.handle(
        _cycleEntryIdMeta,
        cycleEntryId.isAcceptableOrUnknown(
          data['cycle_entry_id']!,
          _cycleEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('insight_type')) {
      context.handle(
        _insightTypeMeta,
        insightType.isAcceptableOrUnknown(
          data['insight_type']!,
          _insightTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insightTypeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('is_stale')) {
      context.handle(
        _isStaleMeta,
        isStale.isAcceptableOrUnknown(data['is_stale']!, _isStaleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiInsightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiInsightRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cycleEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_entry_id'],
      ),
      insightType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insight_type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generated_at'],
      )!,
      isStale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_stale'],
      )!,
    );
  }

  @override
  $AiInsightsCacheTableTable createAlias(String alias) {
    return $AiInsightsCacheTableTable(attachedDatabase, alias);
  }
}

class AiInsightRow extends DataClass implements Insertable<AiInsightRow> {
  final int id;
  final int? cycleEntryId;
  final String insightType;
  final String content;
  final int generatedAt;
  final bool isStale;
  const AiInsightRow({
    required this.id,
    this.cycleEntryId,
    required this.insightType,
    required this.content,
    required this.generatedAt,
    required this.isStale,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || cycleEntryId != null) {
      map['cycle_entry_id'] = Variable<int>(cycleEntryId);
    }
    map['insight_type'] = Variable<String>(insightType);
    map['content'] = Variable<String>(content);
    map['generated_at'] = Variable<int>(generatedAt);
    map['is_stale'] = Variable<bool>(isStale);
    return map;
  }

  AiInsightsCacheTableCompanion toCompanion(bool nullToAbsent) {
    return AiInsightsCacheTableCompanion(
      id: Value(id),
      cycleEntryId: cycleEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(cycleEntryId),
      insightType: Value(insightType),
      content: Value(content),
      generatedAt: Value(generatedAt),
      isStale: Value(isStale),
    );
  }

  factory AiInsightRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiInsightRow(
      id: serializer.fromJson<int>(json['id']),
      cycleEntryId: serializer.fromJson<int?>(json['cycleEntryId']),
      insightType: serializer.fromJson<String>(json['insightType']),
      content: serializer.fromJson<String>(json['content']),
      generatedAt: serializer.fromJson<int>(json['generatedAt']),
      isStale: serializer.fromJson<bool>(json['isStale']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cycleEntryId': serializer.toJson<int?>(cycleEntryId),
      'insightType': serializer.toJson<String>(insightType),
      'content': serializer.toJson<String>(content),
      'generatedAt': serializer.toJson<int>(generatedAt),
      'isStale': serializer.toJson<bool>(isStale),
    };
  }

  AiInsightRow copyWith({
    int? id,
    Value<int?> cycleEntryId = const Value.absent(),
    String? insightType,
    String? content,
    int? generatedAt,
    bool? isStale,
  }) => AiInsightRow(
    id: id ?? this.id,
    cycleEntryId: cycleEntryId.present ? cycleEntryId.value : this.cycleEntryId,
    insightType: insightType ?? this.insightType,
    content: content ?? this.content,
    generatedAt: generatedAt ?? this.generatedAt,
    isStale: isStale ?? this.isStale,
  );
  AiInsightRow copyWithCompanion(AiInsightsCacheTableCompanion data) {
    return AiInsightRow(
      id: data.id.present ? data.id.value : this.id,
      cycleEntryId: data.cycleEntryId.present
          ? data.cycleEntryId.value
          : this.cycleEntryId,
      insightType: data.insightType.present
          ? data.insightType.value
          : this.insightType,
      content: data.content.present ? data.content.value : this.content,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      isStale: data.isStale.present ? data.isStale.value : this.isStale,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiInsightRow(')
          ..write('id: $id, ')
          ..write('cycleEntryId: $cycleEntryId, ')
          ..write('insightType: $insightType, ')
          ..write('content: $content, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('isStale: $isStale')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cycleEntryId, insightType, content, generatedAt, isStale);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiInsightRow &&
          other.id == this.id &&
          other.cycleEntryId == this.cycleEntryId &&
          other.insightType == this.insightType &&
          other.content == this.content &&
          other.generatedAt == this.generatedAt &&
          other.isStale == this.isStale);
}

class AiInsightsCacheTableCompanion extends UpdateCompanion<AiInsightRow> {
  final Value<int> id;
  final Value<int?> cycleEntryId;
  final Value<String> insightType;
  final Value<String> content;
  final Value<int> generatedAt;
  final Value<bool> isStale;
  const AiInsightsCacheTableCompanion({
    this.id = const Value.absent(),
    this.cycleEntryId = const Value.absent(),
    this.insightType = const Value.absent(),
    this.content = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.isStale = const Value.absent(),
  });
  AiInsightsCacheTableCompanion.insert({
    this.id = const Value.absent(),
    this.cycleEntryId = const Value.absent(),
    required String insightType,
    required String content,
    required int generatedAt,
    this.isStale = const Value.absent(),
  }) : insightType = Value(insightType),
       content = Value(content),
       generatedAt = Value(generatedAt);
  static Insertable<AiInsightRow> custom({
    Expression<int>? id,
    Expression<int>? cycleEntryId,
    Expression<String>? insightType,
    Expression<String>? content,
    Expression<int>? generatedAt,
    Expression<bool>? isStale,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cycleEntryId != null) 'cycle_entry_id': cycleEntryId,
      if (insightType != null) 'insight_type': insightType,
      if (content != null) 'content': content,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (isStale != null) 'is_stale': isStale,
    });
  }

  AiInsightsCacheTableCompanion copyWith({
    Value<int>? id,
    Value<int?>? cycleEntryId,
    Value<String>? insightType,
    Value<String>? content,
    Value<int>? generatedAt,
    Value<bool>? isStale,
  }) {
    return AiInsightsCacheTableCompanion(
      id: id ?? this.id,
      cycleEntryId: cycleEntryId ?? this.cycleEntryId,
      insightType: insightType ?? this.insightType,
      content: content ?? this.content,
      generatedAt: generatedAt ?? this.generatedAt,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cycleEntryId.present) {
      map['cycle_entry_id'] = Variable<int>(cycleEntryId.value);
    }
    if (insightType.present) {
      map['insight_type'] = Variable<String>(insightType.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<int>(generatedAt.value);
    }
    if (isStale.present) {
      map['is_stale'] = Variable<bool>(isStale.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiInsightsCacheTableCompanion(')
          ..write('id: $id, ')
          ..write('cycleEntryId: $cycleEntryId, ')
          ..write('insightType: $insightType, ')
          ..write('content: $content, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('isStale: $isStale')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $CycleEntriesTableTable cycleEntriesTable =
      $CycleEntriesTableTable(this);
  late final $PeriodDayLogsTableTable periodDayLogsTable =
      $PeriodDayLogsTableTable(this);
  late final $SymptomLogsTableTable symptomLogsTable = $SymptomLogsTableTable(
    this,
  );
  late final $MoodLogsTableTable moodLogsTable = $MoodLogsTableTable(this);
  late final $HealthNotesTableTable healthNotesTable = $HealthNotesTableTable(
    this,
  );
  late final $AiInsightsCacheTableTable aiInsightsCacheTable =
      $AiInsightsCacheTableTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final CycleDao cycleDao = CycleDao(this as AppDatabase);
  late final SymptomDao symptomDao = SymptomDao(this as AppDatabase);
  late final MoodDao moodDao = MoodDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    usersTable,
    cycleEntriesTable,
    periodDayLogsTable,
    symptomLogsTable,
    moodLogsTable,
    healthNotesTable,
    aiInsightsCacheTable,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UsersTableTableCreateCompanionBuilder =
    UsersTableCompanion Function({
      Value<int> id,
      required String displayName,
      required int birthYear,
      Value<int> avgCycleDays,
      Value<int> avgPeriodDays,
      Value<bool> cycleLengthKnown,
      Value<bool> onHormonalContraception,
      Value<bool> hasPcos,
      Value<bool> hasEndo,
      Value<String?> trackingGoals,
      Value<String?> commonSymptoms,
      Value<int?> baselineStress,
      Value<String?> exerciseFrequency,
      Value<String> preferredLanguage,
      Value<String> themeBrightness,
      Value<bool> cloudSyncEnabled,
      Value<bool> notificationsPeriod,
      Value<bool> notificationsOvulation,
      Value<bool> notificationsDailyCheckin,
      Value<int> notificationLeadDays,
      Value<bool> onboarded,
      required int createdAt,
    });
typedef $$UsersTableTableUpdateCompanionBuilder =
    UsersTableCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<int> birthYear,
      Value<int> avgCycleDays,
      Value<int> avgPeriodDays,
      Value<bool> cycleLengthKnown,
      Value<bool> onHormonalContraception,
      Value<bool> hasPcos,
      Value<bool> hasEndo,
      Value<String?> trackingGoals,
      Value<String?> commonSymptoms,
      Value<int?> baselineStress,
      Value<String?> exerciseFrequency,
      Value<String> preferredLanguage,
      Value<String> themeBrightness,
      Value<bool> cloudSyncEnabled,
      Value<bool> notificationsPeriod,
      Value<bool> notificationsOvulation,
      Value<bool> notificationsDailyCheckin,
      Value<int> notificationLeadDays,
      Value<bool> onboarded,
      Value<int> createdAt,
    });

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCycleDays => $composableBuilder(
    column: $table.avgCycleDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgPeriodDays => $composableBuilder(
    column: $table.avgPeriodDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cycleLengthKnown => $composableBuilder(
    column: $table.cycleLengthKnown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onHormonalContraception => $composableBuilder(
    column: $table.onHormonalContraception,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPcos => $composableBuilder(
    column: $table.hasPcos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasEndo => $composableBuilder(
    column: $table.hasEndo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingGoals => $composableBuilder(
    column: $table.trackingGoals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonSymptoms => $composableBuilder(
    column: $table.commonSymptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baselineStress => $composableBuilder(
    column: $table.baselineStress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseFrequency => $composableBuilder(
    column: $table.exerciseFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeBrightness => $composableBuilder(
    column: $table.themeBrightness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cloudSyncEnabled => $composableBuilder(
    column: $table.cloudSyncEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsPeriod => $composableBuilder(
    column: $table.notificationsPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsOvulation => $composableBuilder(
    column: $table.notificationsOvulation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsDailyCheckin => $composableBuilder(
    column: $table.notificationsDailyCheckin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationLeadDays => $composableBuilder(
    column: $table.notificationLeadDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCycleDays => $composableBuilder(
    column: $table.avgCycleDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgPeriodDays => $composableBuilder(
    column: $table.avgPeriodDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cycleLengthKnown => $composableBuilder(
    column: $table.cycleLengthKnown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onHormonalContraception => $composableBuilder(
    column: $table.onHormonalContraception,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPcos => $composableBuilder(
    column: $table.hasPcos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasEndo => $composableBuilder(
    column: $table.hasEndo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingGoals => $composableBuilder(
    column: $table.trackingGoals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonSymptoms => $composableBuilder(
    column: $table.commonSymptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baselineStress => $composableBuilder(
    column: $table.baselineStress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseFrequency => $composableBuilder(
    column: $table.exerciseFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeBrightness => $composableBuilder(
    column: $table.themeBrightness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cloudSyncEnabled => $composableBuilder(
    column: $table.cloudSyncEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsPeriod => $composableBuilder(
    column: $table.notificationsPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsOvulation => $composableBuilder(
    column: $table.notificationsOvulation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsDailyCheckin => $composableBuilder(
    column: $table.notificationsDailyCheckin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationLeadDays => $composableBuilder(
    column: $table.notificationLeadDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<int> get avgCycleDays => $composableBuilder(
    column: $table.avgCycleDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgPeriodDays => $composableBuilder(
    column: $table.avgPeriodDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cycleLengthKnown => $composableBuilder(
    column: $table.cycleLengthKnown,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onHormonalContraception => $composableBuilder(
    column: $table.onHormonalContraception,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasPcos =>
      $composableBuilder(column: $table.hasPcos, builder: (column) => column);

  GeneratedColumn<bool> get hasEndo =>
      $composableBuilder(column: $table.hasEndo, builder: (column) => column);

  GeneratedColumn<String> get trackingGoals => $composableBuilder(
    column: $table.trackingGoals,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commonSymptoms => $composableBuilder(
    column: $table.commonSymptoms,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baselineStress => $composableBuilder(
    column: $table.baselineStress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseFrequency => $composableBuilder(
    column: $table.exerciseFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredLanguage => $composableBuilder(
    column: $table.preferredLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeBrightness => $composableBuilder(
    column: $table.themeBrightness,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cloudSyncEnabled => $composableBuilder(
    column: $table.cloudSyncEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsPeriod => $composableBuilder(
    column: $table.notificationsPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsOvulation => $composableBuilder(
    column: $table.notificationsOvulation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsDailyCheckin => $composableBuilder(
    column: $table.notificationsDailyCheckin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationLeadDays => $composableBuilder(
    column: $table.notificationLeadDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          UserRow,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTableTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> birthYear = const Value.absent(),
                Value<int> avgCycleDays = const Value.absent(),
                Value<int> avgPeriodDays = const Value.absent(),
                Value<bool> cycleLengthKnown = const Value.absent(),
                Value<bool> onHormonalContraception = const Value.absent(),
                Value<bool> hasPcos = const Value.absent(),
                Value<bool> hasEndo = const Value.absent(),
                Value<String?> trackingGoals = const Value.absent(),
                Value<String?> commonSymptoms = const Value.absent(),
                Value<int?> baselineStress = const Value.absent(),
                Value<String?> exerciseFrequency = const Value.absent(),
                Value<String> preferredLanguage = const Value.absent(),
                Value<String> themeBrightness = const Value.absent(),
                Value<bool> cloudSyncEnabled = const Value.absent(),
                Value<bool> notificationsPeriod = const Value.absent(),
                Value<bool> notificationsOvulation = const Value.absent(),
                Value<bool> notificationsDailyCheckin = const Value.absent(),
                Value<int> notificationLeadDays = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                displayName: displayName,
                birthYear: birthYear,
                avgCycleDays: avgCycleDays,
                avgPeriodDays: avgPeriodDays,
                cycleLengthKnown: cycleLengthKnown,
                onHormonalContraception: onHormonalContraception,
                hasPcos: hasPcos,
                hasEndo: hasEndo,
                trackingGoals: trackingGoals,
                commonSymptoms: commonSymptoms,
                baselineStress: baselineStress,
                exerciseFrequency: exerciseFrequency,
                preferredLanguage: preferredLanguage,
                themeBrightness: themeBrightness,
                cloudSyncEnabled: cloudSyncEnabled,
                notificationsPeriod: notificationsPeriod,
                notificationsOvulation: notificationsOvulation,
                notificationsDailyCheckin: notificationsDailyCheckin,
                notificationLeadDays: notificationLeadDays,
                onboarded: onboarded,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required int birthYear,
                Value<int> avgCycleDays = const Value.absent(),
                Value<int> avgPeriodDays = const Value.absent(),
                Value<bool> cycleLengthKnown = const Value.absent(),
                Value<bool> onHormonalContraception = const Value.absent(),
                Value<bool> hasPcos = const Value.absent(),
                Value<bool> hasEndo = const Value.absent(),
                Value<String?> trackingGoals = const Value.absent(),
                Value<String?> commonSymptoms = const Value.absent(),
                Value<int?> baselineStress = const Value.absent(),
                Value<String?> exerciseFrequency = const Value.absent(),
                Value<String> preferredLanguage = const Value.absent(),
                Value<String> themeBrightness = const Value.absent(),
                Value<bool> cloudSyncEnabled = const Value.absent(),
                Value<bool> notificationsPeriod = const Value.absent(),
                Value<bool> notificationsOvulation = const Value.absent(),
                Value<bool> notificationsDailyCheckin = const Value.absent(),
                Value<int> notificationLeadDays = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                required int createdAt,
              }) => UsersTableCompanion.insert(
                id: id,
                displayName: displayName,
                birthYear: birthYear,
                avgCycleDays: avgCycleDays,
                avgPeriodDays: avgPeriodDays,
                cycleLengthKnown: cycleLengthKnown,
                onHormonalContraception: onHormonalContraception,
                hasPcos: hasPcos,
                hasEndo: hasEndo,
                trackingGoals: trackingGoals,
                commonSymptoms: commonSymptoms,
                baselineStress: baselineStress,
                exerciseFrequency: exerciseFrequency,
                preferredLanguage: preferredLanguage,
                themeBrightness: themeBrightness,
                cloudSyncEnabled: cloudSyncEnabled,
                notificationsPeriod: notificationsPeriod,
                notificationsOvulation: notificationsOvulation,
                notificationsDailyCheckin: notificationsDailyCheckin,
                notificationLeadDays: notificationLeadDays,
                onboarded: onboarded,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      UserRow,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTableTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$CycleEntriesTableTableCreateCompanionBuilder =
    CycleEntriesTableCompanion Function({
      Value<int> id,
      required String startDate,
      Value<String?> endDate,
      Value<int?> cycleLength,
      Value<int?> periodLength,
      Value<String?> notes,
      Value<bool> isSeeded,
      required int createdAt,
    });
typedef $$CycleEntriesTableTableUpdateCompanionBuilder =
    CycleEntriesTableCompanion Function({
      Value<int> id,
      Value<String> startDate,
      Value<String?> endDate,
      Value<int?> cycleLength,
      Value<int?> periodLength,
      Value<String?> notes,
      Value<bool> isSeeded,
      Value<int> createdAt,
    });

final class $$CycleEntriesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $CycleEntriesTableTable, CycleEntryRow> {
  $$CycleEntriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PeriodDayLogsTableTable, List<PeriodDayRow>>
  _periodDayLogsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.periodDayLogsTable,
        aliasName: $_aliasNameGenerator(
          db.cycleEntriesTable.id,
          db.periodDayLogsTable.cycleEntryId,
        ),
      );

  $$PeriodDayLogsTableTableProcessedTableManager get periodDayLogsTableRefs {
    final manager = $$PeriodDayLogsTableTableTableManager(
      $_db,
      $_db.periodDayLogsTable,
    ).filter((f) => f.cycleEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _periodDayLogsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CycleEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CycleEntriesTableTable> {
  $$CycleEntriesTableTableFilterComposer({
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

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSeeded => $composableBuilder(
    column: $table.isSeeded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> periodDayLogsTableRefs(
    Expression<bool> Function($$PeriodDayLogsTableTableFilterComposer f) f,
  ) {
    final $$PeriodDayLogsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.periodDayLogsTable,
      getReferencedColumn: (t) => t.cycleEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeriodDayLogsTableTableFilterComposer(
            $db: $db,
            $table: $db.periodDayLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CycleEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleEntriesTableTable> {
  $$CycleEntriesTableTableOrderingComposer({
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

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSeeded => $composableBuilder(
    column: $table.isSeeded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CycleEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleEntriesTableTable> {
  $$CycleEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get cycleLength => $composableBuilder(
    column: $table.cycleLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodLength => $composableBuilder(
    column: $table.periodLength,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSeeded =>
      $composableBuilder(column: $table.isSeeded, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> periodDayLogsTableRefs<T extends Object>(
    Expression<T> Function($$PeriodDayLogsTableTableAnnotationComposer a) f,
  ) {
    final $$PeriodDayLogsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.periodDayLogsTable,
          getReferencedColumn: (t) => t.cycleEntryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PeriodDayLogsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.periodDayLogsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CycleEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CycleEntriesTableTable,
          CycleEntryRow,
          $$CycleEntriesTableTableFilterComposer,
          $$CycleEntriesTableTableOrderingComposer,
          $$CycleEntriesTableTableAnnotationComposer,
          $$CycleEntriesTableTableCreateCompanionBuilder,
          $$CycleEntriesTableTableUpdateCompanionBuilder,
          (CycleEntryRow, $$CycleEntriesTableTableReferences),
          CycleEntryRow,
          PrefetchHooks Function({bool periodDayLogsTableRefs})
        > {
  $$CycleEntriesTableTableTableManager(
    _$AppDatabase db,
    $CycleEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleEntriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<int?> cycleLength = const Value.absent(),
                Value<int?> periodLength = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isSeeded = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => CycleEntriesTableCompanion(
                id: id,
                startDate: startDate,
                endDate: endDate,
                cycleLength: cycleLength,
                periodLength: periodLength,
                notes: notes,
                isSeeded: isSeeded,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<int?> cycleLength = const Value.absent(),
                Value<int?> periodLength = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isSeeded = const Value.absent(),
                required int createdAt,
              }) => CycleEntriesTableCompanion.insert(
                id: id,
                startDate: startDate,
                endDate: endDate,
                cycleLength: cycleLength,
                periodLength: periodLength,
                notes: notes,
                isSeeded: isSeeded,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CycleEntriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodDayLogsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (periodDayLogsTableRefs) db.periodDayLogsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (periodDayLogsTableRefs)
                    await $_getPrefetchedData<
                      CycleEntryRow,
                      $CycleEntriesTableTable,
                      PeriodDayRow
                    >(
                      currentTable: table,
                      referencedTable: $$CycleEntriesTableTableReferences
                          ._periodDayLogsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CycleEntriesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).periodDayLogsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.cycleEntryId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CycleEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CycleEntriesTableTable,
      CycleEntryRow,
      $$CycleEntriesTableTableFilterComposer,
      $$CycleEntriesTableTableOrderingComposer,
      $$CycleEntriesTableTableAnnotationComposer,
      $$CycleEntriesTableTableCreateCompanionBuilder,
      $$CycleEntriesTableTableUpdateCompanionBuilder,
      (CycleEntryRow, $$CycleEntriesTableTableReferences),
      CycleEntryRow,
      PrefetchHooks Function({bool periodDayLogsTableRefs})
    >;
typedef $$PeriodDayLogsTableTableCreateCompanionBuilder =
    PeriodDayLogsTableCompanion Function({
      Value<int> id,
      required int cycleEntryId,
      required String date,
      required String flow,
    });
typedef $$PeriodDayLogsTableTableUpdateCompanionBuilder =
    PeriodDayLogsTableCompanion Function({
      Value<int> id,
      Value<int> cycleEntryId,
      Value<String> date,
      Value<String> flow,
    });

final class $$PeriodDayLogsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PeriodDayLogsTableTable, PeriodDayRow> {
  $$PeriodDayLogsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CycleEntriesTableTable _cycleEntryIdTable(_$AppDatabase db) =>
      db.cycleEntriesTable.createAlias(
        $_aliasNameGenerator(
          db.periodDayLogsTable.cycleEntryId,
          db.cycleEntriesTable.id,
        ),
      );

  $$CycleEntriesTableTableProcessedTableManager get cycleEntryId {
    final $_column = $_itemColumn<int>('cycle_entry_id')!;

    final manager = $$CycleEntriesTableTableTableManager(
      $_db,
      $_db.cycleEntriesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PeriodDayLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodDayLogsTableTable> {
  $$PeriodDayLogsTableTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flow => $composableBuilder(
    column: $table.flow,
    builder: (column) => ColumnFilters(column),
  );

  $$CycleEntriesTableTableFilterComposer get cycleEntryId {
    final $$CycleEntriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleEntryId,
      referencedTable: $db.cycleEntriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CycleEntriesTableTableFilterComposer(
            $db: $db,
            $table: $db.cycleEntriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodDayLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodDayLogsTableTable> {
  $$PeriodDayLogsTableTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flow => $composableBuilder(
    column: $table.flow,
    builder: (column) => ColumnOrderings(column),
  );

  $$CycleEntriesTableTableOrderingComposer get cycleEntryId {
    final $$CycleEntriesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleEntryId,
      referencedTable: $db.cycleEntriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CycleEntriesTableTableOrderingComposer(
            $db: $db,
            $table: $db.cycleEntriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PeriodDayLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodDayLogsTableTable> {
  $$PeriodDayLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get flow =>
      $composableBuilder(column: $table.flow, builder: (column) => column);

  $$CycleEntriesTableTableAnnotationComposer get cycleEntryId {
    final $$CycleEntriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.cycleEntryId,
          referencedTable: $db.cycleEntriesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CycleEntriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.cycleEntriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PeriodDayLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodDayLogsTableTable,
          PeriodDayRow,
          $$PeriodDayLogsTableTableFilterComposer,
          $$PeriodDayLogsTableTableOrderingComposer,
          $$PeriodDayLogsTableTableAnnotationComposer,
          $$PeriodDayLogsTableTableCreateCompanionBuilder,
          $$PeriodDayLogsTableTableUpdateCompanionBuilder,
          (PeriodDayRow, $$PeriodDayLogsTableTableReferences),
          PeriodDayRow,
          PrefetchHooks Function({bool cycleEntryId})
        > {
  $$PeriodDayLogsTableTableTableManager(
    _$AppDatabase db,
    $PeriodDayLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodDayLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodDayLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodDayLogsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cycleEntryId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> flow = const Value.absent(),
              }) => PeriodDayLogsTableCompanion(
                id: id,
                cycleEntryId: cycleEntryId,
                date: date,
                flow: flow,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cycleEntryId,
                required String date,
                required String flow,
              }) => PeriodDayLogsTableCompanion.insert(
                id: id,
                cycleEntryId: cycleEntryId,
                date: date,
                flow: flow,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PeriodDayLogsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cycleEntryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cycleEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cycleEntryId,
                                referencedTable:
                                    $$PeriodDayLogsTableTableReferences
                                        ._cycleEntryIdTable(db),
                                referencedColumn:
                                    $$PeriodDayLogsTableTableReferences
                                        ._cycleEntryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PeriodDayLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodDayLogsTableTable,
      PeriodDayRow,
      $$PeriodDayLogsTableTableFilterComposer,
      $$PeriodDayLogsTableTableOrderingComposer,
      $$PeriodDayLogsTableTableAnnotationComposer,
      $$PeriodDayLogsTableTableCreateCompanionBuilder,
      $$PeriodDayLogsTableTableUpdateCompanionBuilder,
      (PeriodDayRow, $$PeriodDayLogsTableTableReferences),
      PeriodDayRow,
      PrefetchHooks Function({bool cycleEntryId})
    >;
typedef $$SymptomLogsTableTableCreateCompanionBuilder =
    SymptomLogsTableCompanion Function({
      Value<int> id,
      required String date,
      required String symptom,
      required int severity,
      Value<String?> notes,
      required int createdAt,
    });
typedef $$SymptomLogsTableTableUpdateCompanionBuilder =
    SymptomLogsTableCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> symptom,
      Value<int> severity,
      Value<String?> notes,
      Value<int> createdAt,
    });

class $$SymptomLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomLogsTableTable> {
  $$SymptomLogsTableTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptom => $composableBuilder(
    column: $table.symptom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SymptomLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomLogsTableTable> {
  $$SymptomLogsTableTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptom => $composableBuilder(
    column: $table.symptom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SymptomLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomLogsTableTable> {
  $$SymptomLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get symptom =>
      $composableBuilder(column: $table.symptom, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SymptomLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SymptomLogsTableTable,
          SymptomRow,
          $$SymptomLogsTableTableFilterComposer,
          $$SymptomLogsTableTableOrderingComposer,
          $$SymptomLogsTableTableAnnotationComposer,
          $$SymptomLogsTableTableCreateCompanionBuilder,
          $$SymptomLogsTableTableUpdateCompanionBuilder,
          (
            SymptomRow,
            BaseReferences<_$AppDatabase, $SymptomLogsTableTable, SymptomRow>,
          ),
          SymptomRow,
          PrefetchHooks Function()
        > {
  $$SymptomLogsTableTableTableManager(
    _$AppDatabase db,
    $SymptomLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> symptom = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => SymptomLogsTableCompanion(
                id: id,
                date: date,
                symptom: symptom,
                severity: severity,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String symptom,
                required int severity,
                Value<String?> notes = const Value.absent(),
                required int createdAt,
              }) => SymptomLogsTableCompanion.insert(
                id: id,
                date: date,
                symptom: symptom,
                severity: severity,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SymptomLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SymptomLogsTableTable,
      SymptomRow,
      $$SymptomLogsTableTableFilterComposer,
      $$SymptomLogsTableTableOrderingComposer,
      $$SymptomLogsTableTableAnnotationComposer,
      $$SymptomLogsTableTableCreateCompanionBuilder,
      $$SymptomLogsTableTableUpdateCompanionBuilder,
      (
        SymptomRow,
        BaseReferences<_$AppDatabase, $SymptomLogsTableTable, SymptomRow>,
      ),
      SymptomRow,
      PrefetchHooks Function()
    >;
typedef $$MoodLogsTableTableCreateCompanionBuilder =
    MoodLogsTableCompanion Function({
      Value<int> id,
      required String date,
      required String mood,
      required int energyLevel,
      Value<String?> notes,
      required int createdAt,
    });
typedef $$MoodLogsTableTableUpdateCompanionBuilder =
    MoodLogsTableCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> mood,
      Value<int> energyLevel,
      Value<String?> notes,
      Value<int> createdAt,
    });

class $$MoodLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MoodLogsTableTable> {
  $$MoodLogsTableTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoodLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodLogsTableTable> {
  $$MoodLogsTableTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoodLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodLogsTableTable> {
  $$MoodLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MoodLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodLogsTableTable,
          MoodRow,
          $$MoodLogsTableTableFilterComposer,
          $$MoodLogsTableTableOrderingComposer,
          $$MoodLogsTableTableAnnotationComposer,
          $$MoodLogsTableTableCreateCompanionBuilder,
          $$MoodLogsTableTableUpdateCompanionBuilder,
          (
            MoodRow,
            BaseReferences<_$AppDatabase, $MoodLogsTableTable, MoodRow>,
          ),
          MoodRow,
          PrefetchHooks Function()
        > {
  $$MoodLogsTableTableTableManager(_$AppDatabase db, $MoodLogsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> mood = const Value.absent(),
                Value<int> energyLevel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => MoodLogsTableCompanion(
                id: id,
                date: date,
                mood: mood,
                energyLevel: energyLevel,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String mood,
                required int energyLevel,
                Value<String?> notes = const Value.absent(),
                required int createdAt,
              }) => MoodLogsTableCompanion.insert(
                id: id,
                date: date,
                mood: mood,
                energyLevel: energyLevel,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoodLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodLogsTableTable,
      MoodRow,
      $$MoodLogsTableTableFilterComposer,
      $$MoodLogsTableTableOrderingComposer,
      $$MoodLogsTableTableAnnotationComposer,
      $$MoodLogsTableTableCreateCompanionBuilder,
      $$MoodLogsTableTableUpdateCompanionBuilder,
      (MoodRow, BaseReferences<_$AppDatabase, $MoodLogsTableTable, MoodRow>),
      MoodRow,
      PrefetchHooks Function()
    >;
typedef $$HealthNotesTableTableCreateCompanionBuilder =
    HealthNotesTableCompanion Function({
      Value<int> id,
      required String date,
      required String content,
      Value<String?> tags,
      required int createdAt,
    });
typedef $$HealthNotesTableTableUpdateCompanionBuilder =
    HealthNotesTableCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> content,
      Value<String?> tags,
      Value<int> createdAt,
    });

class $$HealthNotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $HealthNotesTableTable> {
  $$HealthNotesTableTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthNotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthNotesTableTable> {
  $$HealthNotesTableTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthNotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthNotesTableTable> {
  $$HealthNotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HealthNotesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthNotesTableTable,
          HealthNoteRow,
          $$HealthNotesTableTableFilterComposer,
          $$HealthNotesTableTableOrderingComposer,
          $$HealthNotesTableTableAnnotationComposer,
          $$HealthNotesTableTableCreateCompanionBuilder,
          $$HealthNotesTableTableUpdateCompanionBuilder,
          (
            HealthNoteRow,
            BaseReferences<
              _$AppDatabase,
              $HealthNotesTableTable,
              HealthNoteRow
            >,
          ),
          HealthNoteRow,
          PrefetchHooks Function()
        > {
  $$HealthNotesTableTableTableManager(
    _$AppDatabase db,
    $HealthNotesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthNotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthNotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthNotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => HealthNotesTableCompanion(
                id: id,
                date: date,
                content: content,
                tags: tags,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String content,
                Value<String?> tags = const Value.absent(),
                required int createdAt,
              }) => HealthNotesTableCompanion.insert(
                id: id,
                date: date,
                content: content,
                tags: tags,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthNotesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthNotesTableTable,
      HealthNoteRow,
      $$HealthNotesTableTableFilterComposer,
      $$HealthNotesTableTableOrderingComposer,
      $$HealthNotesTableTableAnnotationComposer,
      $$HealthNotesTableTableCreateCompanionBuilder,
      $$HealthNotesTableTableUpdateCompanionBuilder,
      (
        HealthNoteRow,
        BaseReferences<_$AppDatabase, $HealthNotesTableTable, HealthNoteRow>,
      ),
      HealthNoteRow,
      PrefetchHooks Function()
    >;
typedef $$AiInsightsCacheTableTableCreateCompanionBuilder =
    AiInsightsCacheTableCompanion Function({
      Value<int> id,
      Value<int?> cycleEntryId,
      required String insightType,
      required String content,
      required int generatedAt,
      Value<bool> isStale,
    });
typedef $$AiInsightsCacheTableTableUpdateCompanionBuilder =
    AiInsightsCacheTableCompanion Function({
      Value<int> id,
      Value<int?> cycleEntryId,
      Value<String> insightType,
      Value<String> content,
      Value<int> generatedAt,
      Value<bool> isStale,
    });

class $$AiInsightsCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $AiInsightsCacheTableTable> {
  $$AiInsightsCacheTableTableFilterComposer({
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

  ColumnFilters<int> get cycleEntryId => $composableBuilder(
    column: $table.cycleEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStale => $composableBuilder(
    column: $table.isStale,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiInsightsCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AiInsightsCacheTableTable> {
  $$AiInsightsCacheTableTableOrderingComposer({
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

  ColumnOrderings<int> get cycleEntryId => $composableBuilder(
    column: $table.cycleEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStale => $composableBuilder(
    column: $table.isStale,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiInsightsCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiInsightsCacheTableTable> {
  $$AiInsightsCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleEntryId => $composableBuilder(
    column: $table.cycleEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStale =>
      $composableBuilder(column: $table.isStale, builder: (column) => column);
}

class $$AiInsightsCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiInsightsCacheTableTable,
          AiInsightRow,
          $$AiInsightsCacheTableTableFilterComposer,
          $$AiInsightsCacheTableTableOrderingComposer,
          $$AiInsightsCacheTableTableAnnotationComposer,
          $$AiInsightsCacheTableTableCreateCompanionBuilder,
          $$AiInsightsCacheTableTableUpdateCompanionBuilder,
          (
            AiInsightRow,
            BaseReferences<
              _$AppDatabase,
              $AiInsightsCacheTableTable,
              AiInsightRow
            >,
          ),
          AiInsightRow,
          PrefetchHooks Function()
        > {
  $$AiInsightsCacheTableTableTableManager(
    _$AppDatabase db,
    $AiInsightsCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiInsightsCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiInsightsCacheTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AiInsightsCacheTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> cycleEntryId = const Value.absent(),
                Value<String> insightType = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> generatedAt = const Value.absent(),
                Value<bool> isStale = const Value.absent(),
              }) => AiInsightsCacheTableCompanion(
                id: id,
                cycleEntryId: cycleEntryId,
                insightType: insightType,
                content: content,
                generatedAt: generatedAt,
                isStale: isStale,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> cycleEntryId = const Value.absent(),
                required String insightType,
                required String content,
                required int generatedAt,
                Value<bool> isStale = const Value.absent(),
              }) => AiInsightsCacheTableCompanion.insert(
                id: id,
                cycleEntryId: cycleEntryId,
                insightType: insightType,
                content: content,
                generatedAt: generatedAt,
                isStale: isStale,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiInsightsCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiInsightsCacheTableTable,
      AiInsightRow,
      $$AiInsightsCacheTableTableFilterComposer,
      $$AiInsightsCacheTableTableOrderingComposer,
      $$AiInsightsCacheTableTableAnnotationComposer,
      $$AiInsightsCacheTableTableCreateCompanionBuilder,
      $$AiInsightsCacheTableTableUpdateCompanionBuilder,
      (
        AiInsightRow,
        BaseReferences<_$AppDatabase, $AiInsightsCacheTableTable, AiInsightRow>,
      ),
      AiInsightRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$CycleEntriesTableTableTableManager get cycleEntriesTable =>
      $$CycleEntriesTableTableTableManager(_db, _db.cycleEntriesTable);
  $$PeriodDayLogsTableTableTableManager get periodDayLogsTable =>
      $$PeriodDayLogsTableTableTableManager(_db, _db.periodDayLogsTable);
  $$SymptomLogsTableTableTableManager get symptomLogsTable =>
      $$SymptomLogsTableTableTableManager(_db, _db.symptomLogsTable);
  $$MoodLogsTableTableTableManager get moodLogsTable =>
      $$MoodLogsTableTableTableManager(_db, _db.moodLogsTable);
  $$HealthNotesTableTableTableManager get healthNotesTable =>
      $$HealthNotesTableTableTableManager(_db, _db.healthNotesTable);
  $$AiInsightsCacheTableTableTableManager get aiInsightsCacheTable =>
      $$AiInsightsCacheTableTableTableManager(_db, _db.aiInsightsCacheTable);
}
