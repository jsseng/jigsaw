#%% import libraries
from time import sleep
from pyfirmata import Arduino, SERVO

# set up arduino board
port = "/dev/cu.usbmodem14301" #change as needed
servo1 = 9
servo1 = int(servo1)
servo2 = 10
servo2 = int(servo2)
servo3 = 11
servo3 = int(servo3)

board = Arduino(port)

board.digital[servo1].mode = SERVO
board.digital[servo2].mode = SERVO
board.digital[servo3].mode = SERVO

def turnServo(pin, angle):
    board.digital[pin].write(angle)
    sleep(0.015)

#%% while loop 
while True:
    servoNum = int(input("Enter servo number (1, 2, 3): "))
    if servoNum > 3 or servoNum < 1:
        print("Invalid servo number")
        continue
    pin = servoNum + 8
    angle = int(input("Enter desired angle: "))
    if angle < 10 or angle > 170:
        print("Invalid angle")
        continue
    print(f'Turning servo {servoNum} to angle {angle}')
    turnServo(pin, angle)
