import pyglet
from sys import platform
from os import system
from socket import gethostname

from threading import Timer


import configs
import app
import serialInput


def main():
    gl_background_color = tuple(map(lambda x: x / 255.0, configs.BACKGROUND_COLOR))

    config = pyglet.gl.Config(sample_buffers=1, samples=8, double_buffer=True)
    window = pyglet.window.Window(
        caption="Caboose Wheel", config=config, fullscreen=True
    )
    pyglet.gl.glClearColor(*gl_background_color, 1.0)
    pyglet.options["audio"] = ("openal", "pulse", "directsound", "silent")

    game_app = app.App((window.width, window.height))

    shut_down_timer = None

    shutdown_label = pyglet.text.Label(
        "Shutting down in 10s...Press green to stop shutdown.",
        font_name="Arial",
        font_size=24,
        x=0,
        y=window.height,
        anchor_x="left",
        # anchor_y="bottom",
        anchor_y="top",
        color=(255, 0, 0, 255),
    )

    @window.event
    def on_draw():
        pyglet.gl.glFlush()
        window.clear()

        game_app.on_draw()
        if shut_down_timer is not None:
            shutdown_label.draw()

    @window.event
    def on_mouse_press(x, y, button, modifiers):
        if button == 2:
            handle_shutdown()
        elif button == 4:
            pyglet.app.exit()
        else:
            game_app.on_click(x, y, button)

    def handle_shutdown(cancel_shutdown_only=False):
        nonlocal shut_down_timer
        if shut_down_timer is not None:
            shut_down_timer.cancel()
            shut_down_timer = None
        elif not cancel_shutdown_only:
            shut_down_timer = Timer(10, lambda: system("shutdown now"))
            shut_down_timer.start()

    # dev board will need to be changed. not sure of the name in debian
    if platform != "darwin" and gethostname() == "ubuntu":
        serialInputHandler = serialInput.Input(
            on_green_trigger=game_app.spin,
            on_red_trigger=lambda: handle_shutdown(cancel_shutdown_only=True),
            on_green_hold=pyglet.app.exit,
            on_red_hold=handle_shutdown,
        )
    else:
        serialInputHandler = None

    def update_all(deltaTime):
        if serialInputHandler is not None:
            serialInputHandler.update()
        game_app.on_update(deltaTime)

    pyglet.clock.schedule_interval(update_all, 1 / 60)
    pyglet.app.run()


if __name__ == "__main__":
    main()
