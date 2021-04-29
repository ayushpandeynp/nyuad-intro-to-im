const int switches[] = {A0, A1, A2, A3};
const int potentiometer = A4;
const int LDR = A5;

int pressed;

void setup() {
  for (int s : switches) {
    pinMode(s, INPUT);
  }

  pinMode(potentiometer, INPUT);
  pinMode(LDR, INPUT);

  Serial.begin(9600);
}

void loop() {
  pressed = -1;
  for (int i = 0; i < sizeof(switches) / sizeof(int); i++) {
    if (digitalRead(switches[i]) == HIGH) {
      pressed = i;
    }
  }
  
  int ldrValue = analogRead(LDR);

  int limit = 14;
  String type;

  if (ldrValue > 600) {
    type = "NORMAL";
  } else {
    type = "SHARP";
    limit = 9;
  }

  String potValue = (String) constrain(map(analogRead(potentiometer), 0, 1023, 3, limit), 3, limit);
  Serial.println(potValue + "," + String(pressed) + "," + type);
}
