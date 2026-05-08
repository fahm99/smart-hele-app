// Utility flags for platform detection
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final bool isWeb = kIsWeb;
final bool isAndroid = !kIsWeb && Platform.isAndroid;
final bool isIOS = !kIsWeb && Platform.isIOS;
