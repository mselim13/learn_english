import 'dart:async';

import 'stats_store.dart';

/// Very lightweight on-screen session tracker.
///
/// Intended to be called from pages:
/// - initState: `StudySessionTracker.start(activity: ...)`
/// - dispose: `StudySessionTracker.stop()`
///
/// It records whole minutes (rounded down), so very short visits won't pollute stats.
class StudySessionTracker {
  StudySessionTracker._();

  static LearningActivity? _activity;
  static DateTime? _startedAt;
  static Timer? _heartbeat;

  /// Start (or restart) a study session.
  static void start({
    required LearningActivity activity,
    DateTime? now,
  }) {
    stop(now: now);

    _activity = activity;
    _startedAt = now ?? DateTime.now();

    // Heartbeat ensures stats also tick for long-running pages
    // even if the app is backgrounded/foregrounded without dispose.
    _heartbeat = Timer.periodic(const Duration(minutes: 1), (_) {
      flush(now: DateTime.now());
    });
  }

  /// Flush elapsed minutes without stopping the session.
  static Future<void> flush({DateTime? now}) async {
    if (_activity == null || _startedAt == null) return;
    final n = now ?? DateTime.now();
    final elapsed = n.difference(_startedAt!).inMinutes;
    if (elapsed <= 0) return;

    _startedAt = n;
    await StatsStore.addStudyMinutes(
      elapsed,
      activity: _activity!,
      now: n,
    );
  }

  /// Stop and persist any elapsed minutes.
  static void stop({DateTime? now}) {
    _heartbeat?.cancel();
    _heartbeat = null;

    // Fire-and-forget flush; caller is usually dispose().
    // ignore: discarded_futures
    flush(now: now);

    _activity = null;
    _startedAt = null;
  }
}

