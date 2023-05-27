import pyglet
import math

import color_utils
import configs

# Physics values
SPIN_SPEED = 0.04
CONSTANT_FRICTION = 0.004
LINEAR_FRICTION = 0.003

# Wheel shape values
Y_OFFSET = -100
INNER_RADIUS = 500
OUTER_RADIUS = 900
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
                color=color_utils.color_phase(start_angle),
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

        self.arrow_batch = pyglet.shapes.Batch()

        self.triangle1 = pyglet.shapes.Triangle(
            window_size[0] / 2 - 43, OUTER_RADIUS + Y_OFFSET + 22, 
            window_size[0] / 2 + 43, OUTER_RADIUS + Y_OFFSET + 22, 
            window_size[0] / 2, OUTER_RADIUS + Y_OFFSET - 43,
            color=(0, 0, 0, 255),
            batch=self.arrow_batch
        )
        self.triangle2 = pyglet.shapes.Triangle(
            window_size[0] / 2 - 40, OUTER_RADIUS + Y_OFFSET + 20, 
            window_size[0] / 2 + 40, OUTER_RADIUS + Y_OFFSET + 20, 
            window_size[0] / 2, OUTER_RADIUS + Y_OFFSET - 40,
            color=(255, 30, 30, 255),
            batch=self.arrow_batch
        )

        self.wheel_velocity = 0
        self.wheel_position = 0
        self.prev_segment = 0

    def on_draw(self):
        self.wheel_batch.draw()
        self.background_circle.draw()
        for sector, sprite in self.arcs:
            sprite.x = math.cos(sector.start_angle + self.angle_offset) * MID_RADIUS + self.window_size[0] / 2
            sprite.y = math.sin(sector.start_angle + self.angle_offset) * MID_RADIUS + Y_OFFSET
            sprite.rotation = 90 - math.degrees(sector.start_angle + self.angle_offset)
            sprite.draw()
        
        self.arrow_batch.draw()
        
    def on_click(self, x, y, button):
        self.spin()
    
    def spin(self):
        self.wheel_velocity = SPIN_SPEED

    def on_update(self, deltaTime):
        self.wheel_velocity -= (LINEAR_FRICTION * self.wheel_velocity + CONSTANT_FRICTION) * deltaTime

        self.wheel_velocity = max(self.wheel_velocity, 0)
        self.wheel_position += self.wheel_velocity * 2

        for arc in range(len(self.arcs)):
            self.arcs[arc][0].start_angle = self.wheel_position + arc / configs.SEGMENTS * math.tau
        
        current_segment = int(self.wheel_position / math.tau * configs.SEGMENTS + 0.5)
        if (current_segment != self.prev_segment):
            audio = pyglet.resource.media('sounds/click4.wav')
            audio.play()

        self.prev_segment = current_segment
        

            
