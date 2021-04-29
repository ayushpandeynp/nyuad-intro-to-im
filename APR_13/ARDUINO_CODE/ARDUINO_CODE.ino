/*
   INTRO TO IM
   NYU ABU DHABI, SPRING 2021

   AYUSH PANDEY
   TETRIS RUSH WITH ARDUINO AND PROCESSING
   APR 13, 2021
*/

#define leftSwitch A0     // switch to move LEFT, (BLUE) pin
#define rightSwitch A1    // switch to move RIGHT, (YELLOW) pin

void setup() {
  // setting pin mode of switches as INPUT
  pinMode(leftSwitch, INPUT);
  pinMode(rightSwitch, INPUT);

  Serial.begin(9600);
}

void loop() {
  if (digitalRead(leftSwitch) == HIGH) {    // if left switch is pressed
    Serial.println("LEFT");                 // sending data as LEFT
    delay(200);
  } else if (digitalRead(rightSwitch) == HIGH) {  // if right switch is pressed
    Serial.println("RIGHT");                // sending data as RIGHT
    delay(200);
  }
}
