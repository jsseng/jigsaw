import math
import random

PHASE_1 = math.tau / 3
PHASE_2 = math.tau / 1.5

def color_phase(theta):
    h = theta / math.tau
    i = int(h * 6)
    f = h * 6 - i

    if i % 6 == 0:
        return (1, f, 0)
    if i % 6 == 1:
        return (1 - f, 1, 0)
    if i % 6 == 2:
        return (0, 1, f)
    if i % 6 == 3:
        return (0, 1 - f, 1)
    if i % 6 == 4:
        return (f, 0, 1 - f)
    else:
        return (1, 0, 1 - f)

def color_phase_int(theta):
    color = color_phase(theta)
    return tuple(map(lambda v: int(v * 255), color))

def random_color():
    return color_phase(random.random() * math.tau)