import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';
import '../services/app_prefs.dart';
import '../services/stats_store.dart';

class LevelRoadmapPage extends StatelessWidget {
  const LevelRoadmapPage({super.key});

  static const List<Map<String, dynamic>> _levels = [
    {'name': 'A1', 'desc': 'Başlangıç'},
    {'name': 'A2', 'desc': 'Temel'},
    {'name': 'B1', 'desc': 'Orta alt'},
    {'name': 'B2', 'desc': 'Orta üst'},
    {'name': 'C1', 'desc': 'İleri'},
    {'name': 'C2', 'desc': 'Üst'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: FutureBuilder<String>(
        future: AppPrefs.getUserLevel(),
        builder: (context, snap) {
          final currentLevel = snap.data ?? 'A2';
          const order = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
          final currentIdx = order.indexOf(currentLevel);

          return FutureBuilder<double>(
            future: StatsStore.getLevelProgress(currentLevel),
            builder: (context, pSnap) {
              final progress = (pSnap.data ?? 0.0).clamp(0.0, 1.0);
              final progressPct = (progress * 100).round().clamp(0, 100);

              return ResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTheme.buildAppBar(context, 'Seviye yol haritası'),
                    SizedBox(height: Responsive.gapLg(context)),
                    ...List.generate(_levels.length, (i) {
                      final l = _levels[i];
                      final name = l['name'] as String;
                      final done = currentIdx >= 0 && i < currentIdx;
                      final current = currentIdx >= 0 && i == currentIdx;
                      final showProgress = current;

                      return Padding(
                        padding: EdgeInsets.only(bottom: Responsive.gapSm(context)),
                        child: Container(
                          padding: EdgeInsets.all(Responsive.cardPadding(context)),
                          decoration: AppTheme.cardDecorationFor(context).copyWith(
                            color: current ? AppTheme.primaryLight.withOpacity(0.2) : Colors.white,
                            border: current ? Border.all(color: AppTheme.primary, width: 2) : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: Responsive.scaled(context, min: 44, max: 64),
                                height: Responsive.scaled(context, min: 44, max: 64),
                                decoration: BoxDecoration(
                                  color: done || current ? AppTheme.primary : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: done
                                    ? Icon(Icons.check, color: Colors.white, size: Responsive.iconSizeMedium(context))
                                    : Center(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: Responsive.fontSizeBody(context),
                                          ),
                                        ),
                                      ),
                              ),
                              SizedBox(width: Responsive.gapMd(context)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seviye $name',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSizeBody(context),
                                        fontWeight: FontWeight.bold,
                                        color: current ? AppTheme.primary : Colors.grey.shade800,
                                      ),
                                    ),
                                    Text(
                                      l['desc'] as String,
                                      style: TextStyle(
                                        fontSize: Responsive.fontSizeBodySmall(context),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (showProgress) ...[
                                      SizedBox(height: Responsive.gapSm(context)),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6,
                                          backgroundColor: AppTheme.primaryLight.withOpacity(0.3),
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                        ),
                                      ),
                                      SizedBox(height: Responsive.gapXs(context)),
                                      Text(
                                        '%$progressPct tamamlandı',
                                        style: TextStyle(
                                          fontSize: Responsive.fontSizeCaption(context),
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (current)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.gapMd(context),
                                    vertical: Responsive.gapXs(context),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Şu an',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: Responsive.fontSizeCaption(context),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: Responsive.gapSm(context)),
                    Text(
                      'Seviye ilerlemesi tamamlanan üniteleri geçerek artar.',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeCaption(context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
