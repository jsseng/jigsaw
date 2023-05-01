import pyglet
import math
import random

import color_utils
import configs
import app

def main():
    gl_background_color = tuple(map(lambda x : x / 255.0, configs.BACKGROUND_COLOR))

    config = pyglet.gl.Config(sample_buffers=1, samples=8)
    window = pyglet.window.Window(caption="Caboose Wheel", config=config)
    pyglet.gl.glClearColor(*gl_background_color, 1.0)
    pyglet.options['audio'] = ('openal', 'pulse', 'directsound', 'silent')

    game_app = app.App((window.width, window.height))

    @window.event
    def on_draw():
        pyglet.gl.glFlush()
        window.clear()

        game_app.on_draw()
    
    @window.event
    def on_mouse_press(x, y, button, modifiers):
        game_app.on_click(x, y, button)


    pyglet.clock.schedule_interval(game_app.on_update, 1 / configs.FPS)
    pyglet.app.run()

if __name__ == "__main__":
    main()