import serial
from sys import platform

BAUD_RATE = 115_200

DEV_FILE = '/dev/feather'

if platform == "darwin":
    # running on macOS. to test on Mac
    DEV_FILE = '/dev/tty.usbmodem1101'


class Input:
    def __init__(self, on_trigger):
        self.ser = serial.Serial(DEV_FILE, BAUD_RATE, timeout=0)
        self.on_trigger = on_trigger

    def update(self):
        data = self.ser.read(self.ser.in_waiting)
        if len(data) > 0:
            print(data, data[-1], len(data))
        if len(data) > 0 and data[-1] == 0x10:
            self.on_trigger()
