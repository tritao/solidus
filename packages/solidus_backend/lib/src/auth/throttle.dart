import 'dart:math';

import 'package:drift/drift.dart';

import '../db/app_db.dart';

class AuthThrottleService {
  AuthThrottleService({
    required AppDatabase db,
    required Duration baseBackoff,
    required Duration maxBackoff,
  })  : _db = db,
        _baseBackoff = baseBackoff,
        _maxBackoff = maxBackoff;

  final AppDatabase _db;
  final Duration _baseBackoff;
  final Duration _maxBackoff;

  Future<DateTime?> lockedUntil(String key) async {
    final row = await (_db.select(_db.authThrottles)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.lockedUntil;
  }

  Future<void> reset(String key) async {
    await (_db.delete(_db.authThrottles)..where((t) => t.key.equals(key))).go();
  }

  Future<DateTime> registerFailure(String key, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();

    final existing = await (_db.select(_db.authThrottles)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    final failures = (existing?.failures ?? 0) + 1;
    final backoff = _computeBackoff(failures);
    final lockedUntil = ts.add(backoff);

    await _db.into(_db.authThrottles).insertOnConflictUpdate(
          AuthThrottlesCompanion(
            key: Value(key),
            failures: Value(failures),
            lockedUntil: Value(lockedUntil),
            updatedAt: Value(ts),
          ),
        );

    return lockedUntil;
  }

  Duration _computeBackoff(int failures) {
    // base * 2^(failures-1), capped.
    final pow2 = 1 << (min(failures - 1, 20));
    final ms = _baseBackoff.inMilliseconds * pow2;
    final capped = min(ms, _maxBackoff.inMilliseconds);
    return Duration(milliseconds: capped);
  }
}

