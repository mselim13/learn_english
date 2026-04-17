import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
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
              (v) => setState(() => _enabled = v),
            ),
            SizedBox(height: Responsive.gapSm(context)),
            _buildSwitchRow(
              context,
              'Günlük hatırlatıcı',
              'Her gün öğrenmeye devam et',
              _dailyReminder,
              (v) => setState(() => _dailyReminder = v),
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
                  if (t != null) setState(() => _reminderTime = t);
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
