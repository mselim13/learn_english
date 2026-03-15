import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../services/profile_notifier.dart';
import 'practice_room_page.dart';
import 'listening_exercise_page.dart';
import 'quiz_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            /// Üst Profil Alanı
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
                                  'Kullanıcı - A2',
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
                        final ImageProvider image = hasAvatar
                            ? FileImage(File(data!.avatarPath!))
                            : const AssetImage("assets/images/panda_avatar.png");
                        return CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.white,
                          backgroundImage: image,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.spacing(context, multiplier: 2)),

            /// İstatistikler
            Padding(
              padding: EdgeInsets.symmetric(vertical: gapMd, horizontal: horizontalPad),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(context, Icons.workspace_premium_outlined, "13", Colors.teal),
                    const VerticalDivider(thickness: 1, color: Colors.grey),
                    _buildStatItem(context, Icons.trending_up, "22 / 250", Colors.redAccent),
                    const VerticalDivider(thickness: 1, color: Colors.grey),
                    _buildStatItem(context, Icons.collections_bookmark_outlined, "2 / 5", Colors.pinkAccent),
                  ],
                ),
              ),
            ),

            Divider(indent: horizontalPad, endIndent: horizontalPad),

            /// Kategoriler
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
                    _buildCategoryCard(context, "Words", const Color(0xFFAEF4D1)),
                    _buildCategoryCard(context, "Writing", const Color(0xFFC76D6D)),
                    _buildCategoryCard(context, "Speaking", const Color(0xFF91E1E6)),
                    _buildCategoryCard(context, "Listening", const Color(0xFFF1C1C1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, Color iconColor) {
    final iconSize = Responsive.iconSizeMedium(context);
    final fontSize = Responsive.fontSizeTitleSmall(context);
    return Column(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        SizedBox(height: Responsive.gapXs(context)),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A148C),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == 'Words') {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const QuizPage(),
          ));
        } else if (title == 'Listening') {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const ListeningExercisePage(),
          ));
        } else if (title == 'Speaking') {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const PracticeRoomPage(mode: 'speaking'),
          ));
        } else if (title == 'Writing') {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const PracticeRoomPage(mode: 'writing'),
          ));
        }
      },
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
    );
  }

}
