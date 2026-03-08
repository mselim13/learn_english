import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

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
    final pad = Responsive.horizontalPadding(context);
    final spacing = Responsive.spacing(context);
    final topics = isSpeaking
        ? ['Kendini tanıt', 'Gününü anlat', 'En sevdiğin yemek', 'Tatil planları', 'Hobilerin']
        : ['Kendini tanıt', 'Bir anını yaz', 'Hayalindeki iş', 'Sevdiğin bir yer', 'Öneri mektubu'];
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildAppBar(context, isSpeaking ? 'Konuşma pratiği' : 'Yazma pratiği'),
              SizedBox(height: spacing),
              Text(
                'Konu seç',
                style: TextStyle(
                  fontSize: Responsive.fontSizeBodySmall(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: spacing * 0.5),
              SizedBox(
                height: Responsive.minTouchTarget(context) + 8,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: topics.length,
                  separatorBuilder: (_, __) => SizedBox(width: spacing),
                  itemBuilder: (context, i) {
                    return ActionChip(
                      label: Text(
                        topics[i],
                        style: TextStyle(fontSize: Responsive.fontSizeBodySmall(context)),
                      ),
                      onPressed: () {},
                      backgroundColor: i == 0 ? AppTheme.primaryLight.withOpacity(0.5) : Colors.white,
                    );
                  },
                ),
              ),
              SizedBox(height: spacing * 2),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konu',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeCaption(context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: spacing * 0.5),
                    Text(
                      'Kendini kısa bir cümleyle tanıt.',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeTitleSmall(context),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 2),
              if (isSpeaking) ...[
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _recording = !_recording),
                    child: Container(
                      width: Responsive.iconSizeLarge(context) * 1.4,
                      height: Responsive.iconSizeLarge(context) * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _recording ? Colors.red.shade100 : AppTheme.primaryLight.withOpacity(0.5),
                      ),
                      child: Icon(
                        _recording ? Icons.stop : Icons.mic,
                        size: Responsive.iconSizeLarge(context),
                        color: _recording ? Colors.red : AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Center(
                  child: Text(
                    _recording ? 'Kaydediliyor...' : 'Mikrofona dokun',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBody(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Cevabını yaz:',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBody(context),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(height: spacing),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Örn: My name is Nihan. I am learning English.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
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
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.buttonPaddingVertical(context),
                    ),
                    minimumSize: Size(0, Responsive.minTouchTarget(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                    ),
                  ),
                  child: const Text('Gönder'),
                ),
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
