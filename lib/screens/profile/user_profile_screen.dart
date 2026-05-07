import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sensor_data_provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/asset_image_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool dataEditEnabled = true;
  bool notificationsEnabled = true;
  bool locationTrackingEnabled = true;
  bool passwordProtectionEnabled = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<SensorDataProvider>().loadAlerts(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bluetoothProvider = context.watch<BluetoothProvider>();
    final user = authProvider.user;
    final latestData = bluetoothProvider.latestData;
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const AssetImageWidget(
                        assetPath: 'assets/helmet.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                ),
                // Title
                Text(
                  l10n.myAccount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Image and Name
                const SizedBox(
                  width: 120,
                  height: 120,
                  child: AssetImageWidget(
                    assetPath: 'assets/helmet.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? l10n.notAvailable,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Status and Rating Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Text(
                              '${l10n.status}: ${user?.isActive ?? false ? l10n.active : l10n.inactive}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            Switch(
                              value: user?.isActive ?? false,
                              onChanged: (value) {
                                // TODO: Update user status in database
                              },
                              activeColor: AppColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Text(
                              '${l10n.driverRating}: ${user?.rating.toStringAsFixed(1) ?? '0.0'}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                final rating = user?.rating ?? 0.0;
                                return Icon(
                                  index < rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 24,
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Safety Record Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            l10n.safetyRecord,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(l10n.totalTrips,
                            user?.totalTrips.toString() ?? '0'),
                        _buildInfoRow(l10n.safetyAlerts,
                            '${user?.safetyAlerts ?? 0}${(user?.safetyAlerts ?? 0) > 0 ? '!' : ''}'),
                        _buildInfoRow(
                            l10n.safeTrips, user?.safeTrips.toString() ?? '0'),
                        _buildInfoRow(
                            l10n.lastTrip,
                            user?.lastTripDate != null
                                ? _formatDate(user!.lastTripDate!)
                                : l10n.noTrips),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Driver Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            l10n.driverInfo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                            l10n.email, user?.email ?? l10n.notAvailable),
                        _buildInfoRow(
                            l10n.phone, user?.phone ?? l10n.notAvailable),
                        _buildInfoRow(
                            l10n.idNumber, user?.idNumber ?? l10n.notAvailable),
                        _buildInfoRow(l10n.vehicleType,
                            user?.vehicleType ?? l10n.notSpecified),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Helmet Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            l10n.helmet,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Text(
                              '${l10n.helmetStatus}: ${bluetoothProvider.isConnected ? l10n.connected : l10n.disconnected}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: bluetoothProvider.isConnected,
                                  onChanged: (value) async {
                                    if (value) {
                                      await bluetoothProvider.startScan();
                                    } else {
                                      await bluetoothProvider.disconnect();
                                    }
                                  },
                                  activeColor: AppColors.success,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                            l10n.batteryLevel,
                            latestData != null
                                ? '${latestData.batteryLevel}%'
                                : l10n.notAvailable),
                        _buildInfoRow(
                            l10n.lastConnection,
                            bluetoothProvider.isConnected
                                ? l10n.now
                                : l10n.disconnected),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Privacy Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            l10n.privacySecurity,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.editData,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                textAlign:
                                    isArabic ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                            Switch(
                              value: dataEditEnabled,
                              onChanged: (value) {
                                setState(() => dataEditEnabled = value);
                              },
                              activeColor: AppColors.success,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.notifications,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                textAlign:
                                    isArabic ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                            Switch(
                              value: notificationsEnabled,
                              onChanged: (value) {
                                setState(() => notificationsEnabled = value);
                              },
                              activeColor: AppColors.success,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.enableLocationTracking,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                textAlign:
                                    isArabic ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                            Switch(
                              value: locationTrackingEnabled,
                              onChanged: (value) {
                                setState(() => locationTrackingEnabled = value);
                              },
                              activeColor: AppColors.success,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.passwordProtection,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                textAlign:
                                    isArabic ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                            Switch(
                              value: passwordProtectionEnabled,
                              onChanged: (value) {
                                setState(
                                    () => passwordProtectionEnabled = value);
                              },
                              activeColor: AppColors.success,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.logout,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                textAlign:
                                    isArabic ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                            Switch(
                              value: false,
                              onChanged: (value) async {
                                if (value) {
                                  await authProvider.signOut();
                                  if (context.mounted) {
                                    context.go('/login-selection');
                                  }
                                }
                              },
                              activeColor: AppColors.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          isArabic ? Icons.arrow_forward : Icons.arrow_back,
                        ),
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              textAlign: isArabic ? TextAlign.left : TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }
}
