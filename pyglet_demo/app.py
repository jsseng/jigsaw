import pyglet
import math
import os
import pathlib

import color_utils
import configs
from typing import Tuple
import random

# Physics values
SPIN_SPEED = 0.04
CONSTANT_FRICTION = 0.004
LINEAR_FRICTION = 0.003

# Wheel shape values
Y_OFFSET = -100
INNER_RADIUS = 500
OUTER_RADIUS = 1100
MID_RADIUS = (INNER_RADIUS + OUTER_RADIUS) / 2


class App:
    def __init__(self, window_size: Tuple[int, int]):
        self.wheel_batch = pyglet.graphics.Batch()
        self.window_size = window_size
        image_files = os.listdir(
            str(pathlib.Path(__file__).parent.absolute().resolve()) + "/images/"
        )

        images = [
            pyglet.resource.image(f"images/{image_file}") for image_file in image_files
        ]

        ordered_images = self.order_images(images)

        # Generate circle arcs (pyglet sectors).
        angle = math.tau / configs.SEGMENTS
        self.angle_offset = angle / 2
        self.arcs = []
        self.audio_file_name = []
        for i in range(configs.SEGMENTS):
            start_angle = i / configs.SEGMENTS * math.tau
            image = ordered_images[i]
            image.anchor_x = image.width / 2
            image.anchor_y = image.height / 2
            sector = pyglet.shapes.Sector(
                window_size[0] / 2,
                Y_OFFSET,
                OUTER_RADIUS,
                angle=angle,
                start_angle=start_angle,
                # color=color_utils.color_phase(start_angle),
                color=self.check_position(image, 0, 0),
                batch=self.wheel_batch,
            )

            sprite = pyglet.sprite.Sprite(image)
            sprite.scale = 0.3

            self.audio_file_name.append(
                f"sounds/{image_files[i].replace('.png', '.wav')}"
            )
            self.arcs.append(
                (
                    sector,
                    sprite,
                )
            )

        # Create center circle cutout.
        self.background_circle = pyglet.shapes.Circle(
            window_size[0] / 2, Y_OFFSET, INNER_RADIUS, color=configs.BACKGROUND_COLOR
        )

        self.arrow_batch = pyglet.shapes.Batch()

        self.triangle1 = pyglet.shapes.Triangle(
            window_size[0] / 2 - 43,
            OUTER_RADIUS + Y_OFFSET + 22,
            window_size[0] / 2 + 43,
            OUTER_RADIUS + Y_OFFSET + 22,
            window_size[0] / 2,
            OUTER_RADIUS + Y_OFFSET - 43,
            color=(0, 0, 0, 255),
            batch=self.arrow_batch,
        )
        self.triangle2 = pyglet.shapes.Triangle(
            window_size[0] / 2 - 40,
            OUTER_RADIUS + Y_OFFSET + 20,
            window_size[0] / 2 + 40,
            OUTER_RADIUS + Y_OFFSET + 20,
            window_size[0] / 2,
            OUTER_RADIUS + Y_OFFSET - 40,
            color=(255, 30, 30, 255),
            batch=self.arrow_batch,
        )

        self.wheel_velocity = 0
        self.wheel_position = 0
        self.prev_segment = 0

        self.audio = pyglet.resource.media("sounds/click4.wav")
        self.player = None
        self.player2 = None

    def check_position(self, image, x, y):
        img_data = image.get_region(x, y, 1, 1).get_image_data()
        width = img_data.width
        data = img_data.get_data("RGB", 3 * width)
        print(data)
        return data[0], data[1], data[2]

    def order_images(self, images):
        image_color_tuples = [
            (image, self.check_position(image, 0, 0)) for image in images
        ]

        ordered_images = [image_color_tuples.pop()[0]]
        while len(image_color_tuples) > 0:
            image = ordered_images[-1]
            color = self.check_position(image, 0, 0)

            max_distance = 0
            min_index = -1
            for i in range(len(image_color_tuples)):
                other_image, other_color = image_color_tuples[i]
                distance = math.sqrt(
                    (color[0] - other_color[0]) ** 2
                    + (color[1] - other_color[1]) ** 2
                    + (color[2] - other_color[2]) ** 2
                )

                if distance > max_distance:
                    min_distance = distance
                    min_index = i

            next_image, next_color = image_color_tuples.pop(min_index)
            ordered_images.append(next_image)

        return ordered_images

    def on_draw(self):
        self.wheel_batch.draw()
        self.background_circle.draw()
        for sector, sprite in self.arcs:
            sprite.x = (
                math.cos(sector.start_angle + self.angle_offset) * MID_RADIUS
                + self.window_size[0] / 2
            )
            sprite.y = (
                math.sin(sector.start_angle + self.angle_offset) * MID_RADIUS + Y_OFFSET
            )
            sprite.rotation = 90 - math.degrees(sector.start_angle + self.angle_offset)
            sprite.draw()

        self.arrow_batch.draw()

    def on_click(self, x, y, button):
        self.spin()

    def spin(self):
        rand = random.random() * 0.75 + 0.25  # random num between 0.5 and 1
        self.wheel_velocity = SPIN_SPEED * rand
        self.player2 = None

    def on_update(self, deltaTime):
        self.wheel_velocity -= (
            LINEAR_FRICTION * self.wheel_velocity + CONSTANT_FRICTION
        ) * deltaTime

        self.wheel_velocity = max(self.wheel_velocity, 0)
        self.wheel_position += self.wheel_velocity * 2

        # cur_arc = 0
        for arc in range(len(self.arcs)):
            segment_angle = 1 / configs.SEGMENTS * math.tau
            self.arcs[arc][0].start_angle = self.wheel_position + arc * segment_angle
            diff_to_arrow = (math.pi / 2 - self.arcs[arc][0].start_angle) % (
                2 * math.pi
            )
            if diff_to_arrow > 0 and diff_to_arrow < segment_angle:
                self.cur_arc = arc

                # if self.cur_arc == 5:
                #     print(
                #         self.cur_arc,
                #         ((self.wheel_position / segment_angle) % configs.SEGMENTS),
                #         segment_angle,
                #     )
                #     exit()
                # print("arc", arc, diff_to_arrow, segment_angle)
                # exit()
        # print("updating cur_arc to", self.cur_arc)

        current_segment = int(self.wheel_position / math.tau * configs.SEGMENTS + 0.5)
        if current_segment != self.prev_segment:
            if self.player is None:
                self.player = self.audio.play()
            else:
                self.player.seek(0)
                self.player.play()
        if (
            self.wheel_velocity == 0
            and self.player is not None
            and self.player2 is None
        ):
            self.player.pause()
            # print("segment", current_segment)
            # print(
            #     "cur_arc",
            #     self.cur_arc,
            #     self.wheel_position % math.tau / math.tau * (configs.SEGMENTS - 1),
            # )
            # print(self.audio_file_name[self.cur_arc])
            self.player2 = pyglet.resource.media(
                self.audio_file_name[self.cur_arc]
            ).play()
            # self.player2 = pyglet.resource.media("sounds/output.wav").play()

        self.prev_segment = current_segment
