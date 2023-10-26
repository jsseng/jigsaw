import serial

BAUD_RATE = 115_200


class Input:
    def __init__(self, dev_file, on_trigger):
        self.ser = serial.Serial(dev_file, BAUD_RATE, timeout=0)
        self.on_trigger = on_trigger

    def update(self):
        data = self.ser.read(self.ser.in_waiting)
        if len(data) > 0:
            print(data, data[-1], len(data))
        if len(data) > 0 and data[-1] == 0x10:
            self.on_trigger()
