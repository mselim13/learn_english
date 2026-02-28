import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LevelRoadmapPage extends StatelessWidget {
  const LevelRoadmapPage({super.key});

  static const List<Map<String, dynamic>> _levels = [
    {'name': 'A1', 'desc': 'Başlangıç', 'done': true, 'progress': 100},
    {'name': 'A2', 'desc': 'Temel', 'done': true, 'current': true, 'progress': 60},
    {'name': 'B1', 'desc': 'Orta alt', 'done': false, 'progress': 0},
    {'name': 'B2', 'desc': 'Orta üst', 'done': false, 'progress': 0},
    {'name': 'C1', 'desc': 'İleri', 'done': false, 'progress': 0},
    {'name': 'C2', 'desc': 'Üst', 'done': false, 'progress': 0},
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
              AppTheme.buildAppBar(context, 'Seviye yol haritası'),
              const SizedBox(height: 24),
              ...List.generate(_levels.length, (i) {
                final l = _levels[i];
                final done = l['done'] as bool;
                final current = l['current'] as bool? ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration.copyWith(
                      color: current ? AppTheme.primaryLight.withOpacity(0.2) : Colors.white,
                      border: current ? Border.all(color: AppTheme.primary, width: 2) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: done ? AppTheme.primary : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: done
                              ? const Icon(Icons.check, color: Colors.white, size: 32)
                              : Center(
                                  child: Text(
                                    l['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seviye ${l['name']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: current ? AppTheme.primary : Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                l['desc'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (current && l['progress'] != null) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (l['progress'] as int) / 100,
                                    minHeight: 6,
                                    backgroundColor: AppTheme.primaryLight.withOpacity(0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '%${l['progress']} tamamlandı',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (current)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Şu an',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Seviye ilerlemesi tamamlanan üniteleri geçerek artar.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
