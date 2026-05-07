# دليل إعداد الأذونات للتطبيق
## Permissions Setup Guide

هذا الملف يشرح كيفية إعداد جميع الأذونات المطلوبة لتطبيق SSH Helmet على أندرويد و iOS.

---

## 📱 أذونات أندرويد (Android Permissions)

### 1. ملف `android/app/src/main/AndroidManifest.xml`

أضف الأذونات التالية داخل تاج `<manifest>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- أذونات البلوتوث (Bluetooth Permissions) -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
                     android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
    
    <!-- أذونات الموقع (Location Permissions) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- أذونات الإنترنت (Internet Permissions) -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- أذونات التخزين (Storage Permissions) - اختياري -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- ميزات البلوتوث المطلوبة -->
    <uses-feature android:name="android.hardware.bluetooth" android:required="false" />
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />
    
    <application
        ...
    </application>
</manifest>
```

### 2. تحديث `android/app/build.gradle`

تأكد من أن `minSdkVersion` مناسب:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // على الأقل 21 للبلوتوث
        targetSdkVersion 33
        compileSdkVersion 33
    }
}
```

---

## 🍎 أذونات iOS

### 1. ملف `ios/Runner/Info.plist`

أضف المفاتيح التالية داخل `<dict>`:

```xml
<dict>
    <!-- وصف استخدام البلوتوث -->
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>يحتاج التطبيق للبلوتوث للاتصال بالخوذة الذكية</string>
    
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>يحتاج التطبيق للبلوتوث للاتصال بالخوذة الذكية</string>
    
    <!-- وصف استخدام الموقع -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>يحتاج التطبيق للموقع لعرض موقعك على الخريطة</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>يحتاج التطبيق للموقع لتتبع موقعك أثناء القيادة</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>يحتاج التطبيق للموقع لتتبع موقعك وإرسال تنبيهات الطوارئ</string>
</dict>
```

### 2. تحديث `ios/Podfile`

تأكد من الإصدار المناسب:

```ruby
platform :ios, '12.0'  # على الأقل 12.0
```

---

## 🔧 المكتبات المطلوبة في `pubspec.yaml`

تأكد من وجود هذه المكتبات:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # البلوتوث
  flutter_blue_plus: ^1.32.0
  
  # الأذونات
  permission_handler: ^11.0.1
  
  # الخرائط
  google_maps_flutter: ^2.5.0
  google_maps_flutter_web: ^0.5.4
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
```

---

## ✅ كيفية طلب الأذونات في الكود

التطبيق يطلب الأذونات تلقائياً عند بدء التشغيل من خلال `BluetoothProvider`:

```dart
// في lib/providers/bluetooth_provider.dart
Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    // طلب أذونات البلوتوث والموقع
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  } else if (Platform.isIOS) {
    // طلب أذونات البلوتوث
    await Permission.bluetooth.request();
    await Permission.location.request();
  }
}
```

---

## 🧪 اختبار الأذونات

### على أندرويد:

1. افتح التطبيق لأول مرة
2. سيظهر طلب أذونات البلوتوث - اضغط "السماح"
3. سيظهر طلب أذونات الموقع - اضغط "السماح"
4. تحقق من الإعدادات: Settings > Apps > SSH-APP > Permissions

### على iOS:

1. افتح التطبيق لأول مرة
2. سيظهر طلب البلوتوث - اضغط "OK"
3. سيظهر طلب الموقع - اختر "Allow While Using App"
4. تحقق من الإعدادات: Settings > SSH-APP > Location/Bluetooth

---

## 🔍 حل المشاكل الشائعة

### المشكلة: البلوتوث لا يعمل على أندرويد 12+

**الحل:**
- تأكد من إضافة `BLUETOOTH_SCAN` و `BLUETOOTH_CONNECT`
- تأكد من `targetSdkVersion` هو 31 أو أعلى

### المشكلة: الموقع لا يظهر

**الحل:**
- تأكد من تفعيل GPS على الجهاز
- تأكد من منح أذونات الموقع للتطبيق
- تأكد من إضافة Google Maps API Key

### المشكلة: التطبيق يتوقف عند طلب الأذونات

**الحل:**
- تأكد من إضافة جميع الأذونات في `AndroidManifest.xml`
- تأكد من إضافة الأوصاف في `Info.plist` لـ iOS
- نظف المشروع: `flutter clean && flutter pub get`

---

## 📝 ملاحظات مهمة

1. **أندرويد 12 وما فوق**: يتطلب أذونات بلوتوث جديدة (`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`)

2. **الموقع للبلوتوث**: على أندرويد، البلوتوث يحتاج أذونات الموقع للعمل

3. **الويب**: الأذونات تُطلب تلقائياً من المتصفح

4. **الإنتاج**: قبل النشر، راجع جميع الأذونات وأزل غير المستخدمة

---

## 🚀 خطوات سريعة للبدء

```bash
# 1. نظف المشروع
flutter clean

# 2. احصل على المكتبات
flutter pub get

# 3. للأندرويد
flutter run -d android

# 4. لـ iOS
cd ios && pod install && cd ..
flutter run -d ios

# 5. للويب
flutter run -d chrome
```

---

## 📞 الدعم

إذا واجهت مشاكل في الأذونات:
1. تحقق من ملفات `AndroidManifest.xml` و `Info.plist`
2. تأكد من تحديث المكتبات: `flutter pub upgrade`
3. جرب على جهاز حقيقي (ليس محاكي)
4. راجع سجلات الأخطاء: `flutter logs`
