import math
import random

PHASE_1 = math.tau / 3
PHASE_2 = math.tau / 1.5

def color_phase(theta):
    return (
        int((1 + math.sin(theta)) * 127.5),
        int((1 + math.sin(theta + PHASE_1)) * 127.5),
        int((1 + math.sin(theta + PHASE_2)) * 127.5)
    )

def random_color():
    return color_phase(random.random() * math.tau)