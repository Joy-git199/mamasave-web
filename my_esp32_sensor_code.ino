#include <Wire.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h> // Make sure this library is installed (e.g., v6.x)
#include <OneWire.h>
#include <DallasTemperature.h>
#include "MAX30100_PulseOximeter.h" // The library that worked in isolation for MAX30100
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <freertos/semphr.h> // For mutex protection

// === Wi-Fi Configuration ===
const char* ssid = "Joel";
const char* password = "000qwerty";

// === Backend Configuration ===
const char* backend_host = "192.168.43.238"; // Your PC's NEW IP address
const int backend_port = 5000;
const char* sensorDataEndpoint = "/api/data/sensor/"; // Endpoint for sensor data
const char* SENSOR_FIREBASE_UID = "esp32_sensor_001";

// === Sensor Pin Definitions ===
PulseOximeter pox;

// DS18B20 Temperature Sensor
#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// DF9-40 Pressure Sensor
#define PRESSURE_PIN 34
#define PRESSURE_VCC 3.3

// === Timing Variables ===
uint32_t tsLastTemp = 0;
const uint32_t TEMP_READ_INTERVAL = 3000;
uint32_t tsLastPressure = 0;
const uint32_t PRESSURE_READ_INTERVAL = 1500;
uint32_t lastSendTime = 0;
const uint32_t SEND_TO_BACKEND_INTERVAL = 20000; // 20 seconds

// === Global Sensor Data Storage with Mutex Protection ===
SemaphoreHandle_t sensorDataMutex; // Mutex to protect shared sensor data
volatile float gHeartRate = 0.0;
volatile float gSpO2 = 0.0;
volatile bool gValidHeartReading = false; 
float gTemperatureC = 0.0; // Initialize to 0.0 for consistent float type
float gPressure_kPa = 0.0;
float gPressure_Voltage = 0.0;

// === Function Prototypes ===
void onBeatDetected();
void connectToWiFi();
void sendSensorDataToBackend();
void max30100Task(void* pvParameters);

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("=== MamaSave ESP32 Sensor Hub - Final Attempt ===");

  // Create mutex for sensor data protection
  sensorDataMutex = xSemaphoreCreateMutex();
  if (sensorDataMutex == NULL) {
    Serial.println("Failed to create mutex!");
    while(1); // Halt if mutex creation fails
  }

  // Initialize I2C with default settings for MAX30100 (from previous working isolation test)
  Wire.begin(21, 22, 100000); // Reverted to 100kHz, as 400kHz might be too fast for some modules/libraries

  // Initialize MAX30100 with enhanced error handling
  Serial.print("Initializing MAX30100...");
  delay(500); // Give sensor time to stabilize
  
  int retryCount = 0;
  while (!pox.begin() && retryCount < 3) {
    Serial.print(".");
    delay(1000);
    retryCount++;
  }
  
  if (retryCount >= 3) {
    Serial.println(" FAILED! Check wiring/power.");
    while (1); // Halt if sensor fails to initialize
  }
  
  Serial.println(" OK!");
  pox.setOnBeatDetectedCallback(onBeatDetected);
  
  // Initialize DS18B20
  Serial.print("Initializing DS18B20...");
  sensors.begin();
  sensors.setResolution(10); // Reduce resolution for faster readings
  if (sensors.getDeviceCount() == 0) {
    Serial.println(" No DS18B20 found, temperature will default to 0.0.");
    gTemperatureC = 0.0; // Set default if no sensor found
  } else {
    Serial.println(" OK!");
  }

  // Initialize Pressure Sensor
  pinMode(PRESSURE_PIN, INPUT);
  Serial.printf("DF9-40 Pressure Sensor on GPIO %d configured.\n", PRESSURE_PIN);

  // Create MAX30100 task with higher priority and larger stack
  xTaskCreatePinnedToCore(
    max30100Task,
    "MAX30100Task",
    2048,        // Reverted stack size to 2KB, as it was sufficient for this library's task
    NULL,
    3,           // Higher priority (3)
    NULL,
    1            // Core 1
  );

  // Initial Wi-Fi connection
  connectToWiFi();

  Serial.println("Setup complete. Tasks started.");
  delay(2000); // Let tasks initialize
}

void loop() {
  // Ensure Wi-Fi stays connected
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Wi-Fi disconnected. Reconnecting...");
    connectToWiFi();
  }

  // Read Temperature periodically
  if (millis() - tsLastTemp > TEMP_READ_INTERVAL) {
    sensors.requestTemperatures();
    delay(100); // Give time for conversion
    float temp = sensors.getTempCByIndex(0);
    
    if (temp != DEVICE_DISCONNECTED_C && temp > -50.0 && temp < 100.0) { // Check for reasonable range
      gTemperatureC = temp;
      Serial.printf("Temperature: %.2f °C\n", gTemperatureC);
    } else {
      Serial.println("DS18B20 reading invalid or out of range, keeping previous value or 0.0.");
      // If the reading is invalid, we will keep the previous value or let it be 0.0 if not updated.
      // The backend sending logic will handle sending 0.0 if it's not a valid temp.
    }
    tsLastTemp = millis();
  }

  // Read Pressure periodically
  if (millis() - tsLastPressure > PRESSURE_READ_INTERVAL) {
    // Take multiple readings and average for stability
    float voltageSum = 0;
    for (int i = 0; i < 5; i++) {
      voltageSum += (analogRead(PRESSURE_PIN) / 4095.0) * PRESSURE_VCC;
      delay(5); // Small delay between analog reads
    }
    float voltage = voltageSum / 5.0;
    
    float pressure = (voltage - 0.5) * 10.0;
    gPressure_kPa = (pressure < 0 ? 0.0 : pressure); // Ensure float 0.0
    gPressure_Voltage = voltage;
    Serial.printf("Pressure: %.2f kPa (%.2f V)\n", gPressure_kPa, gPressure_Voltage);
    tsLastPressure = millis();
  }

  // Print sensor status (including HR/SpO2 from the task)
  static uint32_t tsLastPrint = 0;
  if (millis() - tsLastPrint > 2000) { // Print every 2 seconds
    // Acquire mutex before reading shared global variables
    if (xSemaphoreTake(sensorDataMutex, pdMS_TO_TICKS(100)) == pdTRUE) {
      Serial.printf("HR: %.1f BPM | SpO2: %.1f%% | Valid: %s | Temp: %.1f°C | Press: %.1f kPa\n", 
                     gHeartRate, gSpO2, gValidHeartReading ? "YES" : "NO", gTemperatureC, gPressure_kPa);
      xSemaphoreGive(sensorDataMutex); // Release mutex
    } else {
      Serial.println("Failed to acquire mutex for print.");
    }
    tsLastPrint = millis();
  }

  // Send data to backend periodically
  if (millis() - lastSendTime > SEND_TO_BACKEND_INTERVAL) {
    sendSensorDataToBackend();
    lastSendTime = millis();
  }
  
  delay(100); // Main loop delay, allows other tasks to run
}

// MAX30100 task (runs on Core 1)
void max30100Task(void* pvParameters) {
  (void) pvParameters; // Suppress unused parameter warning
  Serial.println("MAX30100 task started on Core 1");
  
  uint32_t stableReadingCount = 0;
  float lastHR = 0.0, lastSpO2 = 0.0;

  while (true) {
    pox.update(); // Process sensor data using the MAX30100_PulseOximeter library
    
    float currentHR = pox.getHeartRate();
    float currentSpO2 = pox.getSpO2();
    
    // Validate readings - must be reasonable values
    bool validReading = (currentHR > 40.0 && currentHR < 200.0 && 
                         currentSpO2 > 70.0 && currentSpO2 <= 100.0);
    
    if (validReading) {
      // Check for stability (similar to previous reading)
      if (abs(currentHR - lastHR) < 5.0 && abs(currentSpO2 - lastSpO2) < 2.0) { // Tighter stability check
        stableReadingCount++;
      } else {
        stableReadingCount = 0;
      }
      
      // Update global values only if we have stable readings
      if (stableReadingCount >= 5) { // Require more stable readings before updating globals
        // Acquire mutex before writing to shared global variables
        if (xSemaphoreTake(sensorDataMutex, pdMS_TO_TICKS(10)) == pdTRUE) {
          gHeartRate = currentHR;
          gSpO2 = currentSpO2;
          gValidHeartReading = true; // Mark as valid
          xSemaphoreGive(sensorDataMutex); // Release mutex
        }
      }
      
      lastHR = currentHR;
      lastSpO2 = currentSpO2;
    } else {
      stableReadingCount = 0;
      // If reading is not valid, reset globals to 0.0 and mark as invalid
      if (xSemaphoreTake(sensorDataMutex, pdMS_TO_TICKS(10)) == pdTRUE) {
        gHeartRate = 0.0;
        gSpO2 = 0.0;
        gValidHeartReading = false;
        xSemaphoreGive(sensorDataMutex);
      }
    }
    
    vTaskDelay(pdMS_TO_TICKS(10)); // Yield CPU for ~10ms, crucial for sensor processing
  }
}

// Beat detection callback for MAX30100_PulseOximeter library
void onBeatDetected() {
  Serial.print("♥"); // Simple beat indicator
}

// Wi-Fi connection helper
void connectToWiFi() {
  Serial.printf("Connecting to Wi-Fi: %s\n", ssid);
  WiFi.mode(WIFI_STA); // Set Wi-Fi to station mode
  WiFi.begin(ssid, password);
  
  int retry = 0;
  while (WiFi.status() != WL_CONNECTED && retry < 30) {
    delay(500);
    Serial.print(".");
    retry++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("\nWi-Fi connected, IP=%s\n", WiFi.localIP().toString().c_str());
  } else {
    Serial.println("\nWi-Fi connection failed.");
  }
}

// Send sensor data to backend
void sendSensorDataToBackend() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Cannot send data: Wi-Fi not connected.");
    return;
  }

  HTTPClient http;
  http.setTimeout(10000); // 10 second timeout for HTTP request
  
  String serverPath = String("http://") + backend_host + ":" + backend_port + sensorDataEndpoint + SENSOR_FIREBASE_UID;

  // Get ISO timestamp (simple HH:MM:SS.mmm using millis())
  char isoTimestamp[25];
  sprintf(isoTimestamp, "2025-07-29T%02d:%02d:%02d.%03dZ",
          (millis() / 3600000) % 24, 
          (millis() / 60000) % 60,   
          (millis() / 1000) % 60,    
          (int)(millis() % 1000));

  // Acquire mutex before reading shared global variables for sending
  if (xSemaphoreTake(sensorDataMutex, pdMS_TO_TICKS(200)) == pdTRUE) { // Increased timeout for mutex acquisition
    // --- Create SINGLE Combined JSON Payload ---
    StaticJsonDocument<512> doc; // Increased size to accommodate all data
    doc["heartRate"] = gHeartRate;
    doc["spo2"] = gSpO2;
    doc["temperature"] = gTemperatureC;
    doc["pressure_kPa"] = gPressure_kPa;
    doc["pressure_voltage"] = gPressure_Voltage;
    doc["timestamp"] = isoTimestamp; // Add the timestamp to the combined object
    doc["uid"] = SENSOR_FIREBASE_UID; // Add the UID to the combined object

    String jsonPayload;
    serializeJson(doc, jsonPayload);
    
    Serial.print("Sending COMBINED Sensor Data: ");
    serializeJsonPretty(doc, Serial); // Print pretty JSON to serial
    Serial.println();
    
    http.begin(serverPath);
    http.addHeader("Content-Type", "application/json");
    
    int httpResponseCode = http.POST(jsonPayload);
    
    if (httpResponseCode > 0) {
      Serial.printf("HTTP Response code: %d\n", httpResponseCode);
      String responsePayload = http.getString();
      Serial.println(responsePayload);
    } else {
      Serial.printf("HTTP Error: %s\n", http.errorToString(httpResponseCode).c_str());
    }
    http.end(); // End connection for this request

    xSemaphoreGive(sensorDataMutex); // Release mutex after the single send
  } else {
    Serial.println("Failed to acquire mutex for sending data. Skipping send.");
    return; // Skip sending if mutex cannot be acquired
  }
}
