#include "HX711.h"
#include <SoftwareSerial.h>
 
SoftwareSerial esp8266(2,3); // make RX Arduino line is pin 2, make TX Arduino line is pin 3.
                             // you need to connect the TX line from the esp to the Arduino's pin 2
                             // RX line from the esp to the Arduino's pin 3
//HX711 cell(3, 2);
HX711 cell(5, 4);

String msg = "";

bool calibrated;
int calibration_counts = 500;
int ignore_counts = 100;

#define BUFFER_SIZE 4

long T;
float V; 
long val;
long long raw_val = 0;
long long count = 0;
long zero = 0; 
long bufferT[BUFFER_SIZE];
float bufferV[BUFFER_SIZE];
int bufferPointer = 0;


void setup() {
  Serial.begin(115200);
  esp8266.begin(74880); // Change baud rate according to your ESP, 

  calibrated = false;
}



void loop() {

  if (!calibrated) {
    Serial.println("C");

    count = count + 1;

    if (count > ignore_counts)
      raw_val += cell.read();

    if (count==calibration_counts) {
      zero = raw_val/(calibration_counts - ignore_counts);
      calibrated = true;
    }
    
  } else {
  
    val = cell.read() - zero;

    V = 55.52*(val/67696.0);
    T = millis();

    if (bufferPointer<BUFFER_SIZE) {
      bufferV[bufferPointer] = V;
      bufferT[bufferPointer++] = T;
    }

/*
    Serial.println("V");
    Serial.println(V,4);
    Serial.println(T);
    Serial.println("E");
*/

    esp8266.println("V");
    esp8266.println(V,4);
    esp8266.println(T);
    esp8266.println("E");

/*
    if(esp8266.available()) {
      msg = "";
      while(esp8266.available()) {
        msg += (char)esp8266.read();
      } 
    
      for (int i=0;i<bufferPointer;i++) {
        esp8266.println(bufferV[i], 4);
        esp8266.println(bufferT[i]);
      }

      bufferPointer = 0;

    }

*/
    
  }  
}
