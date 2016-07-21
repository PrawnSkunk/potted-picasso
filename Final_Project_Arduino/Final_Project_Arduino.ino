
int tempVal = 0.0;
int lightVal = 0;
int moistVal = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(A0, INPUT);
  pinMode(A2, INPUT);
  pinMode(A4, INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  tempVal = analogRead(A0)/4;
  tempVal = map(tempVal, 93, 106, 0, 255);
  lightVal = analogRead(A2)/4;
  moistVal = analogRead(A4)/4;

  Serial.print("a");
  Serial.print(tempVal);
  Serial.print("a");
  Serial.println();

  Serial.print("b");
  Serial.print(lightVal);
  Serial.print("b");
  Serial.println();

  Serial.print("c");
  Serial.print(moistVal);
  Serial.print("c");
  Serial.println();

  Serial.print("&");
  Serial.println();
  delay(100);
}

