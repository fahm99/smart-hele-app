import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/alert_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/admin_bottom_nav_bar.dart';
import '../../widgets/asset_image_widget.dart';

/// Admin home screen with details and management
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  int _totalDrivers = 0;
  int _totalAlerts = 0;
  int _totalReports = 0;
  List<AlertModel> _recentAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _firebaseService.getDashboardStats();
      final alerts = await _firebaseService.getAllAlerts(limit: 5);

      setState(() {
        _totalDrivers = stats['drivers'] ?? 0;
        _totalAlerts = stats['alerts'] ?? 0;
        _totalReports = stats['reports'] ?? 0;
        _recentAlerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              l10n.adminWelcome,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildStatsRow(l10n),
                            const SizedBox(height: 20),
                            _buildRecentAlertsSection(l10n),
                            const SizedBox(height: 16),
                            _buildTodayReportSection(l10n),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
            assetPath: 'assets/admin-2.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorWidget: Icon(
              Icons.admin_panel_settings,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n) {
    return Row(
      children: [
        _buildStatBox(
          value: '$_totalDrivers',
          label: l10n.drivers,
          color: const Color(0xFF4A90E2),
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          value: '$_totalReports',
          label: l10n.reports,
          color: AppColors.error,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          value: '$_totalAlerts',
          label: l10n.alerts,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              l10n.recentReports,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_recentAlerts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.noNotifications,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ..._recentAlerts.take(3).map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => context.go('/management'),
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReportSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              l10n.todayReport,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                '•',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${l10n.alerts}: $_totalAlerts',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '•',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${l10n.reports}: $_totalReports',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.go('/management'),
              child: Text(
                l10n.viewReport,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
