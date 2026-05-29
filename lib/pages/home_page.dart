import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../services/profile_notifier.dart';
import '../services/stats_store.dart';
import 'practice_room_page.dart';
import 'listening_exercise_page.dart';
import 'quiz_page.dart';

class _HomeStats {
  const _HomeStats({
    required this.streakDays,
    required this.weeklyMinutes,
    required this.weeklyGoalMinutes,
    required this.badgesUnlocked,
    required this.badgeTotal,
  });

  final int streakDays;
  final int weeklyMinutes;
  final int weeklyGoalMinutes;
  final int badgesUnlocked;
  final int badgeTotal;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<_HomeStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadHomeStats();
  }

  static Future<_HomeStats> _loadHomeStats() async {
    final streak = await StatsStore.getStreakDays();
    final weeklyCur = await StatsStore.getCurrentWeeklyMinutes();
    final weeklyGoal = await StatsStore.getWeeklyGoalMinutes();
    final badges = await StatsStore.getBadges();
    final unlocked = badges.values.where((v) => v).length;
    return _HomeStats(
      streakDays: streak,
      weeklyMinutes: weeklyCur,
      weeklyGoalMinutes: weeklyGoal,
      badgesUnlocked: unlocked,
      badgeTotal: badges.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.width(context);
    final horizontalPad = Responsive.horizontalPadding(context);
    final profileHeight = Responsive.scaled(context, min: 200.0, max: 300.0);
    final avatarRadius = Responsive.avatarSize(context) / 2;
    final gridCols = Responsive.gridColumns(context);
    final gridSpacing = Responsive.spacing(context, multiplier: 2);
    final gapMd = Responsive.gapMd(context);
    final topMargin = Responsive.gapLg(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: profileHeight,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: topMargin, left: horizontalPad, right: horizontalPad),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBE3F8),
                    borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: avatarRadius * 2 + Responsive.gapLg(context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r * 0.07,
                          vertical: Responsive.buttonPaddingVertical(context),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: horizontalPad),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                          border: Border.all(color: const Color(0xFFD1BEEB)),
                        ),
                        child: ValueListenableBuilder<ProfileData?>(
                          valueListenable: profileNotifier,
                          builder: (context, data, _) {
                            if (data != null) {
                              return Text(
                                data.displayTitle,
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeTitleSmall(context),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4A148C),
                                ),
                              );
                            }
                            return FutureBuilder<ProfileData>(
                              future: loadProfileFromPrefs(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (profileNotifier.value == null) {
                                      profileNotifier.value = snapshot.data;
                                    }
                                  });
                                  return Text(
                                    snapshot.data!.displayTitle,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSizeTitleSmall(context),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4A148C),
                                    ),
                                  );
                                }
                                return Text(
                                  'Kullanıcı — A2',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSizeTitleSmall(context),
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4A148C),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: Responsive.gapLg(context),
                  child: Container(
                    padding: EdgeInsets.all(Responsive.gapXs(context)),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1BEEB),
                      shape: BoxShape.circle,
                    ),
                    child: ValueListenableBuilder<ProfileData?>(
                      valueListenable: profileNotifier,
                      builder: (context, data, _) {
                        final hasAvatar = data?.hasAvatar ?? false;
                        return CircleAvatar(
                          key: ValueKey(data?.avatarPath ?? 'no-avatar'),
                          radius: avatarRadius,
                          backgroundColor: const Color(0xFFD1BEEB),
                          backgroundImage: hasAvatar ? FileImage(File(data!.avatarPath!)) : null,
                          child: hasAvatar
                              ? null
                              : Icon(
                                  Icons.person,
                                  size: avatarRadius * 1.6,
                                  color: Colors.white,
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.spacing(context, multiplier: 2)),

            Padding(
              padding: EdgeInsets.symmetric(vertical: gapMd, horizontal: horizontalPad),
              child: IntrinsicHeight(
                child: FutureBuilder<_HomeStats>(
                  future: _statsFuture,
                  builder: (context, snap) {
                    final s = snap.data;
                    final streakStr = s != null ? '${s.streakDays}' : '…';
                    final weekStr = s != null ? '${s.weeklyMinutes} / ${s.weeklyGoalMinutes} dk' : '…';
                    final badgeStr = s != null ? '${s.badgesUnlocked} / ${s.badgeTotal}' : '…';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          context,
                          Icons.local_fire_department_outlined,
                          streakStr,
                          Colors.deepOrange,
                          'Gün serisi',
                        ),
                        const VerticalDivider(thickness: 1, color: Colors.grey),
                        _buildStatItem(
                          context,
                          Icons.calendar_today_outlined,
                          weekStr,
                          Colors.redAccent,
                          'Haftalık hedef',
                        ),
                        const VerticalDivider(thickness: 1, color: Colors.grey),
                        _buildStatItem(
                          context,
                          Icons.workspace_premium_outlined,
                          badgeStr,
                          Colors.pinkAccent,
                          'Rozet',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            Divider(indent: horizontalPad, endIndent: horizontalPad),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(horizontalPad * 0.9),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: gridCols,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: 1.1,
                  children: [
                    _buildCategoryCard(
                      context,
                      title: 'Kelime',
                      color: const Color(0xFFAEF4D1),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizPage(category: 'Kelime')),
                      ),
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Yazma',
                      color: const Color(0xFFC76D6D),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PracticeRoomPage(mode: 'writing')),
                      ),
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Konuşma',
                      color: const Color(0xFF91E1E6),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PracticeRoomPage(mode: 'speaking')),
                      ),
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Dinleme',
                      color: const Color(0xFFF1C1C1),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ListeningExercisePage()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    Color iconColor,
    String caption,
  ) {
    final iconSize = Responsive.iconSizeMedium(context);
    final fontSize = Responsive.fontSizeTitleSmall(context);
    final capSize = Responsive.fontSizeCaption(context);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          SizedBox(height: Responsive.gapXs(context)),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A148C),
            ),
          ),
          SizedBox(height: Responsive.gapXs(context) * 0.5),
          Text(
            caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: capSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + 2),
            boxShadow: [
              BoxShadow(
                blurRadius: Responsive.gapSm(context) * 1.2,
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, Responsive.gapXs(context)),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: Responsive.fontSizeTitleSmall(context),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
