import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_prefs.dart';
import 'vocabulary_book_service.dart';

enum StatsPeriod { daily, weekly, monthly }

enum LearningActivity {
  vocabulary,
  listening,
  speaking,
  writing,
  quiz,
  flashcards,
}

class StatsSnapshot {
  const StatsSnapshot({
    required this.period,
    required this.seriesLabels,
    required this.seriesMinutes,
    required this.seriesHeights,
    required this.highlightIndex,
    required this.weeklyGoalMinutes,
    required this.currentWeeklyMinutes,
    required this.level,
    required this.nextLevel,
    required this.levelProgress,
    required this.streakDays,
    required this.skills,
    required this.badges,
  });

  final StatsPeriod period;

  /// Labels shown under the bar chart (7/4/6 items depending on [period]).
  final List<String> seriesLabels;

  /// Raw minutes for each bar, same length as [seriesLabels].
  final List<int> seriesMinutes;

  /// Normalized bar heights in range 0..1, same length as [seriesLabels].
  final List<double> seriesHeights;

  /// Index in series to highlight (e.g. today/this week/this month).
  final int highlightIndex;

  final int weeklyGoalMinutes;
  final int currentWeeklyMinutes;

  final String level;
  final String nextLevel;
  final double levelProgress; // 0..1

  final int streakDays;

  /// 0..1 skills
  final Map<String, double> skills;

  /// badgeId -> unlocked
  final Map<String, bool> badges;
}

class StatsStore {
  StatsStore._();

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static const _kWeeklyGoalMinutes = 'stats.weeklyGoalMinutes';

  static const _kStreakLastDay = 'stats.streak.lastDay';
  static const _kStreakCount = 'stats.streak.count';

  static const _kListeningTotalMinutes = 'stats.totalMinutes.listening';

  static const _kSkillVocabulary = 'stats.skill.vocabulary.bps';
  static const _kSkillListening = 'stats.skill.listening.bps';
  static const _kSkillSpeaking = 'stats.skill.speaking.bps';
  static const _kSkillWriting = 'stats.skill.writing.bps';

  static String _kStudyMinutesDay(int yyyymmdd) =>
      'stats.study.minutes.$yyyymmdd';

  static String _kLevelProgress(String level) =>
      'stats.level.progress.$level.bps';

  static String _kBadge(String id) => 'stats.badge.$id';

  static int yyyymmdd(DateTime dt) => (dt.year * 10000) + (dt.month * 100) + dt.day;

  static DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static int _daysBetween(DateTime a, DateTime b) =>
      b.difference(a).inDays;

  static Future<int> getWeeklyGoalMinutes() async {
    final p = await _prefs;
    return p.getInt(_kWeeklyGoalMinutes) ?? 300; // 5 hours default
  }

  static Future<void> setWeeklyGoalMinutes(int minutes) async {
    final p = await _prefs;
    await p.setInt(_kWeeklyGoalMinutes, minutes.clamp(30, 7 * 24 * 60));
  }

  static Future<int> getStudyMinutesForDay(DateTime day) async {
    final p = await _prefs;
    final key = _kStudyMinutesDay(yyyymmdd(day));
    return p.getInt(key) ?? 0;
  }

  static int _posInt(int v) => v < 0 ? 0 : v;

  static Future<void> addStudyMinutes(
    int minutes, {
    required LearningActivity activity,
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final dayKey = _kStudyMinutesDay(yyyymmdd(n));

    final p = await _prefs;
    final current = p.getInt(dayKey) ?? 0;
    final next = current + _posInt(minutes);
    await p.setInt(dayKey, next);

    // Activity totals used for badges
    if (activity == LearningActivity.listening) {
      final lt = p.getInt(_kListeningTotalMinutes) ?? 0;
      await p.setInt(_kListeningTotalMinutes, lt + _posInt(minutes));
    }

    // Update streak when daily minutes crosses threshold.
    await _maybeUpdateStreak(p, n);

    // Apply small skill increments
    await bumpSkill(activity, minutes: minutes, now: n);

    // Badges can depend on multiple sources; recompute after updates.
    await recomputeBadges();
  }

  static Future<void> _maybeUpdateStreak(SharedPreferences p, DateTime now) async {
    const int thresholdMinutes = 5;
    final today = yyyymmdd(now);
    final todayMinutes = p.getInt(_kStudyMinutesDay(today)) ?? 0;
    if (todayMinutes < thresholdMinutes) return;

    final last = p.getInt(_kStreakLastDay);
    final streak = p.getInt(_kStreakCount) ?? 0;

    if (last == null) {
      await p.setInt(_kStreakLastDay, today);
      await p.setInt(_kStreakCount, 1);
      return;
    }

    if (last == today) return; // already counted today

    final lastDt = DateTime(last ~/ 10000, (last % 10000) ~/ 100, last % 100);
    final nowDt = _startOfDay(now);
    final delta = _daysBetween(lastDt, nowDt);
    if (delta == 1) {
      await p.setInt(_kStreakLastDay, today);
      await p.setInt(_kStreakCount, streak + 1);
    } else {
      await p.setInt(_kStreakLastDay, today);
      await p.setInt(_kStreakCount, 1);
    }
  }

  static Future<int> getStreakDays() async {
    final p = await _prefs;
    return p.getInt(_kStreakCount) ?? 0;
  }

  static Future<Map<String, double>> getSkills() async {
    final p = await _prefs;
    double readBps(String key, double fallback) =>
        ((p.getInt(key) ?? (fallback * 10000).round()) / 10000.0)
            .clamp(0.0, 1.0);

    return {
      'Vocabulary': readBps(_kSkillVocabulary, 0.35),
      'Listening': readBps(_kSkillListening, 0.30),
      'Speaking': readBps(_kSkillSpeaking, 0.25),
      'Writing': readBps(_kSkillWriting, 0.25),
    };
  }

  static Future<void> bumpSkill(
    LearningActivity activity, {
    int minutes = 1,
    DateTime? now,
  }) async {
    final p = await _prefs;
    final m = _posInt(minutes);

    // Convert to small increments (basis points), tuned to be noticeable but slow.
    int incBps;
    String? key;

    switch (activity) {
      case LearningActivity.vocabulary:
      case LearningActivity.flashcards:
        key = _kSkillVocabulary;
        incBps = 6 * m;
        break;
      case LearningActivity.listening:
        key = _kSkillListening;
        incBps = 7 * m;
        break;
      case LearningActivity.speaking:
        key = _kSkillSpeaking;
        incBps = 8 * m;
        break;
      case LearningActivity.writing:
        key = _kSkillWriting;
        incBps = 7 * m;
        break;
      case LearningActivity.quiz:
        // Quiz contributes mostly to vocabulary + a bit to writing.
        await _addBps(p, _kSkillVocabulary, 4 * m);
        await _addBps(p, _kSkillWriting, 2 * m);
        return;
    }

    await _addBps(p, key, incBps);
  }

  static Future<void> _addBps(SharedPreferences p, String key, int addBps) async {
    final cur = p.getInt(key) ?? 0;
    final next = (cur + addBps).clamp(0, 10000);
    await p.setInt(key, next);
  }

  static Future<double> getLevelProgress(String level) async {
    final p = await _prefs;
    final bps = p.getInt(_kLevelProgress(level)) ?? 0;
    return (bps / 10000.0).clamp(0.0, 1.0);
  }

  static Future<void> setLevelProgress(String level, double value) async {
    final p = await _prefs;
    final bps = (value.clamp(0.0, 1.0) * 10000).round();
    await p.setInt(_kLevelProgress(level), bps);
  }

  static String nextLevelFor(String level) {
    const order = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final idx = order.indexOf(level);
    if (idx < 0 || idx >= order.length - 1) return level;
    return order[idx + 1];
  }

  static Future<int> getCurrentWeeklyMinutes({DateTime? now}) async {
    final n = now ?? DateTime.now();
    final start = _startOfDay(n.subtract(Duration(days: n.weekday - 1))); // Monday
    var sum = 0;
    for (var i = 0; i < 7; i++) {
      sum += await getStudyMinutesForDay(start.add(Duration(days: i)));
    }
    return sum;
  }

  /// Last 7 days ending today (oldest -> newest), raw minutes.
  static Future<List<int>> getDailyMinutesLast7({DateTime? now}) async {
    final n = now ?? DateTime.now();
    final out = <int>[];
    for (var i = 6; i >= 0; i--) {
      out.add(await getStudyMinutesForDay(_startOfDay(n).subtract(Duration(days: i))));
    }
    return out;
  }

  static List<String> _labelsFor(StatsPeriod period, DateTime now) {
    switch (period) {
      case StatsPeriod.daily:
        // last 7 days ending today
        const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
        final out = <String>[];
        for (var i = 6; i >= 0; i--) {
          final d = _startOfDay(now).subtract(Duration(days: i));
          out.add(days[d.weekday - 1]);
        }
        return out;
      case StatsPeriod.weekly:
        // last 4 weeks ending this week
        return const ['1. Hafta', '2. Hafta', '3. Hafta', 'Bu Hafta'];
      case StatsPeriod.monthly:
        // last 6 months ending this month
        const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
        final out = <String>[];
        var y = now.year;
        var m = now.month;
        for (var i = 5; i >= 0; i--) {
          var mm = m - i;
          var yy = y;
          while (mm <= 0) {
            mm += 12;
            yy -= 1;
          }
          out.add(mm == now.month && yy == now.year ? 'Bu Ay' : months[mm - 1]);
        }
        return out;
    }
  }

  static Future<List<int>> _rawMinutesSeries(StatsPeriod period, DateTime now) async {
    switch (period) {
      case StatsPeriod.daily:
        final out = <int>[];
        for (var i = 6; i >= 0; i--) {
          out.add(await getStudyMinutesForDay(_startOfDay(now).subtract(Duration(days: i))));
        }
        return out;
      case StatsPeriod.weekly:
        // 4 buckets: [w-3, w-2, w-1, w0]
        final out = <int>[];
        final startOfThisWeek = _startOfDay(now.subtract(Duration(days: now.weekday - 1)));
        for (var wi = 3; wi >= 0; wi--) {
          final start = startOfThisWeek.subtract(Duration(days: 7 * wi));
          var sum = 0;
          for (var i = 0; i < 7; i++) {
            sum += await getStudyMinutesForDay(start.add(Duration(days: i)));
          }
          out.add(sum);
        }
        return out;
      case StatsPeriod.monthly:
        final out = <int>[];
        for (var i = 5; i >= 0; i--) {
          var y = now.year;
          var m = now.month - i;
          while (m <= 0) {
            m += 12;
            y -= 1;
          }
          final start = DateTime(y, m, 1);
          final end = DateTime(y, m + 1, 1);
          var sum = 0;
          for (var d = start;
              d.isBefore(end);
              d = d.add(const Duration(days: 1))) {
            sum += await getStudyMinutesForDay(d);
          }
          out.add(sum);
        }
        return out;
    }
  }

  static List<double> _normalize(List<int> minutes) {
    final maxV = minutes.isEmpty ? 0 : minutes.reduce(max);
    if (maxV <= 0) {
      return List<double>.filled(minutes.length, 0.08);
    }
    return minutes.map((m) => (m / maxV).clamp(0.05, 1.0)).toList();
  }

  static Future<Map<String, bool>> getBadges() async {
    final p = await _prefs;
    const ids = ['7_day_streak', '50_vocab', '1h_listening'];
    return {
      for (final id in ids) id: p.getBool(_kBadge(id)) ?? false,
    };
  }

  static Future<void> recomputeBadges() async {
    final p = await _prefs;
    final streak = p.getInt(_kStreakCount) ?? 0;
    final vocabCount = (await VocabularyBookService.loadWords()).length;
    final listeningTotal = p.getInt(_kListeningTotalMinutes) ?? 0;

    await p.setBool(_kBadge('7_day_streak'), streak >= 7);
    await p.setBool(_kBadge('50_vocab'), vocabCount >= 50);
    await p.setBool(_kBadge('1h_listening'), listeningTotal >= 60);
  }

  static Future<StatsSnapshot> getSnapshot(
    StatsPeriod period, {
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final level = await AppPrefs.getUserLevel();
    final nextLevel = nextLevelFor(level);
    final levelProgress = await getLevelProgress(level);
    final skills = await getSkills();
    final streakDays = await getStreakDays();

    final weeklyGoalMinutes = await getWeeklyGoalMinutes();
    final currentWeeklyMinutes = await getCurrentWeeklyMinutes(now: n);

    final labels = _labelsFor(period, n);
    final minutes = await _rawMinutesSeries(period, n);
    final heights = _normalize(minutes);

    final highlightIndex = switch (period) {
      StatsPeriod.daily => 6,
      StatsPeriod.weekly => 3,
      StatsPeriod.monthly => 5,
    };

    final badges = await getBadges();

    return StatsSnapshot(
      period: period,
      seriesLabels: labels,
      seriesMinutes: minutes,
      seriesHeights: heights,
      highlightIndex: highlightIndex,
      weeklyGoalMinutes: weeklyGoalMinutes,
      currentWeeklyMinutes: currentWeeklyMinutes,
      level: level,
      nextLevel: nextLevel,
      levelProgress: levelProgress,
      streakDays: streakDays,
      skills: skills,
      badges: badges,
    );
  }
}

