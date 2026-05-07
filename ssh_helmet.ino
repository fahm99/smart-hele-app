/*
 * ==================== كود الخوذة الذكية SSH ====================
 * 
 * قبل ما ترفع الكود على ESP32، لازم تنزل المكتبات التالية:
 * 
 * 1. مكتبات البلوتوث (BLE) - موجودة مع ESP32 بشكل افتراضي
 *    - لا تحتاج تنزيل شي، جاهزة مع بورد ESP32
 * 
 * 2. مكتبة ArduinoJson - لإرسال واستقبال البيانات بصيغة JSON
 *    طريقة التنزيل:
 *    - روح على: Sketch > Include Library > Manage Libraries
 *    - دور على: ArduinoJson
 *    - نزل الإصدار 6.x (مو 7)
 *    - أو من الرابط: https://github.com/bblanchon/ArduinoJson
 * 
 * 3. مكتبة TinyGPS++ - لقراءة بيانات GPS
 *    طريقة التنزيل:
 *    - Sketch > Include Library > Manage Libraries
 *    - دور على: TinyGPSPlus
 *    - اضغط Install
 *    - أو من الرابط: https://github.com/mikalhart/TinyGPSPlus
 * 
 * 4. مكتبة DHT - لحساس الحرارة والرطوبة DHT22
 *    طريقة التنزيل:
 *    - Sketch > Include Library > Manage Libraries
 *    - دور على: DHT sensor library by Adafruit
 *    - اضغط Install
 *    - راح يطلب منك تنزل Adafruit Unified Sensor، وافق عليها
 *    - أو من الرابط: https://github.com/adafruit/DHT-sensor-library
 * 
 * 5. مكتبة MPU6050 - لحساس الحركة والتسارع
 *    طريقة التنزيل:
 *    - Sketch > Include Library > Manage Libraries
 *    - دور على: MPU6050 by Electronic Cats
 *    - اضغط Install
 *    - أو من الرابط: https://github.com/ElectronicCats/mpu6050
 * 
 * 6. مكتبة SparkFun MAX3010x - لحساس نبض القلب MAX30102
 *    طريقة التنزيل:
 *    - Sketch > Include Library > Manage Libraries
 *    - دور على: SparkFun MAX3010x Pulse and Proximity Sensor Library
 *    - اضغط Install
 *    - أو من الرابط: https://github.com/sparkfun/SparkFun_MAX3010x_Sensor_Library
 * 
 * ملاحظات مهمة:
 * - تأكد إن بورد ESP32 منزل عندك في Arduino IDE
 * - لو ما عندك ESP32، روح Tools > Board > Boards Manager
 * - دور على ESP32 ونزله
 * - اختر البورد: ESP32 Dev Module
 * 
 * التوصيلات:
 * - DHT22: Pin 4
 * - GPS: RX=16, TX=17
 * - MPU6050: SDA=21, SCL=22 (I2C)
 * - MAX30102: SDA=21, SCL=22 (I2C - نفس خط MPU6050)
 * - SW420 (حساس الصدمة): Pin 34
 * - البطارية: Pin 35 (ADC)
 */
في مشروع خوذة تستخدم esp32  وترسل بيانات السائق الى الهاتف لماذا لا يظهر البلوتوث او اسم البلوتوث وهذا هو الكود 

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>
#include <ArduinoJson.h>
#include <TinyGPS++.h>
#include <HardwareSerial.h>
#include <DHT.h>
#include <MPU6050.h>
#include <MAX30105.h>
#include <heartRate.h>
#include <spo2_algorithm.h>

// ================= PIN =================
#define DHT_PIN 4
#define DHT_TYPE DHT22
#define SHOCK_PIN 34
#define BATTERY_PIN 35
#define GPS_RX 16
#define GPS_TX 17
#define I2C_SDA 21
#define I2C_SCL 22

// ================= SETTINGS =================
#define SEND_INTERVAL 1000
#define FALL_THRESHOLD_HIGH 2.5
#define FALL_THRESHOLD_LOW 0.3
#define SHOCK_THRESHOLD 500

// ================= BLE =================
#define DEVICE_NAME "SSH-Helmet"
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// ================= OBJECTS =================
BLEServer *server;
BLECharacteristic *characteristic;
bool connected = false;

DHT dht(DHT_PIN, DHT_TYPE);
TinyGPSPlus gps;
HardwareSerial gpsSerial(2);
MPU6050 mpu;
MAX30105 maxSensor;

// ================= HEART =================
uint32_t irBuffer[100], redBuffer[100];
int32_t spo2, heartRate;
int8_t validSPO2, validHeartRate;
int lastHR = 0, lastSpO2 = 0;
bool maxOK = false;

// ================= TIMERS =================
unsigned long lastSend = 0;
unsigned long lastHeart = 0;

// ================= FALL =================
bool fallDetected = false;
unsigned long fallTime = 0;

// ================= BLE CALLBACK =================
class ServerCB: public BLEServerCallbacks {
  void onConnect(BLEServer*) { connected = true; }
  void onDisconnect(BLEServer* s) {
    connected = false;
    delay(300);
    s->startAdvertising();
  }
};

class CharCB: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *c) {
    String cmd = c->getValue().c_str();
    if (cmd == "RESET") ESP.restart();
    if (cmd == "CALIBRATE") {
      mpu.CalibrateAccel(6);
      mpu.CalibrateGyro(6);
    }
  }
};

// ================= SETUP =================
void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin(I2C_SDA, I2C_SCL);
  dht.begin();
  gpsSerial.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);
  
  if (!mpu.initialize()) {
    Serial.println("MPU6050 INIT FAIL!");
  } else {
    Serial.println("MPU6050 OK");
  }

  pinMode(SHOCK_PIN, INPUT);

  initMAX30102();
  initBLE();

  Serial.println("SYSTEM READY");
}

// ================= LOOP =================
void loop() {
  readGPS();
  detectFall();
  updateHeart();

  if (millis() - lastSend >= SEND_INTERVAL) {
    if (connected) sendData();
    lastSend = millis();
  }
}

// ================= INIT =================
void initMAX30102() {
  if (!maxSensor.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("MAX FAIL");
    return;
  }

  maxSensor.setup(60, 4, 2, 100, 411, 4096);
  maxSensor.setPulseAmplitudeGreen(0);
  maxOK = true;

  for (int i = 0; i < 100; i++) {
    while (!maxSensor.available()) maxSensor.check();
    redBuffer[i] = maxSensor.getRed();
    irBuffer[i] = maxSensor.getIR();
    maxSensor.nextSample();
  }
}

void initBLE() {
  // تهيئة البلوتوث مع اسم الجهاز
  BLEDevice::init(DEVICE_NAME);
  
  // زيادة قوة الإشارة لتحسين ظهور الجهاز
  esp_ble_tx_power_set(ESP_BLE_PWR_TYPE_ADV, ESP_PWR_LVL_P9);
  esp_ble_tx_power_set(ESP_BLE_PWR_TYPE_SCAN, ESP_PWR_LVL_P9);

  server = BLEDevice::createServer();
  server->setCallbacks(new ServerCB());

  BLEService *s = server->createService(SERVICE_UUID);

  characteristic = s->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_NOTIFY
  );

  characteristic->setCallbacks(new CharCB());
  characteristic->addDescriptor(new BLE2902());

  s->start();

  // إعداد الإعلان لتحسين ظهور اسم الجهاز
  BLEAdvertising *advertising = BLEDevice::getAdvertising();
  
  // إضافة اسم الخدمة والـ UUIDs للإعلان
  advertising->addServiceUUID(SERVICE_UUID);
  advertising->setMinInterval(0x20);    // 32ms
  advertising->setMaxInterval(0x40);    // 64ms
  advertising->setAppearance(0x0800);   // Generic Wearable
  
  // البدء بالإعلان
  BLEDevice::startAdvertising();
  
  Serial.println("BLE Advertising started with name: " + String(DEVICE_NAME));
}

// ================= FUNCTIONS =================
void readGPS() {
  while (gpsSerial.available()) gps.encode(gpsSerial.read());
}

void detectFall() {
  int16_t ax, ay, az;
  mpu.getAcceleration(&ax, &ay, &az);

  //هنا اهم تصحيح: ax*ax + ay*ay وليس axax + ayay
  float total = sqrt((float)ax*ax + (float)ay*ay + (float)az*az) / 16384.0;

  if (total > FALL_THRESHOLD_HIGH || total < FALL_THRESHOLD_LOW) {
    fallDetected = true;
    fallTime = millis();
  }

  if (fallDetected && millis() - fallTime > 5000) {
    fallDetected = false;
  }
}

void updateHeart() {
  if (!maxOK) return;

  if (millis() - lastHeart > 1000) {
    for (int i = 25; i < 100; i++) {  
      redBuffer[i - 25] = redBuffer[i];  
      irBuffer[i - 25] = irBuffer[i];  
    }  

    for (int i = 75; i < 100; i++) {  
      while (!maxSensor.available()) maxSensor.check();  
      redBuffer[i] = maxSensor.getRed();  
      irBuffer[i] = maxSensor.getIR();  
      maxSensor.nextSample();  
    }  

    maxim_heart_rate_and_oxygen_saturation(  
      irBuffer, 100, redBuffer,  
      &spo2, &validSPO2,  
      &heartRate, &validHeartRate  
    );  

    long ir = maxSensor.getIR();  

    if (ir < 50000) {  
      lastHR = 0;  
      lastSpO2 = 0;  
    } else {  
      lastHR = (validHeartRate && heartRate < 200) ? heartRate : 0;  
      lastSpO2 = (validSPO2 && spo2 <= 100) ? spo2 : 0;  
    }  

    lastHeart = millis();
  }
}

int readBattery() {
  int raw = analogRead(BATTERY_PIN);
  float v = (raw / 4095.0) * 3.3 * 2;
  // هنا  تصحيح: تحويل إلى long قبل map()
  int p = map((long)(v * 100), 300, 420, 0, 100);
  return constrain(p, 0, 100);
}

void sendData() {
  StaticJsonDocument<768> doc; // ✅ زيادة الحجم للأمان

  //هنا في  تصحيح: فحص قراءة DHT
  float t = dht.readTemperature();
  float h = dht.readHumidity();
  doc["temp"] = isnan(t) ? 0 : t;
  doc["hum"] = isnan(h) ? 0 : h;

  doc["heart"] = lastHR;
  doc["spo2"] = lastSpO2;

  int shockVal = analogRead(SHOCK_PIN);
  doc["shock"] = shockVal > SHOCK_THRESHOLD;
  doc["shock_val"] = shockVal;

  doc["fall"] = fallDetected;
  doc["battery"] = readBattery();

  int16_t ax, ay, az, gx, gy, gz;
  mpu.getAcceleration(&ax, &ay, &az);
  mpu.getRotation(&gx, &gy, &gz);

  doc["ax"] = ax / 16384.0;
  doc["ay"] = ay / 16384.0;
  doc["az"] = az / 16384.0;
  doc["gx"] = gx / 131.0;
  doc["gy"] = gy / 131.0;
  doc["gz"] = gz / 131.0;

  if (gps.location.isValid()) {
    doc["lat"] = gps.location.lat();
    doc["lng"] = gps.location.lng();
    doc["speed"] = gps.speed.kmph();
    doc["alt"] = gps.altitude.meters();
  } else {
    doc["lat"] = 0;
    doc["lng"] = 0;
  }

  doc["time"] = millis();

  char buffer[768];
  size_t len = serializeJson(doc, buffer);

  characteristic->setValue((uint8_t*)buffer, len);
  characteristic->notify();

  Serial.println(buffer);
}