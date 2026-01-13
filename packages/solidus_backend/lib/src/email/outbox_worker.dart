import 'dart:async';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../db/app_db.dart';
import 'email_sender.dart';

class EmailOutboxWorker {
  EmailOutboxWorker({
    required AppDatabase db,
    required EmailSender sender,
    required Logger logger,
    required Duration pollInterval,
    required int maxAttempts,
  })  : _db = db,
        _sender = sender,
        _logger = logger,
        _pollInterval = pollInterval,
        _maxAttempts = maxAttempts;

  final AppDatabase _db;
  final EmailSender _sender;
  final Logger _logger;
  final Duration _pollInterval;
  final int _maxAttempts;

  Timer? _timer;
  bool _running = false;
  bool _closed = false;

  void start() {
    if (_closed) return;
    _timer ??= Timer.periodic(_pollInterval, (_) => _tick());
    // kick immediately
    // ignore: unawaited_futures
    _tick();
  }

  Future<void> close() async {
    _closed = true;
    _timer?.cancel();
    _timer = null;
    await _sender.close();
  }

  Future<String> enqueue({
    required String to,
    required String from,
    required String subject,
    required String text,
    String? html,
    DateTime? now,
  }) async {
    final id = const Uuid().v4();
    final ts = (now ?? DateTime.now().toUtc());
    await _db.into(_db.emailOutbox).insert(
          EmailOutboxCompanion.insert(
            id: id,
            to: to,
            from: from,
            subject: subject,
            textBody: text,
            htmlBody: html == null ? const Value.absent() : Value(html),
            status: 'pending',
            attempts: const Value(0),
            nextAttemptAt: ts,
            sentAt: const Value.absent(),
            lastError: const Value.absent(),
            createdAt: ts,
            updatedAt: ts,
          ),
        );
    return id;
  }

  Future<void> sendNow({
    required String to,
    required String from,
    required String subject,
    required String text,
    String? html,
  }) async {
    await _sender.send(
      OutboundEmail(
        to: to,
        from: from,
        subject: subject,
        text: text,
        html: html,
      ),
    );
  }

  Future<void> _tick() async {
    if (_running || _closed) return;
    _running = true;
    try {
      await _processOnce();
    } finally {
      _running = false;
    }
  }

  Future<void> _processOnce() async {
    final now = DateTime.now().toUtc();
    final row = await (_db.select(_db.emailOutbox)
          ..where((e) =>
              e.status.equals('pending') &
              e.nextAttemptAt.isSmallerOrEqualValue(now))
          ..orderBy([
            (e) => OrderingTerm(expression: e.nextAttemptAt),
            (e) => OrderingTerm(expression: e.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return;

    final attempts = row.attempts + 1;
    final ts = DateTime.now().toUtc();

    try {
      await _sender.send(
        OutboundEmail(
          to: row.to,
          from: row.from,
          subject: row.subject,
          text: row.textBody,
          html: row.htmlBody,
        ),
      );
      await (_db.update(_db.emailOutbox)..where((e) => e.id.equals(row.id))).write(
        EmailOutboxCompanion(
          status: const Value('sent'),
          attempts: Value(attempts),
          sentAt: Value(ts),
          lastError: const Value.absent(),
          updatedAt: Value(ts),
        ),
      );
    } catch (e, st) {
      _logger.warning('email send failed (id=${row.id}): $e\n$st');
      final next = _computeBackoff(attempts, base: _pollInterval, max: const Duration(minutes: 30));
      final failedPermanently = attempts >= _maxAttempts;
      await (_db.update(_db.emailOutbox)..where((x) => x.id.equals(row.id))).write(
        EmailOutboxCompanion(
          status: Value(failedPermanently ? 'failed' : 'pending'),
          attempts: Value(attempts),
          nextAttemptAt: Value(ts.add(next)),
          lastError: Value(e.toString()),
          updatedAt: Value(ts),
        ),
      );
    }
  }
}

Duration _computeBackoff(int attempts, {required Duration base, required Duration max}) {
  // attempts starts at 1. Backoff: base * 2^(attempts-1)
  var factor = 1 << (attempts - 1);
  final ms = base.inMilliseconds * factor;
  final capped = ms > max.inMilliseconds ? max.inMilliseconds : ms;
  return Duration(milliseconds: capped);
}

