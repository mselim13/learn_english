import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';
import '../services/stats_store.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  static final List<Map<String, dynamic>> _badgeDefs = [
    {
      'id': '7_day_streak',
      'icon': Icons.local_fire_department,
      'title': '7 gün',
      'desc': '7 gün üst üste öğren',
      'color': Colors.orange,
    },
    {
      'id': '50_vocab',
      'icon': Icons.library_books,
      'title': '50 kelime',
      'desc': 'Kelime defterinde 50 kelime',
      'color': Colors.green,
    },
    {
      'id': '1h_listening',
      'icon': Icons.headphones,
      'title': '1 saat dinleme',
      'desc': 'Toplam 1 saat dinleme tamamla',
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.gridColumns(context).clamp(2, 4);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: FutureBuilder<void>(
        future: StatsStore.recomputeBadges(),
        builder: (context, _) {
          return FutureBuilder<Map<String, bool>>(
            future: StatsStore.getBadges(),
            builder: (context, snap) {
              final unlockedById = snap.data ?? const <String, bool>{};
              final unlockedCount = _badgeDefs
                  .where((b) => unlockedById[b['id'] as String] == true)
                  .length;
              final totalCount = _badgeDefs.length;

              return ResponsivePage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTheme.buildAppBar(context, 'Rozetler'),
                    SizedBox(height: Responsive.gapMd(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.cardPadding(context),
                        vertical: Responsive.gapSm(context),
                      ),
                      decoration: AppTheme.cardDecorationFor(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kazanılan',
                            style: TextStyle(
                              fontSize: Responsive.fontSizeBodySmall(context),
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '$unlockedCount / $totalCount rozet',
                            style: TextStyle(
                              fontSize: Responsive.fontSizeBody(context),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.gapLg(context)),
                    if (snap.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cols,
                        mainAxisSpacing: Responsive.gapMd(context),
                        crossAxisSpacing: Responsive.gapMd(context),
                        childAspectRatio: 0.9,
                        children: _badgeDefs.map((b) {
                          final id = b['id'] as String;
                          final unlocked = unlockedById[id] == true;
                          return Container(
                            padding: EdgeInsets.all(Responsive.cardPadding(context) * 0.75),
                            decoration: AppTheme.cardDecorationFor(context).copyWith(
                              color: unlocked ? Colors.white : Colors.grey.shade100,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  b['icon'] as IconData,
                                  size: Responsive.iconSizeLarge(context) * 0.7,
                                  color: unlocked ? (b['color'] as Color) : Colors.grey,
                                ),
                                SizedBox(height: Responsive.gapSm(context)),
                                Text(
                                  b['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Responsive.fontSizeBody(context),
                                    fontWeight: FontWeight.bold,
                                    color: unlocked ? AppTheme.primary : Colors.grey,
                                  ),
                                ),
                                SizedBox(height: Responsive.gapXs(context)),
                                Text(
                                  b['desc'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Responsive.fontSizeCaption(context),
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
