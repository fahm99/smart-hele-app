import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/constants/app_constants.dart';
import '../models/device_model.dart';
import '../models/sensor_data_model.dart';
import '../services/notification_service.dart';

/// Provider for managing Bluetooth connectivity with ESP32
class BluetoothProvider extends ChangeNotifier {
  // Bluetooth state
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _error;

  // Device info
  BluetoothDevice? _connectedDevice;
  List<BluetoothDevice> _scannedDevices = [];
  DeviceModel? _deviceInfo;

  // Data stream
  SensorDataModel? _latestData;
  final StreamController<SensorDataModel> _dataStreamController =
      StreamController<SensorDataModel>.broadcast();

  // Subscriptions
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _dataSubscription;

  // Reconnect timer
  Timer? _reconnectTimer;
  String? _lastDeviceId;

  // Getters
  BluetoothAdapterState get adapterState => _adapterState;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String? get error => _error;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothDevice> get scannedDevices => _scannedDevices;
  DeviceModel? get deviceInfo => _deviceInfo;
  SensorDataModel? get latestData => _latestData;
  Stream<SensorDataModel> get dataStream => _dataStreamController.stream;
  bool get isBluetoothEnabled => _adapterState == BluetoothAdapterState.on;

  BluetoothProvider() {
    _init();
  }

  /// Initialize Bluetooth
  void _init() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (state == BluetoothAdapterState.off) {
        _isConnected = false;
        _connectedDevice = null;
      }
      notifyListeners();
    });
  }

  /// Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    // Bluetooth is not supported on web
    if (kIsWeb) {
      debugPrint('Bluetooth is not supported on web');
      return false;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final bluetooth = await Permission.bluetooth.request();
      final bluetoothScan = await Permission.bluetoothScan.request();
      final bluetoothConnect = await Permission.bluetoothConnect.request();
      final location = await Permission.location.request();

      return bluetooth.isGranted &&
          bluetoothScan.isGranted &&
          bluetoothConnect.isGranted &&
          location.isGranted;
    }
    return true;
  }

  /// Enable Bluetooth
  Future<bool> enableBluetooth() async {
    try {
      // Bluetooth is not supported on web
      if (kIsWeb) {
        debugPrint('Bluetooth is not supported on web');
        return false;
      }

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await FlutterBluePlus.turnOn();
      }
      return true;
    } catch (e) {
      _setError('فشل في تفعيل البلوتوث: $e');
      return false;
    }
  }

  /// Start scanning for devices
  Future<void> startScan() async {
    if (_isScanning) return;

    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      _setError('يرجى منح أذونات البلوتوث');
      return;
    }

    if (!isBluetoothEnabled) {
      final enabled = await enableBluetooth();
      if (!enabled) return;
    }

    _isScanning = true;
    _scannedDevices = [];
    _clearError();
    notifyListeners();

    try {
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (!_scannedDevices
              .any((d) => d.remoteId == result.device.remoteId)) {
            _scannedDevices.add(result.device);
            notifyListeners();
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: AppConstants.bluetoothScanDuration,
        androidUsesFineLocation: true,
      );

      await Future.delayed(AppConstants.bluetoothScanDuration);
      await stopScan();
    } catch (e) {
      _setError('فشل في البحث عن الأجهزة: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  /// Connect to a device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return false;

    _isConnecting = true;
    _clearError();
    notifyListeners();

    try {
      // Disconnect from any existing device
      await disconnect();

      // Connect to the new device
      await device.connect(
        autoConnect: false,
        mtu: null,
      );

      _connectedDevice = device;
      _lastDeviceId = device.remoteId.str;

      // Listen to connection state
      _connectionSubscription = device.connectionState.listen((state) {
        _isConnected = state == BluetoothConnectionState.connected;
        notifyListeners();

        if (!_isConnected && _lastDeviceId != null) {
          _scheduleReconnect();
        }
      });

      // Discover services and characteristics
      await _setupDataListener(device);

      // Create device info
      _deviceInfo = DeviceModel(
        id: device.remoteId.str,
        name:
            device.platformName.isNotEmpty ? device.platformName : 'SSH-Helmet',
        macAddress: device.remoteId.str,
        isConnected: true,
        createdAt: DateTime.now(),
      );

      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل في الاتصال بالجهاز: $e');
      _isConnecting = false;
      _scheduleReconnect();
      notifyListeners();
      return false;
    }
  }

  /// Setup data listener for the connected device
  Future<void> _setupDataListener(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      for (final service in services) {
        if (service.uuid.toString() == AppConstants.esp32ServiceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.toString() ==
                AppConstants.esp32CharacteristicUuid) {
              // Enable notifications
              await characteristic.setNotifyValue(true);

              // Listen to data
              _dataSubscription = characteristic.lastValueStream.listen((data) {
                if (data.isNotEmpty) {
                  _processReceivedData(data);
                }
              });

              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error setting up data listener: $e');
    }
  }

  /// Process received data from ESP32
  void _processReceivedData(List<int> data) {
    try {
      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Check if this is a system notification from the helmet
      if (jsonData['type'] == 'notification') {
        final String title = jsonData['title'] ?? 'Helmet Notification';
        final String body = jsonData['body'] ?? '';

        NotificationService().showSimpleNotification(
          title: title,
          body: body,
        );
        return; // Don't process as sensor data
      }

      final sensorData = SensorDataModel.fromJson(
        jsonData,
        _deviceInfo?.userId ?? 'unknown',
      );

      _latestData = sensorData;
      _dataStreamController.add(sensorData);

      // Update device battery level
      if (_deviceInfo != null) {
        _deviceInfo = _deviceInfo!.copyWith(
          batteryLevel: sensorData.batteryLevel,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error processing sensor data: $e');
    }
  }

  /// Disconnect from device
  Future<void> disconnect() async {
    try {
      await _dataSubscription?.cancel();
      await _connectionSubscription?.cancel();

      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }

      _connectedDevice = null;
      _isConnected = false;
      _deviceInfo = null;
      _reconnectTimer?.cancel();
      notifyListeners();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  /// Schedule auto-reconnect
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(AppConstants.bluetoothReconnectDelay, () async {
      if (_lastDeviceId != null && !_isConnected) {
        // Try to find and reconnect to the last device
        await startScan();

        final device = _scannedDevices.firstWhere(
          (d) => d.remoteId.str == _lastDeviceId,
          orElse: () => throw StateError('Device not found'),
        );

        await connectToDevice(device);
      }
    });
  }

  /// Send command to ESP32
  Future<bool> sendCommand(String command) async {
    if (!_isConnected || _connectedDevice == null) return false;

    try {
      final services = await _connectedDevice!.discoverServices();

      for (final service in services) {
        if (service.uuid.toString() == AppConstants.esp32ServiceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.toString() ==
                AppConstants.esp32CharacteristicUuid) {
              final data = utf8.encode(command);
              await characteristic.write(data);
              return true;
            }
          }
        }
      }
    } catch (e) {
      _setError('فشل في إرسال الأمر: $e');
    }

    return false;
  }

  /// Clear error
  void _clearError() {
    _error = null;
  }

  /// Set error message
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _reconnectTimer?.cancel();
    _dataStreamController.close();
    super.dispose();
  }
}
