import 'package:flutter/material.dart';
import 'badges_page.dart';

enum _Period { daily, weekly, monthly }

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  _Period _period = _Period.weekly;

  // Günlük: son 7 gün
  static const List<String> _days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  static const List<double> _dailyHeights = [0.4, 0.5, 0.35, 0.6, 1.0, 0.45, 0.55];
  // Haftalık: son 4 hafta
  static const List<String> _weekLabels = ['1. Hafta', '2. Hafta', '3. Hafta', 'Bu Hafta'];
  static const List<double> _weekHeights = [0.5, 0.8, 0.6, 1.0];
  // Aylık: son 6 ay
  static const List<String> _monthLabels = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Bu Ay'];
  static const List<double> _monthHeights = [0.5, 0.7, 0.6, 0.9, 0.8, 1.0];
  static const int _highlightIndexDaily = 6;
  static const int _highlightIndexWeekly = 3;
  static const int _highlightIndexMonthly = 5;

  // Mock data
  static const double _weeklyGoalHours = 5.0;
  static const double _currentWeeklyHours = 3.75;
  static const String _level = 'A2';
  static const String _nextLevel = 'B1';
  static const double _levelProgress = 0.6;
  static const int _streakDays = 10;
  static const Map<String, double> _skills = {
    'Vocabulary': 0.8,
    'Listening': 0.65,
    'Speaking': 0.5,
    'Writing': 0.45,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildBarChartCard(context),
              const SizedBox(height: 20),
              _buildWeeklyGoalCard(),
              const SizedBox(height: 16),
              _buildLevelProgressCard(),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildLearningTimeCard(context)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSkillMasterCard(context)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildStreakCard(context),
              const SizedBox(height: 16),
              _buildWeeklySummaryCard(),
              const SizedBox(height: 20),
              _buildBadgesSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const SizedBox(width: 12),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Senin Özetin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
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
          builder: (ctx) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Periyot seç',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._Period.values.map((p) => ListTile(
                    title: Text(labels[p]!),
                    selected: _period == p,
                    onTap: () {
                      setState(() => _period = p);
                      Navigator.pop(ctx);
                    },
                  )),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD1BEEB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labels[_period]!,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A148C)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoalCard() {
    final progress = (_currentWeeklyHours / _weeklyGoalHours).clamp(0.0, 1.0);
    final hoursStr = '${_currentWeeklyHours.toStringAsFixed(1)} saat';
    final goalStr = '$_weeklyGoalHours saat';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bu hafta',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$hoursStr / $goalStr',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFD1BEEB).withOpacity(0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7A3EC8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                '$_level → $_nextLevel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _levelProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFFD1BEEB).withOpacity(0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7A3EC8)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(_levelProgress * 100).toInt()}% $_nextLevel seviyesine',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(BuildContext context) {
    const double barAreaHeight = 160;
    const double maxBarHeight = 130;
    final isDaily = _period == _Period.daily;
    final isWeekly = _period == _Period.weekly;
    final isMonthly = _period == _Period.monthly;
    final labels = isDaily ? _days : (isWeekly ? _weekLabels : _monthLabels);
    final heights = isDaily ? _dailyHeights : (isWeekly ? _weekHeights : _monthHeights);
    final highlightIndex = isDaily ? _highlightIndexDaily : (isWeekly ? _highlightIndexWeekly : _highlightIndexMonthly);
    final showHighlight = true;
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
            color: Colors.black.withOpacity(0.06),
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
                    if (showHighlight && isHighlight)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          isMonthly ? '8 sa' : (isWeekly ? '5 sa' : '4 sa'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    Container(
                      width: barWidth,
                      height: maxBarHeight * heights[i],
                      decoration: BoxDecoration(
                        color: isHighlight
                            ? const Color(0xFF7A3EC8)
                            : const Color(0xFFD7C4EA),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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

  Widget _buildLearningTimeCard(BuildContext context) {
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
              color: const Color(0xFF7A3EC8).withOpacity(0.3),
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
            Icon(Icons.assignment_outlined, color: Colors.white.withOpacity(0.9), size: 28),
            const SizedBox(height: 10),
            Text(
              'Haftalık öğrenme süresi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '52 dk',
              style: TextStyle(
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

  Widget _buildSkillMasterCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSkillMasterDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF5B8DEE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B8DEE).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.rocket_launch_outlined, color: Colors.white.withOpacity(0.95), size: 28),
            const SizedBox(height: 12),
            Text(
              'Yetenek Seviyeleri',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ..._skills.entries.map((e) {
              final short = e.key == 'Vocabulary' ? 'Voca' : e.key == 'Listening' ? 'Listen' : e.key == 'Speaking' ? 'Speak' : 'Write';
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
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
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

  Widget _buildStreakCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStreakDetail(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.amber.shade700, size: 36),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktif Serin',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '10 günlük seri!',
                    style: TextStyle(
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

  Widget _buildWeeklySummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
            'Bu hafta 5 gün çalıştın, toplam 3s 45dk. Geçen haftaya göre +2 saat.',
            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    final badges = [
      (Icons.local_fire_department, '7 gün', Colors.orange),
      (Icons.library_books, 'İlk 50', Colors.green),
      (Icons.headphones, 'Dinleyici', Colors.blue),
      (Icons.mic, '"Hello.."', Colors.purple),
    ];
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesPage())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rozetler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: badges.asMap().entries.map((e) {
              final (icon, label, color) = e.value;
              return Container(
                width: 90,
                margin: EdgeInsets.only(right: e.key < badges.length - 1 ? 12 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        ],
      ),
    );
  }

  void _showStreakDetail(BuildContext context) {
    const int totalDays = 14;
    final inactiveCount = totalDays - _streakDays;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.42,
        minChildSize: 0.35,
        maxChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
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
                  Icon(Icons.local_fire_department, color: Colors.amber.shade700, size: 36),
                  const SizedBox(width: 8),
                  const Text(
                    'Streak geçmişi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_streakDays gündür öğreniyorsun!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(totalDays, (i) {
                  final dayActive = i >= inactiveCount;
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: dayActive
                          ? const Color(0xFF7A3EC8).withOpacity(0.2)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dayActive ? const Color(0xFF7A3EC8) : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      dayActive ? Icons.check : Icons.close,
                      size: 20,
                      color: dayActive ? const Color(0xFF7A3EC8) : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLearningTimeDetail(BuildContext context) {
    final dailyMinutes = [45, 30, 0, 60, 90, 20, 40];
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
              'Haftalık öğrenme süresi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
              ),
            ),
            const SizedBox(height: 8),
            const Text('3 sa 45 dak toplam', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ...List.generate(7, (i) {
              final m = dailyMinutes[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(_days[i], style: TextStyle(color: Colors.grey.shade700)),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: m / 120,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7A3EC8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('$m dk', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSkillMasterDetail(BuildContext context) {
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
            ..._skills.entries.map((e) => Padding(
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
                      backgroundColor: const Color(0xFFD1BEEB).withOpacity(0.4),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B8DEE)),
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
}
