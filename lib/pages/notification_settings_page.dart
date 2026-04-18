import 'package:flutter/material.dart';
import '../services/app_prefs.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _enabled = true;
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await AppPrefs.getNotificationsEnabled();
    final daily = await AppPrefs.getDailyReminderEnabled();
    final mins = await AppPrefs.getDailyReminderTimeMinutes();
    final t = TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _dailyReminder = daily;
      _reminderTime = t;
      _loading = false;
    });
    await _applyScheduling();
  }

  Future<void> _applyScheduling() async {
    if (!_enabled || !_dailyReminder) {
      await NotificationService.cancelDailyReminder();
      return;
    }
    await NotificationService.requestPermissionIfNeeded();
    await NotificationService.scheduleDailyReminder(
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
    );
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
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Bildirim ayarları'),
            SizedBox(height: Responsive.gapLg(context)),
            _buildSwitchRow(
              context,
              'Bildirimler',
              'Tüm uygulama bildirimleri',
              _enabled,
              (v) async {
                setState(() => _enabled = v);
                await AppPrefs.setNotificationsEnabled(v);
                await _applyScheduling();
              },
            ),
            SizedBox(height: Responsive.gapSm(context)),
            _buildSwitchRow(
              context,
              'Günlük hatırlatıcı',
              'Her gün öğrenmeye devam et',
              _dailyReminder,
              (v) async {
                setState(() => _dailyReminder = v);
                await AppPrefs.setDailyReminderEnabled(v);
                await _applyScheduling();
              },
            ),
            SizedBox(height: Responsive.gapLg(context)),
            Text(
              'Hatırlatma saati',
              style: TextStyle(
                fontSize: Responsive.fontSizeBody(context),
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: Responsive.gapSm(context)),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
              child: InkWell(
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                  );
                  if (t == null) return;
                  setState(() => _reminderTime = t);
                  await AppPrefs.setDailyReminderTimeMinutes(t.hour * 60 + t.minute);
                  await _applyScheduling();
                },
                borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                child: Container(
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  decoration: AppTheme.cardDecorationFor(context).copyWith(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: AppTheme.primary),
                      SizedBox(width: Responsive.gapMd(context)),
                      Text(
                        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: Responsive.fontSizeTitleSmall(context),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.requestPermissionIfNeeded();
                  await NotificationService.showNow(
                    title: 'Notification test',
                    body: 'This is a test notification from the app.',
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Test bildirimi gönder'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  minimumSize: Size(0, Responsive.minTouchTarget(context)),
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.buttonPaddingVertical(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(BuildContext context, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: EdgeInsets.all(Responsive.cardPadding(context)),
      decoration: AppTheme.cardDecorationFor(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBody(context),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBodySmall(context),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
