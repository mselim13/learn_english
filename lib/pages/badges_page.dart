import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  static final List<Map<String, dynamic>> _badges = [
    {'icon': Icons.local_fire_department, 'title': '7 gün', 'desc': '7 gün üst üste öğren', 'unlocked': true, 'color': Colors.orange},
    {'icon': Icons.library_books, 'title': '50 kelime', 'desc': '50 kelime öğren', 'unlocked': true, 'color': Colors.green},
    {'icon': Icons.headphones, 'title': '1 saat dinleme', 'desc': '1 saat dinleme tamamla', 'unlocked': true, 'color': Colors.blue},
    {'icon': Icons.mic, 'title': 'İlk konuşma', 'desc': 'İlk konuşma pratiğini yap', 'unlocked': true, 'color': Colors.purple},
    {'icon': Icons.emoji_events, 'title': 'Seviye atla', 'desc': 'Bir seviye tamamla', 'unlocked': false, 'color': Colors.amber},
    {'icon': Icons.nightlight_round, 'title': 'Gece kuşu', 'desc': 'Gece 22:00 sonrası 7 ders', 'unlocked': false, 'color': Colors.indigo},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildAppBar(context, 'Rozetler'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: AppTheme.cardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kazanılan',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    Text(
                      '4 / 6 rozet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: _badges.map((b) {
                  final unlocked = b['unlocked'] as bool;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.cardDecoration.copyWith(
                      color: unlocked ? Colors.white : Colors.grey.shade100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          b['icon'] as IconData,
                          size: 48,
                          color: unlocked ? (b['color'] as Color) : Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          b['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? AppTheme.primary : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b['desc'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
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
        ),
      ),
    );
  }
}
