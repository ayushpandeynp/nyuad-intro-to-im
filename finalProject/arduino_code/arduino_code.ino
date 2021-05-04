/*
AYUSH PANDEY
INTRO TO IM

ARDUINO CODE for FINAL PROJECT
MINI MIDI KEYBOARD + LOOPSTATION
SPRING 2021
*/

const int switches[] = {A0, A1, A2, A3};	// switch pins
const int potentiometer = A4;			// potentiometer pin
const int LDR = A5;				// LDR pin

int pressed;					// to check which switch is pressed [loop()]

void setup() {
  // pin modes
  for (int s : switches) {
    pinMode(s, INPUT);
  }

  pinMode(potentiometer, INPUT);
  pinMode(LDR, INPUT);
  
  // for serial communication
  Serial.begin(9600);
}

void loop() {
  pressed = -1;
  
  // getting which switch is pressed
  for (int i = 0; i < sizeof(switches) / sizeof(int); i++) {
    if (digitalRead(switches[i]) == HIGH) {
      pressed = i;
    }
  }
  
  // checking the LDR sensor value
  int ldrValue = analogRead(LDR);

  int limit = 14;	// limit variable for map() and constrain() used to get value from potentiometer.
  String type;

  // if there's more light, type = "NORMAL" else type = "SHARP"
  if (ldrValue > 600) {
    type = "NORMAL";
  } else {
    type = "SHARP";
    limit = 9;
  }
  
  // potentiometer value
  String potValue = (String) constrain(map(analogRead(potentiometer), 0, 1023, 3, limit), 3, limit);
  
  // printing data to serial
  Serial.println(potValue + "," + String(pressed) + "," + type);
}
