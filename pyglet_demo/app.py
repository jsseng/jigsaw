import pyglet
import math

import color_utils
import configs

Y_OFFSET = -100
INNER_RADIUS = 300
OUTER_RADIUS = 600
MID_RADIUS = (INNER_RADIUS + OUTER_RADIUS) / 2

class App:
    def __init__(self, window_size: tuple[int, int]):
        self.wheel_batch = pyglet.graphics.Batch()
        self.window_size = window_size

        image = pyglet.resource.image('images/cplogo.png')
        image.anchor_x = image.width / 2
        image.anchor_y = image.height / 2

        # Generate circle arcs (pyglet sectors).
        angle = math.tau / configs.SEGMENTS
        self.angle_offset = angle / 2
        self.arcs = []
        for i in range(configs.SEGMENTS):
            start_angle = i / configs.SEGMENTS * math.tau

            sector = pyglet.shapes.Sector(
                window_size[0] / 2,
                Y_OFFSET,
                OUTER_RADIUS,
                angle=angle,
                start_angle=start_angle,
                color=color_utils.random_color(),
                batch=self.wheel_batch
            )

            sprite = pyglet.sprite.Sprite(image)
            sprite.scale = 0.15

            self.arcs.append((
                sector,
                sprite
            ))

        # Create center circle cutout.
        self.background_circle = pyglet.shapes.Circle(window_size[0] / 2, Y_OFFSET, INNER_RADIUS, color=configs.BACKGROUND_COLOR)

    def on_draw(self):
        self.wheel_batch.draw()
        self.background_circle.draw()
        for sector, sprite in self.arcs:
            sprite.x = math.cos(sector.start_angle + self.angle_offset) * MID_RADIUS + self.window_size[0] / 2
            sprite.y = math.sin(sector.start_angle + self.angle_offset) * MID_RADIUS + Y_OFFSET
            sprite.rotation = 90 - math.degrees(sector.start_angle + self.angle_offset)
            sprite.draw()

    def on_update(self, deltaTime):
        for arc in self.arcs:
            arc[0].start_angle += deltaTime
            
