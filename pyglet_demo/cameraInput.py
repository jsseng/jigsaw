import time

class Input:
    def __init__(self, on_trigger):
        self.on_trigger = on_trigger

    def update(self):
        threshold = 0

        # Do some kind of camera logic here

        if threshold > 1:
            self.on_trigger()