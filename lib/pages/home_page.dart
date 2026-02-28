import 'package:flutter/material.dart';
import 'practice_room_page.dart';
import 'listening_exercise_page.dart';
import 'lesson_page.dart';
import 'quiz_page.dart';
import 'level_roadmap_page.dart';
import 'daily_goal_page.dart';
import 'badges_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  height: 250,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBE3F8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 140),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: const Color(0xFFD1BEEB)),
                        ),
                        child: const Text(
                          "Nihan Karaca - A2",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Profil Avatar
                Positioned(
                  top: 40,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1BEEB),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage:
                      AssetImage("assets/images/panda_avatar.png"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// İstatistikler
            Padding( padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30), child: IntrinsicHeight( child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ _buildStatItem(Icons.workspace_premium_outlined, "13", Colors.teal), const VerticalDivider(thickness: 1, color: Colors.grey), _buildStatItem(Icons.trending_up, "22 / 250", Colors.redAccent), const VerticalDivider(thickness: 1, color: Colors.grey), _buildStatItem(Icons.collections_bookmark_outlined, "2 / 5", Colors.pinkAccent), ], ), ), ),

            const Divider(indent: 30, endIndent: 30),

            /// Kategoriler
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
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

  /// İstatistik Widget
  Widget _buildStatItem(
      IconData icon, String value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A148C),
          ),
        ),
      ],
    );
  }

  /// Kategori Kartı
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
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
