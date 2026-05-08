import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_constants.dart';

/// Service for handling Bluetooth Low Energy communication with ESP32
class BluetoothService {
  // Singleton pattern
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // Bluetooth state
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isScanning = false;
  bool _isConnected = false;

  // Device info
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic;

  // Subscriptions
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // Stream controllers
  final StreamController<Map<String, dynamic>> _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<BluetoothAdapterState> _stateStreamController =
      StreamController<BluetoothAdapterState>.broadcast();

  // Getters
  BluetoothAdapterState get adapterState => _adapterState;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;
  Stream<BluetoothAdapterState> get stateStream =>
      _stateStreamController.stream;

  /// Initialize the service
  Future<void> initialize() async {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      _stateStreamController.add(state);
    });
  }

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final permissions = [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ];

      for (final permission in permissions) {
        final status = await permission.request();
        if (!status.isGranted) {
          debugPrint('Permission ${permission.toString()} not granted');
          return false;
        }
      }
    }
    return true;
  }

  /// Enable Bluetooth adapter
  Future<bool> enableBluetooth() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await FlutterBluePlus.turnOn();
      }
      return true;
    } catch (e) {
      debugPrint('Error enabling Bluetooth: $e');
      return false;
    }
  }

  /// Start scanning for BLE devices
  Future<List<BluetoothDevice>> scanForDevices({Duration? timeout}) async {
    if (_isScanning) return [];

    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      throw Exception('Bluetooth permissions not granted');
    }

    if (_adapterState != BluetoothAdapterState.on) {
      final enabled = await enableBluetooth();
      if (!enabled) {
        throw Exception('Bluetooth is not enabled');
      }
    }

    _isScanning = true;
    final devices = <BluetoothDevice>[];

    try {
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (!devices.any((d) => d.remoteId == result.device.remoteId)) {
            devices.add(result.device);
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: timeout ?? AppConstants.bluetoothScanDuration,
        androidUsesFineLocation: true,
      );

      await Future.delayed(timeout ?? AppConstants.bluetoothScanDuration);
    } finally {
      await stopScan();
    }

    return devices;
  }

  /// Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _isScanning = false;
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  /// Connect to a specific device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      // Disconnect from any existing connection
      await disconnect();

      // Connect to the device
      await device.connect(
        autoConnect: false,
        mtu: null,
      );

      _connectedDevice = device;

      // Listen to connection state changes
      _connectionSubscription = device.connectionState.listen((state) {
        _isConnected = state == BluetoothConnectionState.connected;
        if (!_isConnected) {
          _dataCharacteristic = null;
        }
      });

      // Discover services and setup data listener
      await _setupNotifications(device);

      return true;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }

  /// Setup notifications for data characteristic
  Future<void> _setupNotifications(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      for (final service in services) {
        if (service.uuid.toString() == AppConstants.esp32ServiceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.toString() ==
                AppConstants.esp32CharacteristicUuid) {
              _dataCharacteristic = characteristic;

              // Enable notifications
              await characteristic.setNotifyValue(true);

              // Listen for data
              characteristic.lastValueStream.listen((data) {
                if (data.isNotEmpty) {
                  _processData(data);
                }
              });

              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error setting up notifications: $e');
    }
  }

  /// Process received data
  void _processData(List<int> data) {
    try {
      final jsonString = utf8.decode(data);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      _dataStreamController.add(jsonData);
    } catch (e, st) {
      try {
        final raw = utf8.decode(data);
        debugPrint('Error processing data (invalid JSON). Raw: $raw Error: $e');
      } catch (_) {
        debugPrint('Error processing data and failed to decode raw bytes: $e');
      }
      debugPrint(st.toString());
    }
  }

  /// Send data to the connected device
  Future<bool> sendData(String data) async {
    if (_dataCharacteristic == null || !_isConnected) {
      return false;
    }

    try {
      final bytes = utf8.encode(data);
      await _dataCharacteristic!.write(bytes);
      return true;
    } catch (e) {
      debugPrint('Error sending data: $e');
      return false;
    }
  }

  /// Send command to ESP32
  Future<bool> sendCommand(String command) async {
    final commandData = jsonEncode({'command': command});
    return await sendData(commandData);
  }

  /// Trigger a buzzer alert on the helmet
  Future<bool> triggerHelmetAlert({int durationMs = 1000}) async {
    final alertData = jsonEncode(
        {'command': 'BUZZER_ON', 'duration': durationMs, 'type': 'alert'});
    return await sendData(alertData);
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    try {
      await _connectionSubscription?.cancel();

      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }

      _connectedDevice = null;
      _dataCharacteristic = null;
      _isConnected = false;
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  /// Find ESP32 device by name
  Future<BluetoothDevice?> findESP32Device() async {
    final devices = await scanForDevices(timeout: const Duration(seconds: 5));

    for (final device in devices) {
      final platformName = device.platformName;
      final advName = device.advName;
      if (platformName.contains(AppConstants.esp32DeviceName) ||
          advName.contains(AppConstants.esp32DeviceName)) {
        return device;
      }
    }

    return null;
  }

  /// Auto-connect to ESP32
  Future<bool> autoConnect() async {
    final device = await findESP32Device();
    if (device != null) {
      return await connect(device);
    }
    return false;
  }

  /// Dispose resources
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _dataStreamController.close();
    _stateStreamController.close();
  }
}
