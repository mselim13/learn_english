import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Responsive.gapLg(context);
    final iconBox = Responsive.scaled(context, min: 88, max: 120);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Hakkında'),
            SizedBox(height: spacing),
            Center(
              child: Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + 6),
                ),
                child: Icon(
                  Icons.school,
                  size: Responsive.iconSizeLarge(context),
                  color: AppTheme.primary,
                ),
              ),
            ),
            SizedBox(height: Responsive.gapMd(context)),
            Center(
              child: Text(
                'Learn English',
                style: TextStyle(
                  fontSize: Responsive.fontSizeTitle(context),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            SizedBox(height: Responsive.gapXs(context)),
            Center(
              child: Text(
                'Sürüm 1.0.0 (Build 1)',
                style: TextStyle(
                  fontSize: Responsive.fontSizeBodySmall(context),
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: spacing),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.cardPadding(context)),
              decoration: AppTheme.cardDecorationFor(context),
              child: Text(
                'Türkçe konuşan kullanıcılar için İngilizce öğrenme uygulaması. '
                'Kelime, dinleme, konuşma ve yazma becerilerini geliştirmene yardımcı olur.',
                style: TextStyle(
                  fontSize: Responsive.fontSizeBody(context),
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(height: Responsive.gapMd(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.cardPadding(context)),
              decoration: AppTheme.cardDecorationFor(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İletişim',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBody(context),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: Responsive.gapSm(context)),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppTheme.primary,
                        size: Responsive.iconSizeSmall(context),
                      ),
                      SizedBox(width: Responsive.gapSm(context)),
                      const Expanded(
                        child: Text(
                          'support@learnenglish.app',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.gapXs(context)),
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: AppTheme.primary,
                        size: Responsive.iconSizeSmall(context),
                      ),
                      SizedBox(width: Responsive.gapSm(context)),
                      const Expanded(
                        child: Text(
                          'learnenglish.app',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
