import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/entities/period_day.dart';
import '../../domain/entities/symptom_log.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/repositories/symptom_repository.dart';
import '../../domain/repositories/user_repository.dart';

class SyncService {
  final UserRepository _userRepo;
  final CycleRepository _cycleRepo;
  final SymptomRepository _symptomRepo;
  final MoodRepository _moodRepo;

  SyncService({
    required UserRepository userRepo,
    required CycleRepository cycleRepo,
    required SymptomRepository symptomRepo,
    required MoodRepository moodRepo,
  })  : _userRepo = userRepo,
        _cycleRepo = cycleRepo,
        _symptomRepo = symptomRepo,
        _moodRepo = moodRepo;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ── Push all local data to Firestore ────────────────────────────────────────

  Future<void> pushAll(String uid) async {
    final user = await _userRepo.getUser();
    final cycles = await _cycleRepo.getAllCycles();
    final symptoms = await _symptomRepo.getSymptomsForRange(
        '1970-01-01', '2100-01-01');
    final moods = await _moodRepo.getMoodsForRange('1970-01-01', '2100-01-01');

    final userDoc = _userDoc(uid);

    if (user != null) {
      await userDoc.set(_userToMap(user), SetOptions(merge: true));
    }

    await _batchWriteDocs(
      coll: userDoc.collection('cycles'),
      ids: cycles.map((c) => c.id.toString()).toList(),
      maps: cycles.map(_cycleToMap).toList(),
    );
    await _batchWriteDocs(
      coll: userDoc.collection('symptom_logs'),
      ids: symptoms.map((s) => s.id.toString()).toList(),
      maps: symptoms.map(_symptomToMap).toList(),
    );
    await _batchWriteDocs(
      coll: userDoc.collection('mood_logs'),
      ids: moods.map((m) => m.id.toString()).toList(),
      maps: moods.map(_moodToMap).toList(),
    );

    // Push period day logs (flow intensity per day).
    // Doc ID: "{cycleStartDate}_{date}" — stable across devices.
    final periodDayIds = <String>[];
    final periodDayMaps = <Map<String, dynamic>>[];
    for (final cycle in cycles) {
      final days = await _cycleRepo.getPeriodDaysForCycle(cycle.id);
      for (final day in days) {
        periodDayIds.add('${cycle.startDate}_${day.date}');
        periodDayMaps.add(_periodDayToMap(cycle.startDate, day));
      }
    }
    await _batchWriteDocs(
      coll: userDoc.collection('period_day_logs'),
      ids: periodDayIds,
      maps: periodDayMaps,
    );
  }

  // ── Pull Firestore data to local Drift (new device restore) ─────────────────
  // Returns true if Firestore had data to restore.

  Future<bool> restoreAll(String uid) async {
    final userSnap = await _userDoc(uid).get();
    if (!userSnap.exists) return false;

    final existingUser = await _userRepo.getUser();
    if (existingUser == null) {
      await _userRepo.saveUser(_userFromMap(userSnap.data()!));
    }

    // Map: cycleStartDate → new local auto-increment id, built while restoring.
    // Used below to re-link period_day_logs to the correct local cycle id.
    final cycleStartDateToId = <String, int>{};

    final localCycles = await _cycleRepo.getAllCycles();
    if (localCycles.isEmpty) {
      final cyclesSnap = await _userDoc(uid).collection('cycles').get();
      // Sort ascending so we insert in chronological order
      final sorted = cyclesSnap.docs
        ..sort((a, b) => (a.data()['createdAt'] as int? ?? 0)
            .compareTo(b.data()['createdAt'] as int? ?? 0));
      for (final doc in sorted) {
        final data = doc.data();
        final startDate = data['startDate'] as String;
        final newId = await _cycleRepo.startCycle(
          startDate,
          isSeeded: (data['isSeeded'] as bool?) ?? false,
        );
        cycleStartDateToId[startDate] = newId;
        final endDate = data['endDate'] as String?;
        if (endDate != null) {
          await _cycleRepo.endCycle(newId, endDate);
        }
      }
    } else {
      // Cycles already present (e.g. partial restore) — build map from local db.
      for (final c in localCycles) {
        cycleStartDateToId[c.startDate] = c.id;
      }
    }

    final localSymptoms = await _symptomRepo.getSymptomsForRange(
        '1970-01-01', '2100-01-01');
    if (localSymptoms.isEmpty) {
      final snap = await _userDoc(uid).collection('symptom_logs').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        await _symptomRepo.logSymptom(
          date: data['date'] as String,
          symptom: data['symptom'] as String,
          severity: data['severity'] as int,
          notes: data['notes'] as String?,
        );
      }
    }

    final localMoods =
        await _moodRepo.getMoodsForRange('1970-01-01', '2100-01-01');
    if (localMoods.isEmpty) {
      final snap = await _userDoc(uid).collection('mood_logs').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        await _moodRepo.logMood(
          date: data['date'] as String,
          mood: data['mood'] as String,
          energyLevel: data['energyLevel'] as int,
          notes: data['notes'] as String?,
        );
      }
    }

    // Restore period day logs — requires cycles to be present first so we can
    // map cycleStartDate back to the new local auto-increment id.
    if (cycleStartDateToId.isNotEmpty) {
      final periodDaysSnap =
          await _userDoc(uid).collection('period_day_logs').get();
      for (final doc in periodDaysSnap.docs) {
        final data = doc.data();
        final cycleStartDate = data['cycleStartDate'] as String?;
        if (cycleStartDate == null) continue;
        final localCycleId = cycleStartDateToId[cycleStartDate];
        if (localCycleId == null) continue; // orphaned doc — skip
        await _cycleRepo.logPeriodDay(
          localCycleId,
          data['date'] as String,
          data['flow'] as String,
        );
      }
    }

    return true;
  }

  // ── Batch write helper (chunks at 499 — Firestore batch limit is 500) ───────

  Future<void> _batchWriteDocs({
    required CollectionReference<Map<String, dynamic>> coll,
    required List<String> ids,
    required List<Map<String, dynamic>> maps,
  }) async {
    if (ids.isEmpty) return;
    const chunkSize = 499;
    for (int i = 0; i < ids.length; i += chunkSize) {
      final batch = _db.batch();
      final end = (i + chunkSize).clamp(0, ids.length);
      for (int j = i; j < end; j++) {
        batch.set(coll.doc(ids[j]), maps[j]);
      }
      await batch.commit();
    }
  }

  // ── Serialization ────────────────────────────────────────────────────────────

  Map<String, dynamic> _userToMap(User u) => {
        'displayName': u.displayName,
        'birthYear': u.birthYear,
        'avgCycleDays': u.avgCycleDays,
        'avgPeriodDays': u.avgPeriodDays,
        'cycleLengthKnown': u.cycleLengthKnown,
        'onHormonalContraception': u.onHormonalContraception,
        'hasPcos': u.hasPcos,
        'hasEndo': u.hasEndo,
        'trackingGoals': u.trackingGoals,
        'commonSymptoms': u.commonSymptoms,
        'baselineStress': u.baselineStress,
        'exerciseFrequency': u.exerciseFrequency,
        'preferredLanguage': u.preferredLanguage,
        'themeBrightness': u.themeBrightness,
        'notificationsPeriod': u.notificationsPeriod,
        'notificationsOvulation': u.notificationsOvulation,
        'notificationsDailyCheckin': u.notificationsDailyCheckin,
        'notificationLeadDays': u.notificationLeadDays,
        'onboarded': u.onboarded,
        'createdAt': u.createdAt,
      };

  User _userFromMap(Map<String, dynamic> m) => User(
        id: 1,
        displayName: m['displayName'] as String? ?? '',
        birthYear: m['birthYear'] as int? ?? 2000,
        avgCycleDays: m['avgCycleDays'] as int? ?? 28,
        avgPeriodDays: m['avgPeriodDays'] as int? ?? 5,
        cycleLengthKnown: m['cycleLengthKnown'] as bool? ?? true,
        onHormonalContraception:
            m['onHormonalContraception'] as bool? ?? false,
        hasPcos: m['hasPcos'] as bool? ?? false,
        hasEndo: m['hasEndo'] as bool? ?? false,
        trackingGoals:
            List<String>.from(m['trackingGoals'] as List? ?? const []),
        commonSymptoms:
            List<String>.from(m['commonSymptoms'] as List? ?? const []),
        baselineStress: m['baselineStress'] as int?,
        exerciseFrequency: m['exerciseFrequency'] as String?,
        preferredLanguage: m['preferredLanguage'] as String? ?? 'en',
        themeBrightness: m['themeBrightness'] as String? ?? 'dark',
        notificationsPeriod: m['notificationsPeriod'] as bool? ?? true,
        notificationsOvulation: m['notificationsOvulation'] as bool? ?? true,
        notificationsDailyCheckin:
            m['notificationsDailyCheckin'] as bool? ?? true,
        notificationLeadDays: m['notificationLeadDays'] as int? ?? 2,
        onboarded: m['onboarded'] as bool? ?? false,
        createdAt: m['createdAt'] as int? ??
            DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> _cycleToMap(CycleEntry c) => {
        'startDate': c.startDate,
        'endDate': c.endDate,
        'cycleLength': c.cycleLength,
        'periodLength': c.periodLength,
        'notes': c.notes,
        'isSeeded': c.isSeeded,
        'createdAt': c.createdAt,
      };

  Map<String, dynamic> _symptomToMap(SymptomLog s) => {
        'date': s.date,
        'symptom': s.symptom,
        'severity': s.severity,
        'notes': s.notes,
        'createdAt': s.createdAt,
      };

  Map<String, dynamic> _moodToMap(MoodLog m) => {
        'date': m.date,
        'mood': m.mood,
        'energyLevel': m.energyLevel,
        'notes': m.notes,
        'createdAt': m.createdAt,
      };

  Map<String, dynamic> _periodDayToMap(String cycleStartDate, PeriodDay d) => {
        'cycleStartDate': cycleStartDate,
        'date': d.date,
        'flow': d.flow,
      };
}
