import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
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
    required this.activityBreakdown,
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

  /// Bu haftaki aktivite bazlı dakikalar (sadece > 0 olanlar).
  final Map<LearningActivity, int> activityBreakdown;
}

class StatsStore {
  StatsStore._();

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static const _kWeeklyGoalMinutes = 'stats.weeklyGoalMinutes';

  static const _kStreakLastDay = 'stats.streak.lastDay';
  static const _kStreakCount = 'stats.streak.count';

  static const _kListeningTotalMinutes = 'stats.totalMinutes.listening';

  /// Günlük aktiviteye göre dakika kaydı: stats.activity.{name}.{yyyymmdd}
  static String _kActivityDay(LearningActivity a, int d) =>
      'stats.activity.${a.name}.$d';

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
    final day = yyyymmdd(n);
    final dayKey = _kStudyMinutesDay(day);

    final p = await _prefs;
    final current = p.getInt(dayKey) ?? 0;
    final next = current + _posInt(minutes);
    await p.setInt(dayKey, next);

    // Aktiviteye göre ayrıntılı dakika takibi
    final actKey = _kActivityDay(activity, day);
    await p.setInt(actKey, (p.getInt(actKey) ?? 0) + _posInt(minutes));

    if (activity == LearningActivity.listening) {
      final lt = p.getInt(_kListeningTotalMinutes) ?? 0;
      await p.setInt(_kListeningTotalMinutes, lt + _posInt(minutes));
    }

    await _maybeUpdateStreak(p, n);
    await bumpSkill(activity, minutes: minutes, now: n);
    await recomputeBadges();

    // Backend'e çalışma seansını ve skill puanlarını asenkron olarak bildir.
    _syncStudyToBackend(day: day, minutes: _posInt(minutes));
    _syncSkillsToBackend();
  }

  /// Backend'den istatistikleri çekip yerel önbelleğe yazar.
  /// Hata olursa sessizce geçer (yerel veri korunur).
  static Future<void> syncFromBackend() async {
    try {
      final res = await ApiService.get('/stats');
      if (res.statusCode != 200) return;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final stats = body['stats'] as Map<String, dynamic>?;
      if (stats == null) return;

      final p = await _prefs;

      // Günlük dakikalar
      final daily = stats['dailyMinutes'] as List<dynamic>?;
      if (daily != null) {
        for (final entry in daily) {
          final e = entry as Map<String, dynamic>;
          final date = (e['date'] as num).toInt();
          final mins = (e['minutes'] as num).toInt();
          await p.setInt(_kStudyMinutesDay(date), mins);
        }
      }

      // Streak
      final streak = stats['streak'] as Map<String, dynamic>?;
      if (streak != null) {
        final lastDay = streak['lastDay'] as num?;
        final count = streak['count'] as num?;
        if (lastDay != null) await p.setInt(_kStreakLastDay, lastDay.toInt());
        if (count != null) await p.setInt(_kStreakCount, count.toInt());
      }

      // Skill puanları (basis points)
      final skills = stats['skills'] as Map<String, dynamic>?;
      if (skills != null) {
        final vocab = skills['vocabulary'] as num?;
        final listening = skills['listening'] as num?;
        final speaking = skills['speaking'] as num?;
        final writing = skills['writing'] as num?;
        if (vocab != null) await p.setInt(_kSkillVocabulary, vocab.toInt());
        if (listening != null) await p.setInt(_kSkillListening, listening.toInt());
        if (speaking != null) await p.setInt(_kSkillSpeaking, speaking.toInt());
        if (writing != null) await p.setInt(_kSkillWriting, writing.toInt());
      }

      // Level ilerleme
      final levelProgress = stats['levelProgress'] as Map<String, dynamic>?;
      if (levelProgress != null) {
        for (final e in levelProgress.entries) {
          await p.setInt(_kLevelProgress(e.key), (e.value as num).toInt());
        }
      }

      // Rozetler
      final badges = stats['badges'] as Map<String, dynamic>?;
      if (badges != null) {
        for (final e in badges.entries) {
          await p.setBool(_kBadge(e.key), e.value as bool? ?? false);
        }
      }

      // Diğer alanlar
      final listeningTotal = stats['listeningTotalMinutes'] as num?;
      if (listeningTotal != null) {
        await p.setInt(_kListeningTotalMinutes, listeningTotal.toInt());
      }
      final weeklyGoal = stats['weeklyGoalMinutes'] as num?;
      if (weeklyGoal != null) {
        await p.setInt(_kWeeklyGoalMinutes, weeklyGoal.toInt());
      }
    } catch (_) {}
  }

  static void _syncStudyToBackend({required int day, required int minutes}) {
    if (minutes <= 0) return;
    // Fire-and-forget: yerel önce güncellendi, backend sync arka planda.
    Future(() async {
      try {
        await ApiService.post('/stats/study', {'date': day, 'minutes': minutes});
      } catch (_) {}
    });
  }

  /// Skill puanlarını, streak'i ve dinleme toplamını backend'e gönderir.
  /// Fire-and-forget — hata olsa da yerel veriler korunur.
  static void _syncSkillsToBackend() {
    Future(() async {
      try {
        final p = await _prefs;
        await ApiService.put('/stats', {
          'skills': {
            'vocabulary': p.getInt(_kSkillVocabulary) ?? 0,
            'listening': p.getInt(_kSkillListening) ?? 0,
            'speaking': p.getInt(_kSkillSpeaking) ?? 0,
            'writing': p.getInt(_kSkillWriting) ?? 0,
          },
          'streak': {
            'lastDay': p.getInt(_kStreakLastDay),
            'count': p.getInt(_kStreakCount) ?? 0,
          },
          'listeningTotalMinutes': p.getInt(_kListeningTotalMinutes) ?? 0,
        });
      } catch (_) {}
    });
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

  /// Eski hardcoded skill default'larını (3500/3000/2500/2500) yerel önbellekten siler.
  /// Backend migration ile eşleşir; uygulama ilk açılışında bir kez çağrılır.
  static Future<void> clearOldSkillDefaults() async {
    const oldVocab = 3500;
    const oldListen = 3000;
    const oldSpeak = 2500;
    const oldWrite = 2500;
    final p = await _prefs;
    final v = p.getInt(_kSkillVocabulary) ?? 0;
    final l = p.getInt(_kSkillListening) ?? 0;
    final s = p.getInt(_kSkillSpeaking) ?? 0;
    final w = p.getInt(_kSkillWriting) ?? 0;
    // Yalnızca tam olarak eski default değerlere eşitse sıfırla.
    if (v == oldVocab && l == oldListen && s == oldSpeak && w == oldWrite) {
      await p.setInt(_kSkillVocabulary, 0);
      await p.setInt(_kSkillListening, 0);
      await p.setInt(_kSkillSpeaking, 0);
      await p.setInt(_kSkillWriting, 0);
    }
  }

  static Future<int> getStreakDays() async {
    final p = await _prefs;
    return p.getInt(_kStreakCount) ?? 0;
  }

  static Future<Map<String, double>> getSkills() async {
    final p = await _prefs;

    // Eski hardcoded default'ları (3500/3000/2500/2500) veya herhangi bir
    // kombinasyonunu anında sıfırla — backend restart beklemeye gerek yok.
    // Eski hardcoded default'ları (3500/3000/2500/2500) anında sıfırla.
    final isOldSeed =
        p.getInt(_kSkillVocabulary) == 3500 &&
        p.getInt(_kSkillListening)  == 3000 &&
        p.getInt(_kSkillSpeaking)   == 2500 &&
        p.getInt(_kSkillWriting)    == 2500;
    if (isOldSeed) {
      await p.setInt(_kSkillVocabulary, 0);
      await p.setInt(_kSkillListening,  0);
      await p.setInt(_kSkillSpeaking,   0);
      await p.setInt(_kSkillWriting,    0);
    }

    double readBps(String key) =>
        ((p.getInt(key) ?? 0) / 10000.0).clamp(0.0, 1.0);

    return {
      'Vocabulary': readBps(_kSkillVocabulary),
      'Listening':  readBps(_kSkillListening),
      'Speaking':   readBps(_kSkillSpeaking),
      'Writing':    readBps(_kSkillWriting),
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

  /// Bu haftaki (Pzt–Paz) aktivite bazlı dakikalar.
  static Future<Map<LearningActivity, int>> getActivityBreakdownThisWeek({
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final startOfWeek = _startOfDay(n.subtract(Duration(days: n.weekday - 1)));
    final p = await _prefs;
    final result = <LearningActivity, int>{};
    for (final activity in LearningActivity.values) {
      var sum = 0;
      for (var i = 0; i < 7; i++) {
        final d = yyyymmdd(startOfWeek.add(Duration(days: i)));
        sum += p.getInt(_kActivityDay(activity, d)) ?? 0;
      }
      if (sum > 0) result[activity] = sum;
    }
    return result;
  }

  /// Son 30 günde çalışma yapıldı mı? (en eskiden en yeniye).
  static Future<List<bool>> getDailyStudyLast30({DateTime? now}) async {
    final n = now ?? DateTime.now();
    final p = await _prefs;
    final result = <bool>[];
    for (var i = 29; i >= 0; i--) {
      final d = _startOfDay(n).subtract(Duration(days: i));
      final mins = p.getInt(_kStudyMinutesDay(yyyymmdd(d))) ?? 0;
      result.add(mins > 0);
    }
    return result;
  }

  /// Bu haftanın (Pzt–Paz) her günü için dakika listesi (7 eleman).
  static Future<List<int>> getDailyMinutesThisWeek({DateTime? now}) async {
    final n = now ?? DateTime.now();
    final startOfWeek = _startOfDay(n.subtract(Duration(days: n.weekday - 1)));
    final out = <int>[];
    for (var i = 0; i < 7; i++) {
      out.add(await getStudyMinutesForDay(startOfWeek.add(Duration(days: i))));
    }
    return out;
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
    bool syncFirst = false,
  }) async {
    if (syncFirst) await syncFromBackend();
    final n = now ?? DateTime.now();
    final level = await AppPrefs.getUserLevel();
    final nextLevel = nextLevelFor(level);
    final levelProgress = await getLevelProgress(level);
    final skills = await getSkills();
    final streakDays = await getStreakDays();
    final activityBreakdown = await getActivityBreakdownThisWeek(now: n);

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
      activityBreakdown: activityBreakdown,
    );
  }
}

