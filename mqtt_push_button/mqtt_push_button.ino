#include <Wire.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h> // https://github.com/knolleary/pubsubclient/

char *wifi_ssid = "wifi ssid";
char *wifi_password = "wifi password";

char *mqtt_server    = "mqtt.example.com";
int  mqtt_port      = 1883;
char *mqtt_username = "username";
char *mqtt_password = "password";
char *mqtt_topic    = "topic";

#define PIN_BUTTON 12

WiFiClient wifi_client;
PubSubClient mqtt_client(mqtt_server, mqtt_port, mqtt_sub_callback, wifi_client);

void setup() {
  pinMode(PIN_BUTTON, INPUT);
  
  Wire.begin(5, 4);
  aqm0802_init();

  aqm0802_print("MQTT Push Button");
  delay(2000);

  WiFi.begin(wifi_ssid, wifi_password);
  int wifi_count = 0;
  while (WiFi.status() != WL_CONNECTED) {
    if (wifi_count % 2 == 0) aqm0802_print("WIFI    conn... ");
    else                     aqm0802_print("WIFI    conn..  ");
    wifi_count ++;
    delay(500);
  }

  aqm0802_print("MQTT    conn... ");
  delay(1000);

  if (mqtt_client.connect("client_id", mqtt_username, mqtt_password) == false) {
    aqm0802_print("conn failed...  ");
    delay(3000);
    reboot();
  }
  aqm0802_print("connected!      ");
  delay(500);
}

bool flag = false;

void loop() {
  // for MQTT
  if (!mqtt_client.connected()) {
    reboot();
  }
  mqtt_client.loop();

  // something to do here...
  if (digitalRead(PIN_BUTTON) == LOW && flag == false) {
    aqm0802_print("publish!        ");
    mqtt_client.publish(mqtt_topic, "press_button");
    flag = true;
    delay(1000);
    aqm0802_print("waiting...      ");
  }
  else {
    flag = false;
    if ((millis()/500) % 2 == 1) {     
      aqm0802_print("press   button..");
    }
    else {
      aqm0802_print("press   button. ");
    }
  }
}

void mqtt_sub_callback(char* topic, byte* payload, unsigned int length) {
  aqm0802_print((char*)payload, length);
}

// ESP8266 special
void reboot() {
  delay(1000);
  ESP.restart();
  while (true) {};
}
