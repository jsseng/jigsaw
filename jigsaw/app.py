import pyglet
import math
import os
import pathlib


class App:

    def __init__(self, x_window_size: int, y_window_size: int):
        self.x_window_size = x_window_size
        self.y_window_size = y_window_size
