import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../services/stats_store.dart';

enum _Period { daily, weekly, monthly }

class StatsPage extends StatefulWidget {
  const StatsPage({
    super.key,
    this.onExposeReload,
  });

  /// Çağrıldığında istatistikleri arka planda backend'den yenileyip
  /// UI'ı günceller. [MainNavigationPage] tab seçilince bunu çağırır.
  final void Function(VoidCallback reload)? onExposeReload;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  _Period _period = _Period.weekly;
  late Future<StatsSnapshot> _future;

  StatsPeriod _toStatsPeriod(_Period p) => switch (p) {
        _Period.daily => StatsPeriod.daily,
        _Period.weekly => StatsPeriod.weekly,
        _Period.monthly => StatsPeriod.monthly,
      };

  @override
  void initState() {
    super.initState();
    _future = StatsStore.getSnapshot(_toStatsPeriod(_period));
    widget.onExposeReload?.call(_reloadFromServer);
  }

  void _reload({_Period? period, bool syncFromServer = false}) {
    final p = period ?? _period;
    setState(() {
      _period = p;
      _future = StatsStore.getSnapshot(
        _toStatsPeriod(p),
        syncFirst: syncFromServer,
      );
    });
  }

  /// Önce önbellekteki veriyi göster, arka planda backend'den çek ve güncelle.
  void _reloadFromServer() {
    _reload();
    StatsStore.syncFromBackend().then((_) {
      if (mounted) _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: FutureBuilder<StatsSnapshot>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final s = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async => _reload(syncFromServer: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.horizontalPadding(context),
                      vertical: Responsive.verticalPadding(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        SizedBox(height: Responsive.gapMd(context)),
                        _buildBarChartCard(context, s),
                        SizedBox(height: Responsive.gapMd(context)),
                        _buildWeeklyGoalCard(context, s),
                        SizedBox(height: Responsive.gapMd(context)),
                        _buildLevelProgressCard(context, s),
                        SizedBox(height: Responsive.gapMd(context)),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _buildLearningTimeCard(context, s)),
                              SizedBox(width: Responsive.gapSm(context)),
                              Expanded(child: _buildSkillMasterCard(context, s)),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.gapMd(context)),
                        _buildStreakCard(context, s),
                        SizedBox(height: Responsive.gapMd(context)),
                        _buildWeeklySummaryCard(context, s),
                        SizedBox(height: Responsive.gapMd(context)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: Responsive.gapSm(context)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: Responsive.gapXs(context)),
            child: Text(
              'Senin Özetin',
              style: TextStyle(
                fontSize: Responsive.fontSizeTitle(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
          ),
        ),
        _buildPeriodDropdown(),
      ],
    );
  }

  Widget _buildPeriodDropdown() {
    const Map<_Period, String> labels = {
      _Period.daily: 'Günlük',
      _Period.weekly: 'Haftalık',
      _Period.monthly: 'Aylık',
    };
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(ctx)),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(Responsive.cardRadius(ctx)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: Responsive.gapSm(ctx)),
                      Text(
                        'Periyot seç',
                        style: TextStyle(
                          fontSize: Responsive.fontSizeBody(ctx),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: Responsive.gapXs(ctx)),
                      ..._Period.values.map(
                        (p) => ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            labels[p]!,
                            style: TextStyle(fontSize: Responsive.fontSizeBody(ctx)),
                          ),
                          selected: _period == p,
                          onTap: () {
                            Navigator.pop(ctx);
                            _reload(period: p);
                          },
                        ),
                      ),
                      SizedBox(height: Responsive.gapSm(ctx)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.gapMd(context),
          vertical: Responsive.gapSm(context) * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          border: Border.all(color: const Color(0xFFD1BEEB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labels[_period]!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A148C),
                fontSize: Responsive.fontSizeBodySmall(context),
              ),
            ),
            SizedBox(width: Responsive.gapXs(context)),
            Icon(Icons.keyboard_arrow_down,
                size: Responsive.iconSizeSmall(context), color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  // ── Bar Chart ────────────────────────────────────────────────────

  Widget _buildBarChartCard(BuildContext context, StatsSnapshot s) {
    const double barAreaHeight = 160;
    const double maxBarHeight = 130;
    final isDaily = s.period == StatsPeriod.daily;
    final isWeekly = s.period == StatsPeriod.weekly;
    final isMonthly = s.period == StatsPeriod.monthly;
    final labels = s.seriesLabels;
    final minutes = s.seriesMinutes;
    final heights = s.seriesHeights;
    final highlightIndex = s.highlightIndex;
    final barWidth = isDaily ? 28.0 : (isWeekly ? 36.0 : 32.0);
    final labelWidth = isDaily ? 28.0 : (isWeekly ? 72.0 : 40.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: barAreaHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(labels.length, (i) {
                final isHighlight = i == highlightIndex;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isHighlight)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _formatMinutes(minutes[i]),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      width: barWidth,
                      height: maxBarHeight * heights[i],
                      decoration: BoxDecoration(
                        color: isHighlight
                            ? const Color(0xFF7A3EC8)
                            : const Color(0xFFD7C4EA),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(labels.length, (i) {
              return SizedBox(
                width: labelWidth,
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMonthly ? 10 : (isWeekly ? 11 : 12),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Haftalık Hedef ───────────────────────────────────────────────

  Widget _buildWeeklyGoalCard(BuildContext context, StatsSnapshot s) {
    final progress = s.weeklyGoalMinutes <= 0
        ? 0.0
        : (s.currentWeeklyMinutes / s.weeklyGoalMinutes).clamp(0.0, 1.0);
    final hoursStr = _formatMinutes(s.currentWeeklyMinutes);
    final goalStr = _formatMinutes(s.weeklyGoalMinutes);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.cardPadding(context)),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bu hafta',
                style: TextStyle(
                  fontSize: Responsive.fontSizeBodySmall(context),
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$hoursStr / $goalStr',
                style: TextStyle(
                  fontSize: Responsive.fontSizeBodySmall(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.gapSm(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(Responsive.cardRadius(context) * 0.5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFD1BEEB).withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7A3EC8)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Seviye ───────────────────────────────────────────────────────

  Widget _buildLevelProgressCard(BuildContext context, StatsSnapshot s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.cardPadding(context)),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seviye',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${s.level} → ${s.nextLevel}',
                style: TextStyle(
                  fontSize: Responsive.fontSizeBody(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: s.levelProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFFD1BEEB).withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7A3EC8)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(s.levelProgress * 100).toInt()}% ${s.nextLevel} seviyesine',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ── Öğrenme Süresi Kartı ─────────────────────────────────────────

  Widget _buildLearningTimeCard(BuildContext context, StatsSnapshot s) {
    final timeStr = _formatMinutes(s.currentWeeklyMinutes);
    final periodLabel = switch (_period) {
      _Period.daily => 'Günlük öğrenme',
      _Period.weekly => 'Haftalık öğrenme',
      _Period.monthly => 'Aylık öğrenme',
    };
    return GestureDetector(
      onTap: () => _showLearningTimeDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9C6ADE), Color(0xFF7A3EC8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A3EC8).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                color: Colors.white.withValues(alpha: 0.9), size: 28),
            const SizedBox(height: 10),
            Text(
              periodLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              timeStr,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Yetenek Seviyeleri Kartı ─────────────────────────────────────

  Widget _buildSkillMasterCard(BuildContext context, StatsSnapshot s) {
    return GestureDetector(
      onTap: () => _showSkillMasterDetail(context, skills: s.skills),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF5B8DEE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B8DEE).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.rocket_launch_outlined,
                color: Colors.white.withValues(alpha: 0.95), size: 28),
            const SizedBox(height: 12),
            Text(
              'Yetenek Seviyeleri',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...s.skills.entries.map((e) {
              final short = switch (e.key) {
                'Vocabulary' => 'Voca',
                'Listening' => 'Listen',
                'Speaking' => 'Speak',
                _ => 'Write',
              };
              final pct = (e.value * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        short,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e.value,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Seri ─────────────────────────────────────────────────────────

  Widget _buildStreakCard(BuildContext context, StatsSnapshot s) {
    return GestureDetector(
      onTap: () => _showStreakDetail(context, streakDays: s.streakDays),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: _cardDeco(),
        child: Row(
          children: [
            Icon(Icons.local_fire_department,
                color: s.streakDays > 0 ? Colors.amber.shade700 : Colors.grey,
                size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktif Serin',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.streakDays == 0
                        ? 'Bugün çalışmaya başla!'
                        : '${s.streakDays} günlük seri!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 28),
          ],
        ),
      ),
    );
  }

  // ── Haftalık Özet (Aktivite Bazlı) ───────────────────────────────

  Widget _buildWeeklySummaryCard(BuildContext context, StatsSnapshot s) {
    final breakdown = s.activityBreakdown;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 22, color: Colors.grey.shade700),
              const SizedBox(width: 10),
              Text(
                'Haftalık özet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            s.currentWeeklyMinutes == 0
                ? 'Bu hafta henüz çalışma kaydedilmedi.'
                : 'Bu hafta toplam ${_formatMinutes(s.currentWeeklyMinutes)} çalıştın.',
            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade700),
          ),
          if (breakdown.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...breakdown.entries.map((e) {
              final (label, icon, color) = _activityMeta(e.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      _formatMinutes(e.value),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A148C),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ── Detail Sheets ────────────────────────────────────────────────

  void _showStreakDetail(BuildContext context, {required int streakDays}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.7,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<List<bool>>(
            future: StatsStore.getDailyStudyLast30(),
            builder: (ctx, snap) {
              final days = snap.data ?? List<bool>.filled(30, false);
              final now = DateTime.now();
              return ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_fire_department,
                          color: streakDays > 0
                              ? Colors.amber.shade700
                              : Colors.grey,
                          size: 36),
                      const SizedBox(width: 8),
                      const Text(
                        'Son 30 gün',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    streakDays == 0
                        ? 'Bugün ilk günün olsun!'
                        : '$streakDays gündür öğreniyorsun! 🔥',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),
                  // 30 günlük takvim — 5 satır × 6 sütun
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(30, (i) {
                      final active = days[i];
                      final date = now.subtract(Duration(days: 29 - i));
                      return Tooltip(
                        message:
                            '${date.day}/${date.month}: ${active ? "çalışıldı" : "çalışılmadı"}',
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF7A3EC8).withValues(alpha: 0.15)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: active
                                  ? const Color(0xFF7A3EC8)
                                  : Colors.grey.shade300,
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: active
                                    ? const Color(0xFF7A3EC8)
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLearningTimeDetail(BuildContext context) {
    const dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FutureBuilder<List<int>>(
          // Bu haftanın (Pzt–Paz) dakikaları
          future: StatsStore.getDailyMinutesThisWeek(),
          builder: (ctx, snap) {
            final dailyMinutes = snap.data ?? List<int>.filled(7, 0);
            final total = dailyMinutes.fold<int>(0, (a, b) => a + b);
            final maxMins =
                dailyMinutes.reduce((a, b) => a > b ? a : b).clamp(1, 99999);
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Haftalık öğrenme süresi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${_formatMinutes(total)} toplam',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ...List.generate(7, (i) {
                    final m = dailyMinutes[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(dayLabels[i],
                                style:
                                    TextStyle(color: Colors.grey.shade700)),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: m / maxMins,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF7A3EC8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 48,
                            child: Text(
                              _formatMinutes(m),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSkillMasterDetail(
      BuildContext context, {required Map<String, double> skills}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yetenek Grafiği',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
              ),
            ),
            const SizedBox(height: 24),
            ...skills.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A148C),
                            ),
                          ),
                          Text(
                            '${(e.value * 100).toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: e.value,
                          minHeight: 12,
                          backgroundColor:
                              const Color(0xFFD1BEEB).withValues(alpha: 0.4),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF5B8DEE)),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  BoxDecoration _cardDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static (String label, IconData icon, Color color) _activityMeta(
      LearningActivity a) {
    return switch (a) {
      LearningActivity.vocabulary => ('Kelime', Icons.translate, Colors.purple),
      LearningActivity.listening =>
        ('Dinleme', Icons.headphones, Colors.blue),
      LearningActivity.speaking => ('Konuşma', Icons.mic, Colors.orange),
      LearningActivity.writing => ('Yazma', Icons.edit, Colors.green),
      LearningActivity.quiz => ('Quiz', Icons.quiz, Colors.teal),
      LearningActivity.flashcards =>
        ('Kartlar', Icons.style, Colors.deepOrange),
    };
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return '0 dk';
    if (minutes < 60) return '$minutes dk';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h sa';
    return '${h}sa ${m}dk';
  }
}
