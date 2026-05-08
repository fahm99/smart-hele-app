import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/bluetooth_provider.dart';

/// Screen for scanning and selecting Bluetooth devices
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتصال الخوذة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BluetoothProvider>().startScan(),
          ),
        ],
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, bluetooth, child) {
          // Check if Bluetooth is enabled
          if (!bluetooth.isBluetoothEnabled) {
            return _buildBluetoothDisabled(context, bluetooth);
          }

          // Show scanning state
          if (bluetooth.isScanning) {
            return _buildScanningView();
          }

          // Show devices list
          if (bluetooth.scannedDevices.isNotEmpty) {
            return _buildDevicesList(bluetooth);
          }

          // Empty state
          return _buildEmptyState(context, bluetooth);
        },
      ),
    );
  }

  Widget _buildBluetoothDisabled(
      BuildContext context, BluetoothProvider bluetooth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 24),
            const Text(
              'البلوتوث غير مفعل',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'يرجى تفعيل البلوتوث للاتصال بالخوذة الذكية',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => bluetooth.enableBluetooth(),
              icon: const Icon(Icons.bluetooth),
              label: const Text('تفعيل البلوتوث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'جاري البحث عن الأجهزة...',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'تأكد من تشغيل الخوذة وأنها قريبة من الهاتف',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, BluetoothProvider bluetooth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.devices_other,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 24),
            const Text(
              'لم يتم العثور على أجهزة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'تأكد من:\n• تشغيل الخوذة الذكية\n• تفعيل البلوتوث على الهاتف\n• أن الخوذة قريبة من الهاتف',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => bluetooth.startScan(),
              icon: const Icon(Icons.search),
              label: const Text('بحث مرة أخرى'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList(BluetoothProvider bluetooth) {
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
        if (helmetDevices.isNotEmpty) ...[
          const Text(
            'الخوذة الذكية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...helmetDevices.map((device) => _buildDeviceTile(device, bluetooth)),
          const SizedBox(height: 24),
        ],
        if (otherDevices.isNotEmpty) ...[
          const Text(
            'أجهزة أخرى',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...otherDevices.map((device) => _buildDeviceTile(device, bluetooth)),
        ],
      ],
    );
  }

  Widget _buildDeviceTile(BluetoothDevice device, BluetoothProvider bluetooth) {
    final isConnecting = bluetooth.isConnecting &&
        bluetooth.connectedDevice?.remoteId == device.remoteId;
    final isConnected = bluetooth.isConnected &&
        bluetooth.connectedDevice?.remoteId == device.remoteId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isConnected ? Icons.bluetooth_connected : Icons.headset_mic,
            color: isConnected ? AppColors.success : AppColors.primary,
          ),
        ),
        title: Text(
          device.platformName.isNotEmpty
              ? device.platformName
              : 'جهاز بدون اسم',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(device.remoteId.str),
        trailing: isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : isConnected
                ? Chip(
                    label: const Text('متصل'),
                    backgroundColor: AppColors.success.withOpacity(0.1),
                  )
                : ElevatedButton(
                    onPressed: () => _connectToDevice(context, device),
                    child: const Text('اتصال'),
                  ),
        onTap: isConnected ? () => _showDeviceInfo(context, device) : null,
      ),
    );
  }

  Future<void> _connectToDevice(
      BuildContext context, BluetoothDevice device) async {
    final bluetooth = context.read<BluetoothProvider>();

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري الاتصال بـ ${device.platformName}...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final success = await bluetooth.connectToDevice(device);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الاتصال بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bluetooth.error ?? 'فشل في الاتصال'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeviceInfo(BuildContext context, BluetoothDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات الجهاز'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('الاسم', device.platformName),
            _buildInfoRow('المعرف', device.remoteId.str),
            _buildInfoRow('النوع', 'SSH Smart Helmet'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BluetoothProvider>().disconnect();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('قطع الاتصال'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
