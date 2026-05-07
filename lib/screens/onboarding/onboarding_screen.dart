import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/asset_image_widget.dart';

/// Onboarding screen - shows relevant pages based on user type
class OnboardingScreen extends StatefulWidget {
  final String userType; // 'admin' or 'user'
  const OnboardingScreen({super.key, this.userType = 'user'});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  List<OnboardingPage> get _pages {
    if (widget.userType == 'admin') {
      return [
        OnboardingPage(
          imageAsset: 'assets/admin.png',
          title: 'إشراف ذكي ومتكامل',
          description:
              'مراقبة فورية لحالة السائقين والخوذ الذكية من خلال نظام تحكم مركزي متقدم',
          features: [
            OnboardingFeature(
              icon: Icons.visibility,
              title: 'إشراف ذكي ومتكامل',
              description:
                  'مراقبة فورية لحالة السائقين والخوذ الذكية من خلال نظام تحكم مركزي متقدم',
            ),
            OnboardingFeature(
              icon: Icons.notification_important,
              title: 'إدارة التنبيهات الطارئة',
              description:
                  'استقبال تنبيهات فورية عند السقوط أو الحوادث لضمان سرعة الاستجابة واتخاذ الإجراء المناسب',
            ),
            OnboardingFeature(
              icon: Icons.analytics,
              title: 'لوحة تحكم وتحليلات',
              description:
                  'عرض التقارير والإحصائيات وسجل الحوادث لدعم اتخاذ القرار وتحسين مستوى السلامة',
            ),
            OnboardingFeature(
              icon: Icons.people,
              title: 'إدارة السائقين',
              description:
                  'إضافة وتحديث وإدارة حسابات السائقين ومتابعة حالتهم التشغيلية بكل سهولة',
            ),
          ],
        ),
      ];
    } else {
      return [
        OnboardingPage(
          imageAsset: 'assets/helmet.png',
          title: 'حماية ذكية استباقية',
          description:
              'تبدو ذكي بالمخاطر المحيطة قبل وقوعها بفضل أجهزة الاستشعار المتقدمة',
          features: [
            OnboardingFeature(
              icon: Icons.shield,
              title: 'حماية ذكية استباقية',
              description:
                  'تبدو ذكي بالمخاطر المحيطة قبل وقوعها بفضل أجهزة الاستشعار المتقدمة',
            ),
            OnboardingFeature(
              icon: Icons.warning_amber,
              title: 'تنبيهات السقوط الفورية',
              description:
                  'إرسال إشارات استغاثة تلقائية لمسؤول السلامة عند رصد أي سقوط مفاجئ أو اصطدام',
            ),
            OnboardingFeature(
              icon: Icons.favorite,
              title: 'تتبع العلامات الحيوية',
              description:
                  'مراقبة مستمرة لمعدل ضربات القلب والجهد البدني لضمان سلامتك طوال فترة العمل',
            ),
          ],
        ),
      ];
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      // Navigate to the correct login screen based on user type
      if (widget.userType == 'admin') {
        context.go('/admin-login');
      } else {
        context.go('/user-login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Page indicator (only shown if multiple pages)
                if (_pages.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.textMuted.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                if (_pages.length > 1) const SizedBox(height: 40),
                if (_pages.length == 1) const SizedBox(height: 20),

                // Main icon/image
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  child: page.imageAsset != null
                      ? AssetImageWidget(
                          assetPath: page.imageAsset!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorWidget: Icon(
                            page.icon ?? Icons.help_outline,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          page.icon,
                          size: 60,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(height: 40),

                // Features list
                Expanded(
                  child: ListView.builder(
                    itemCount: page.features.length,
                    itemBuilder: (context, index) {
                      final feature = page.features[index];
                      return _buildFeatureItem(feature);
                    },
                  ),
                ),
                // Next / Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'التالي' : 'ابدأ الآن',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(OnboardingFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              feature.icon,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData? icon;
  final String? imageAsset;
  final String title;
  final String description;
  final List<OnboardingFeature> features;

  OnboardingPage({
    this.icon,
    this.imageAsset,
    required this.title,
    required this.description,
    required this.features,
  });
}

class OnboardingFeature {
  final IconData icon;
  final String title;
  final String description;

  OnboardingFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
