import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/sensor_data_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../providers/sensor_data_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/sensor_card.dart';
import '../../widgets/safety_gauge.dart';
import '../../widgets/fall_alert_overlay.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<SensorDataModel>? _dataSubscription;

  bool _isConnecting = false; // 🔥 مهم

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    final bluetoothProvider = context.read<BluetoothProvider>();
    final sensorDataProvider = context.read<SensorDataProvider>();
    final authProvider = context.read<AuthProvider>();

    _dataSubscription = bluetoothProvider.dataStream.listen((data) {
      sensorDataProvider.initializeStream(
        bluetoothProvider.dataStream,
        authProvider.user?.id ?? 'unknown',
      );
    });

    await bluetoothProvider.requestPermissions();

    if (!bluetoothProvider.isBluetoothEnabled) return;

    // 🔥 بدء البحث
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (var r in results) {
        // ⚠️ غيري الاسم إذا جهازك مختلف
        if (!_isConnecting && r.device.advName.contains("SSH-Helmet")) {
          _isConnecting = true;

          try {
            await r.device.connect(
              timeout: const Duration(seconds: 10),
              autoConnect: false,
            );

            print("✅ Connected to SSH-Helmet");

            await FlutterBluePlus.stopScan();
          } catch (e) {
            print("❌ Failed: $e");
            _isConnecting = false;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _dataSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bluetoothProvider = context.watch<BluetoothProvider>();
    final sensorData = bluetoothProvider.latestData;
    final l10n = AppLocalizations.of(context);

    double safetyValue = 1.0;
    String statusText = l10n.safe ?? 'SAFE';
    if (sensorData != null) {
      if (sensorData.fallDetected || sensorData.shockDetected) {
        safetyValue = 0.2;
        statusText = 'DANGER';
      } else if (!sensorData.isHeartRateNormal ||
          !sensorData.isTemperatureNormal) {
        safetyValue = 0.5;
        statusText = 'WARNING';
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(authProvider, l10n),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: SafetyGauge(
                        value: safetyValue,
                        status: statusText,
                        label: l10n.safetyStatus ?? 'Helmet Condition',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildListDelegate([
                        SensorCard(
                          icon: Icons.monitor_heart,
                          label: l10n.heartRateMeasurement,
                          value: sensorData != null && sensorData.heartRate > 0
                              ? '${sensorData.heartRate}'
                              : '--',
                          iconColor: Colors.redAccent,
                        ),
                        SensorCard(
                          icon: Icons.thermostat,
                          label: l10n.temperatureMeasurement,
                          value: sensorData != null &&
                                  sensorData.temperature > 0
                              ? '${sensorData.temperature.toStringAsFixed(1)}°C'
                              : '--',
                          iconColor: Colors.orangeAccent,
                        ),
                        SensorCard(
                          icon: Icons.battery_charging_full,
                          label: l10n.batteryLevel,
                          value: sensorData != null
                              ? '${sensorData.batteryLevel}%'
                              : '--',
                          iconColor:
                              sensorData != null && sensorData.isBatteryLow
                                  ? AppColors.error
                                  : AppColors.success,
                        ),
                        SensorCard(
                          icon: bluetoothProvider.isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          label: l10n.bluetoothConnection,
                          value: bluetoothProvider.isConnected ? 'LIVE' : 'OFF',
                          iconColor: bluetoothProvider.isConnected
                              ? AppColors.accent
                              : Colors.grey,
                        ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.location ?? 'Live Location',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildMap(sensorData, bluetoothProvider.isConnected),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildEmergencyButton(l10n),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
          const FallAlertOverlay(),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader(AuthProvider auth, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SSH ${l10n.dashboard ?? "Dashboard"}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'Welcome back, ${auth.user?.name ?? "Driver"}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const CircleAvatar(child: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildMap(SensorDataModel? sensorData, bool isHelmetConnected) {
    // إذا كانت الخوذة غير متصلة، لا نعرض أي بيانات خريطة
    if (!isHelmetConnected) {
      return _buildDisconnectedMapPlaceholder();
    }

    // إذا كانت الخوذة متصلة لكن لا توجد بيانات، نعرض موقع افتراضي
    if (sensorData == null || sensorData.latitude == 0.0 || sensorData.longitude == 0.0) {
      return _buildDefaultMap();
    }

    // نعرض الخريطة ببيانات GPS الحقيقية من الخوذة
    return _buildLiveMap(sensorData);
  }

  /// عرض رسالة عند عدم اتصال الخوذة
  Widget _buildDisconnectedMapPlaceholder() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Colors.red.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.red.shade300,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد بيانات - الخوذة غير متصلة',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى الاتصال بالخوذة الذكية',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// خريطة افتراضية عند عدم توفر بيانات GPS
  Widget _buildDefaultMap() {
    final double lat = AppConstants.defaultLatitude;
    final double lng = AppConstants.defaultLongitude;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(lat, lng), zoom: 15),
        ),
      ),
    );
  }

  /// خريطة حية ببيانات GPS من الخوذة
  Widget _buildLiveMap(SensorDataModel sensorData) {
    final double lat = sensorData.latitude;
    final double lng = sensorData.longitude;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.success,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: LatLng(lat, lng), zoom: 16),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: {
                Marker(
                  markerId: const MarkerId('helmet_location'),
                  position: LatLng(lat, lng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(
                    title: 'موقع الخوذة',
                    snippet: 'إحداثيات: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                  ),
                ),
              },
            ),
            // مؤشر الحالة الحية
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 8,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () => context.push('/create-report'),
      child: Text(l10n.emergencyCall.toUpperCase()),
    );
  }
}
