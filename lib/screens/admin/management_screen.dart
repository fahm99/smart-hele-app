import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/alert_model.dart';
import '../../models/report_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/admin_bottom_nav_bar.dart';
import '../../widgets/asset_image_widget.dart';

/// Management screen for reports and alerts
class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  int _selectedTab = 0; // 0: التقارير, 1: لوحة التحكم, 2: بلاغات

  List<AlertModel> _alerts = [];
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final alerts = await _firebaseService.getAllAlerts();
      final reports = await _firebaseService.getAllReports();

      setState(() {
        _alerts = alerts;
        _reports = reports;
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
              const SizedBox(height: 16),
              Text(
                l10n.detailsManagement,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildTabs(l10n),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(l10n),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 2),
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
          AssetImageWidget(
            assetPath: 'assets/admin-2.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorWidget: const Icon(
              Icons.admin_panel_settings,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTab(l10n.reportsTab, 0),
          const SizedBox(width: 10),
          _buildTab(l10n.controlPanel, 1),
          const SizedBox(width: 10),
          _buildTab(l10n.notificationsTab, 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF5B6B9E) : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF5B6B9E) : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    switch (_selectedTab) {
      case 0:
        return _buildReportsTab(l10n);
      case 1:
        return _buildControlPanelTab(l10n);
      case 2:
        return _buildNotificationsTab(l10n);
      default:
        return const SizedBox();
    }
  }

  Widget _buildReportsTab(AppLocalizations l10n) {
    if (_reports.isEmpty) {
      return Center(
        child: Text(
          l10n.noReports,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report: report, l10n: l10n);
      },
    );
  }

  Widget _buildControlPanelTab(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.controlPanel,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(AppLocalizations l10n) {
    if (_alerts.isEmpty) {
      return Center(
        child: Text(
          l10n.noNotifications,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildDriverCard(
          name: alert.userName,
          status: alert.title,
          statusColor: _getAlertColor(alert.alertType),
          l10n: l10n,
        );
      },
    );
  }

  Color _getAlertColor(String alertType) {
    switch (alertType) {
      case 'sos':
        return AppColors.error;
      case 'fall':
        return AppColors.error;
      case 'shock':
        return AppColors.warning;
      case 'heart_rate':
        return Colors.red;
      case 'temperature':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildDriverCard({
    required String name,
    required String status,
    required Color statusColor,
    required AppLocalizations l10n,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.viewReport,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required ReportModel report,
    required AppLocalizations l10n,
  }) {
    Color statusColor;
    switch (report.status) {
      case 'pending':
        statusColor = AppColors.warning;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'resolved':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.getStatusDisplayName(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                report.userName,
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            report.getReportTypeDisplayName(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.description,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _showReportDetails(report, l10n);
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.viewReport,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                _formatDateTime(report.timestamp),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDetails(ReportModel report, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          report.title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('اسم المستخدم', report.userName),
              _buildDetailRow('البريد الإلكتروني', report.userEmail),
              _buildDetailRow('نوع التقرير', report.getReportTypeDisplayName()),
              _buildDetailRow('الحالة', report.getStatusDisplayName()),
              _buildDetailRow('التاريخ', _formatDateTime(report.timestamp)),
              const Divider(color: AppColors.borderLight),
              const Text(
                'التفاصيل:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (report.latitude != null && report.longitude != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'الموقع',
                  '${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)}',
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!report.isResolved)
            TextButton(
              onPressed: () async {
                await _firebaseService.updateReportStatus(
                  report.id!,
                  'resolved',
                  resolvedBy: 'Admin',
                );
                Navigator.pop(context);
                _loadData();
              },
              child: const Text(
                'تم الحل',
                style: TextStyle(color: AppColors.success),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}  ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
