import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../services/firebase_service.dart';

/// Screen for creating emergency reports
class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  String _selectedReportType = 'emergency';
  bool _isSubmitting = false;

  final List<Map<String, String>> _reportTypes = [
    {'value': 'emergency', 'label': 'طوارئ', 'labelEn': 'Emergency'},
    {'value': 'accident', 'label': 'حادث', 'labelEn': 'Accident'},
    {
      'value': 'helmet_malfunction',
      'label': 'عطل في الخوذة',
      'labelEn': 'Helmet Malfunction'
    },
    {'value': 'other', 'label': 'أخرى', 'labelEn': 'Other'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final authProvider = context.read<AuthProvider>();
      final bluetoothProvider = context.read<BluetoothProvider>();

      // تحقق من أن المستخدم مسجل الدخول
      if (!authProvider.isAuthenticated) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // تحقق من أن بيانات المستخدم محملة
      if (!authProvider.isUserDataLoaded) {
        // جرب إعادة تحميل بيانات المستخدم
        await authProvider.reloadUser();

        if (!authProvider.isUserDataLoaded) {
          throw Exception(
              'لم يتم العثور على بيانات المستخدم. يرجى تسجيل الخروج والدخول مرة أخرى');
        }
      }

      final user = authProvider.user;
      final sensorData = bluetoothProvider.latestData;

      if (user == null) {
        throw Exception(
            'لم يتم العثور على بيانات المستخدم. يرجى تسجيل الخروج والدخول مرة أخرى');
      }

      final report = ReportModel(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        reportType: _selectedReportType,
        latitude: sensorData?.latitude,
        longitude: sensorData?.longitude,
        timestamp: DateTime.now(),
      );

      await _firebaseService.createReport(report);

      if (!mounted) return;
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال التقرير بنجاح'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      // Wait a moment for the snackbar to show, then pop
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // رسالة خطأ أكثر وضوحاً
      String errorMessage = 'فشل إرسال التقرير';
      if (e.toString().contains('User not found') ||
          e.toString().contains('لم يتم العثور')) {
        errorMessage =
            'لم يتم العثور على بيانات المستخدم. يرجى تسجيل الدخول مرة أخرى';
      } else if (e.toString().contains('يجب تسجيل الدخول')) {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      } else if (e.toString().contains('جاري تحميل')) {
        errorMessage =
            'جاري تحميل بيانات المستخدم، يرجى الانتظار قليلاً والمحاولة مرة أخرى';
      } else {
        errorMessage =
            'فشل إرسال التقرير: ${e.toString().replaceAll('Exception: ', '')}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textPrimary,
                    ),
                    Expanded(
                      child: Text(
                        l10n.emergencyCall,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Report Type
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'نوع التقرير',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._reportTypes.map((type) {
                                return RadioListTile<String>(
                                  title: Text(
                                    type['label']!,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  value: type['value']!,
                                  groupValue: _selectedReportType,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedReportType = value!;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'عنوان التقرير',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'أدخل عنوان التقرير',
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted.withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'الرجاء إدخال عنوان التقرير';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تفاصيل التقرير',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _descriptionController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: 'اشرح التفاصيل بدقة...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted.withOpacity(0.5),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'الرجاء إدخال تفاصيل التقرير';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'التفاصيل يجب أن تكون 10 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor:
                                AppColors.error.withOpacity(0.5),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'إرسال التقرير',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
