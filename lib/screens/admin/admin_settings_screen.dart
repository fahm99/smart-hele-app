import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/admin_bottom_nav_bar.dart';
import '../../widgets/settings_card.dart';
import '../../widgets/asset_image_widget.dart';

/// Admin settings screen
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(l10n),
                const SizedBox(height: 24),

                // Title
                Center(
                  child: Text(
                    l10n.adminSettings,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account section
                SettingsCard(
                  title: l10n.account,
                  children: [
                    _buildInfoRow(
                        l10n.organizationName, l10n.smartSafetyOrganization),
                    _buildInfoRow(l10n.accountType, l10n.systemAdmin),
                    _buildInfoRow(l10n.accountStatus, l10n.active,
                        valueColor: AppColors.success),
                    _buildInfoRow(l10n.email, user?.email ?? ''),
                  ],
                ),
                const SizedBox(height: 16),

                // Notifications section
                SettingsCard(
                  title: l10n.notifications,
                  children: [
                    _buildToggleRow(l10n.emergencyAlerts, true, (value) {}),
                    _buildToggleRow(l10n.fallAlerts, true, (value) {}),
                    _buildToggleRow(l10n.vitalSignsAlerts, true, (value) {}),
                  ],
                ),
                const SizedBox(height: 16),

                // Tracking section
                SettingsCard(
                  title: l10n.trackingMonitoring,
                  children: [
                    _buildToggleRow(l10n.enableLiveTracking, true, (value) {}),
                    _buildLinkRow(l10n.routeHistory, () {}),
                    _buildLinkRow(l10n.trackingDataRetention, () {}),
                  ],
                ),
                const SizedBox(height: 16),

                // Reports section
                SettingsCard(
                  title: l10n.reportsAnalytics,
                  children: [
                    _buildLinkRow(l10n.performanceReports, () {}),
                    _buildLinkRow(l10n.exportReports, () {}),
                    _buildLinkRow(l10n.incidentLog, () {}),
                  ],
                ),
                const SizedBox(height: 16),

                // Privacy section
                SettingsCard(
                  title: l10n.privacySecurity,
                  children: [
                    _buildLinkRow(l10n.changePassword, () {
                      context.push('/change-password');
                    }),
                    _buildLinkRow(l10n.privacyPolicy, () {}),
                  ],
                ),
                const SizedBox(height: 16),

                // Language section
                SettingsCard(
                  title: l10n.language,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => languageProvider.toggleLanguage(),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                          ),
                          child: Text(
                            languageProvider.isArabic ? 'English' : 'العربية',
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        const Text(
                          'العربية / English',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Account management section
                SettingsCard(
                  title: l10n.accountManagement,
                  children: [
                    _buildLinkRow(l10n.manageDrivers, () {}),
                    _buildLinkRow(l10n.manageSmartHelmets, () {}),
                    _buildLinkRow(l10n.permissionsAccess, () {}),
                  ],
                ),
                const SizedBox(height: 32),

                // Logout button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            context.go('/login-selection');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          l10n.logout,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.appTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const AssetImageWidget(
          assetPath: 'assets/admin-3.png',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.chevron_left,
              color: AppColors.textMuted,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
