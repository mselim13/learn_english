import 'package:flutter/material.dart';
import '../services/app_prefs.dart';
import '../services/stats_store.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class DailyGoalPage extends StatefulWidget {
  const DailyGoalPage({super.key});

  @override
  State<DailyGoalPage> createState() => _DailyGoalPageState();
}

class _DailyGoalPageState extends State<DailyGoalPage> {
  int _goalMinutes = 20;
  int _todayMinutes = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goal = await AppPrefs.getDailyGoalMinutes();
    final today = await StatsStore.getStudyMinutesForDay(DateTime.now());
    if (!mounted) return;
    setState(() {
      _goalMinutes = goal;
      _todayMinutes = today;
      _loading = false;
    });
  }

  Future<void> _setGoal(int minutes) async {
    final v = minutes.clamp(5, 240);
    setState(() => _goalMinutes = v);
    await AppPrefs.setDailyGoalMinutes(v);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    final progress = (_todayMinutes / _goalMinutes).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Günlük hedef'),
            SizedBox(height: Responsive.gapLg(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.cardPadding(context)),
              decoration: AppTheme.cardDecorationFor(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bugünkü ilerleme',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBody(context),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: Responsive.gapMd(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_todayMinutes dk',
                        style: TextStyle(
                          fontSize: Responsive.fontSizeDisplay(context),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        '$_goalMinutes dk hedef',
                        style: TextStyle(
                          fontSize: Responsive.fontSizeBodySmall(context),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.gapMd(context)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Responsive.cardRadius(context) * 0.5),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: Responsive.scaled(context, min: 10, max: 14),
                      backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                  SizedBox(height: Responsive.gapSm(context)),
                  Text(
                    'Hedefe ${(_goalMinutes - _todayMinutes).clamp(0, _goalMinutes)} dk kaldı',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeCaption(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.cardPadding(context) * 0.85),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                border: Border.all(color: AppTheme.primaryLight),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.primary, size: Responsive.iconSizeMedium(context)),
                  SizedBox(width: Responsive.gapSm(context)),
                  Expanded(
                    child: Text(
                      'Her gün kısa süre bile olsa çalışmak, uzun aralıklı uzun oturumlardan daha etkilidir.',
                      style: TextStyle(fontSize: Responsive.fontSizeBodySmall(context), color: Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),
            Text(
              'Hedef süre (dakika)',
              style: TextStyle(
                fontSize: Responsive.fontSizeBody(context),
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: Responsive.gapSm(context)),
            Row(
              children: [
                IconButton(
                  onPressed: () => _setGoal(_goalMinutes - 5),
                  icon: Icon(Icons.remove_circle_outline, color: AppTheme.primary, size: Responsive.iconSizeLarge(context) * 0.55),
                ),
                SizedBox(width: Responsive.gapMd(context)),
                Text(
                  '$_goalMinutes dk',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeTitleSmall(context),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: Responsive.gapMd(context)),
                IconButton(
                  onPressed: () => _setGoal(_goalMinutes + 5),
                  icon: Icon(Icons.add_circle_outline, color: AppTheme.primary, size: Responsive.iconSizeLarge(context) * 0.55),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
