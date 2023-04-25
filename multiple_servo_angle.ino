#include <Servo.h>
Servo myServo1;
Servo myServo2;
Servo myServo3;
int pos = 0;

void setup()

{

  Serial.begin(9600);
  while (!Serial);
  Serial.println("-------------------------");
  Serial.println("ARos is loading....");
  delay(1000);
  Serial.println("ARos loaded succesfully");
  Serial.println("-------------------------");
  myServo1.attach(9);
  myServo2.attach(10);
  myServo3.attach(11);
  Serial.println("calibrating servo...");
  for (pos = 0; pos <= 180; pos += 1)
    myServo1.write(0);
    myServo2.write(0);
    myServo3.write(0);
  delay(1000);
  myServo1.write(180);
  myServo2.write(180);
  myServo3.write(180);
  delay(1000);
  myServo1.write(90);
  myServo2.write(90);
  myServo3.write(90);
  delay(1000);
  Serial.println("servo calibrated");
  Serial.println("-------------------------");
  Serial.println("Comand input online, write command to perform action");
  Serial.println("-------------------------");

}

void loop() {

  for (pos = 0; pos <= 180; pos += 1)
    if (Serial.available())


    {
      Serial.print("Enter servo number: ")
      int servoNum = Serial.parseInt();
      Serial.print("Enter servo angle: ")
      int state = Serial.parseInt();
      Servo servoSelect;

      switch (servoNum) {
        case 1:
          servoSelect = myServo1;
          break;
        case 2:
          servoSelect = myServo2;
          break;
        case 3:
          servoSelect = myServo3;
          break;
        default:
          Serial.println("Invalid servo number");
          Serial.read();
          Serial.read();          
      }

      if (state < 10)

      {
        Serial.print(">");
        Serial.println(state);
        Serial.println("Cannot execute command, too low number");
        Serial.read();
        Serial.read();

      }

      if (state >= 10 && state < 170)
      {
        Serial.print(">");
        Serial.println(state);
        Serial.print("turning servo to ");
        Serial.print(state);
        Serial.println(" degrees");
        servoSelect.write(state);
        Serial.read();
        Serial.read();

      }

    }
}