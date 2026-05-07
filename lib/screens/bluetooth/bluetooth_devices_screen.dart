import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/bluetooth_provider.dart';

/// Screen for scanning and connecting to SSH Smart Helmet via Bluetooth
class BluetoothDevicesScreen extends StatefulWidget {
  const BluetoothDevicesScreen({super.key});

  @override
  State<BluetoothDevicesScreen> createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BluetoothProvider>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, l10n, isArabic),

              // Content
              Expanded(
                child: Consumer<BluetoothProvider>(
                  builder: (context, bluetooth, child) {
                    if (!bluetooth.isBluetoothEnabled) {
                      return _buildBluetoothDisabled(
                          context, bluetooth, l10n, isArabic);
                    }
                    if (bluetooth.isScanning) {
                      return _buildScanningView(l10n, isArabic);
                    }
                    if (bluetooth.scannedDevices.isNotEmpty) {
                      return _buildDevicesList(bluetooth, l10n, isArabic);
                    }
                    return _buildEmptyState(context, bluetooth, l10n, isArabic);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              isArabic ? Icons.arrow_forward : Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              l10n.bluetoothConnection,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => context.read<BluetoothProvider>().startScan(),
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothDisabled(
    BuildContext context,
    BluetoothProvider bluetooth,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bluetooth_disabled,
                size: 64,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.bluetoothDisabled,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.enableBluetoothMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => bluetooth.enableBluetooth(),
              icon: const Icon(Icons.bluetooth),
              label: Text(l10n.enableBluetooth),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView(AppLocalizations l10n, bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 32),
            Text(
              l10n.scanningDevices,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.scanningHint,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildScanningTips(l10n, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningTips(AppLocalizations l10n, bool isArabic) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.tips,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(l10n.tip1, isArabic),
          _buildTipItem(l10n.tip2, isArabic),
          _buildTipItem(l10n.tip3, isArabic),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    BluetoothProvider bluetooth,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.devices_other,
                size: 64,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noDevicesFound,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDevicesHint,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => bluetooth.startScan(),
              icon: const Icon(Icons.search),
              label: Text(l10n.scanAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList(
    BluetoothProvider bluetooth,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    // Filter for SSH-Helmet devices
    final helmetDevices = bluetooth.scannedDevices.where((device) {
      final name = device.platformName.toLowerCase();
      return name.contains('ssh') ||
          name.contains('helmet') ||
          name.contains('esp32');
    }).toList();

    final otherDevices = bluetooth.scannedDevices.where((device) {
      final name = device.platformName.toLowerCase();
      return !name.contains('ssh') &&
          !name.contains('helmet') &&
          !name.contains('esp32');
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connected device info
        if (bluetooth.isConnected && bluetooth.deviceInfo != null) ...[
          _buildConnectedDeviceCard(bluetooth, l10n, isArabic),
          const SizedBox(height: 24),
        ],

        // Helmet devices
        if (helmetDevices.isNotEmpty) ...[
          _buildSectionTitle(l10n.smartHelmet, isArabic),
          const SizedBox(height: 8),
          ...helmetDevices.map((device) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDeviceCard(device, bluetooth, l10n, isArabic,
                    isHelmet: true),
              )),
          const SizedBox(height: 16),
        ],

        // Other devices
        if (otherDevices.isNotEmpty) ...[
          _buildSectionTitle(l10n.otherDevices, isArabic),
          const SizedBox(height: 8),
          ...otherDevices.map((device) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDeviceCard(device, bluetooth, l10n, isArabic,
                    isHelmet: false),
              )),
        ],
      ],
    );
  }

  Widget _buildConnectedDeviceCard(
    BluetoothProvider bluetooth,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final deviceInfo = bluetooth.deviceInfo!;
    final latestData = bluetooth.latestData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.2),
            AppColors.success.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_connected,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceInfo.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.connected,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.accent),
          const SizedBox(height: 12),

          // Device stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.battery_full,
                '${latestData?.batteryLevel ?? deviceInfo.batteryLevel}%',
                l10n.battery,
                _getBatteryColor(
                    latestData?.batteryLevel ?? deviceInfo.batteryLevel),
              ),
              _buildStatItem(
                Icons.favorite,
                '${latestData?.heartRate ?? 0}',
                l10n.heartRate,
                AppColors.error,
              ),
              _buildStatItem(
                Icons.thermostat,
                '${latestData?.temperature.toStringAsFixed(1) ?? '--'}°',
                l10n.temperature,
                AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Disconnect button
          OutlinedButton.icon(
            onPressed: () => _showDisconnectDialog(context, bluetooth, l10n),
            icon: const Icon(Icons.bluetooth_disabled, color: AppColors.error),
            label: Text(
              l10n.disconnect,
              style: const TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getBatteryColor(int level) {
    if (level <= 20) return AppColors.error;
    if (level <= 50) return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildSectionTitle(String title, bool isArabic) {
    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }

  Widget _buildDeviceCard(
    BluetoothDevice device,
    BluetoothProvider bluetooth,
    AppLocalizations l10n,
    bool isArabic, {
    required bool isHelmet,
  }) {
    final isConnecting = bluetooth.isConnecting &&
        bluetooth.connectedDevice?.remoteId == device.remoteId;
    final isConnected = bluetooth.isConnected &&
        bluetooth.connectedDevice?.remoteId == device.remoteId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isHelmet ? AppColors.primary.withOpacity(0.3) : AppColors.accent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isHelmet ? AppColors.primary : AppColors.textMuted)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConnected ? Icons.bluetooth_connected : Icons.headset_mic,
              color: isConnected
                  ? AppColors.success
                  : (isHelmet ? AppColors.primary : AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.platformName.isNotEmpty
                      ? device.platformName
                      : l10n.unknownDevice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  device.remoteId.str,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isConnecting)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.connected,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => _connectToDevice(context, device, l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.connect),
            ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(
    BuildContext context,
    BluetoothDevice device,
    AppLocalizations l10n,
  ) async {
    final bluetooth = context.read<BluetoothProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.connectingTo(device.platformName.isNotEmpty
            ? device.platformName
            : l10n.unknownDevice)),
        backgroundColor: AppColors.primary,
      ),
    );

    final success = await bluetooth.connectToDevice(device);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.connectionSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bluetooth.error ?? l10n.connectionFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDisconnectDialog(
    BuildContext context,
    BluetoothProvider bluetooth,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(l10n.disconnectHelmet),
        content: Text(l10n.disconnectConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              bluetooth.disconnect();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.disconnected),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.disconnect),
          ),
        ],
      ),
    );
  }
}
