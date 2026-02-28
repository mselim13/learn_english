import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PracticeRoomPage extends StatefulWidget {
  const PracticeRoomPage({super.key, this.mode = 'speaking'});
  final String mode; // 'speaking' | 'writing'

  @override
  State<PracticeRoomPage> createState() => _PracticeRoomPageState();
}

class _PracticeRoomPageState extends State<PracticeRoomPage> {
  final _controller = TextEditingController();
  bool _recording = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = widget.mode == 'speaking';
    final topics = isSpeaking
        ? ['Kendini tanıt', 'Gününü anlat', 'En sevdiğin yemek', 'Tatil planları', 'Hobilerin']
        : ['Kendini tanıt', 'Bir anını yaz', 'Hayalindeki iş', 'Sevdiğin bir yer', 'Öneri mektubu'];
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildAppBar(context, isSpeaking ? 'Konuşma pratiği' : 'Yazma pratiği'),
              const SizedBox(height: 16),
              Text(
                'Konu seç',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: topics.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    return ActionChip(
                      label: Text(topics[i]),
                      onPressed: () {},
                      backgroundColor: i == 0 ? AppTheme.primaryLight.withOpacity(0.5) : Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kendini kısa bir cümleyle tanıt.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (isSpeaking) ...[
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _recording = !_recording),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _recording ? Colors.red.shade100 : AppTheme.primaryLight.withOpacity(0.5),
                      ),
                      child: Icon(
                        _recording ? Icons.stop : Icons.mic,
                        size: 56,
                        color: _recording ? Colors.red : AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _recording ? 'Kaydediliyor...' : 'Mikrofona dokun',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ] else ...[
                const Text(
                  'Cevabını yaz:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Örn: My name is Nihan. I am learning English.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Gönder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
