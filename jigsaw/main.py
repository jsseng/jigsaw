import app
import pyglet
from typing import Tuple
from window import Window


# 1024 x 768

def main():
    window = Window(fullscreen=True, caption='Draggable Rectangle')
    # image = pyglet.resource.image('images/seattle.png')
    image = pyglet.image.load('images/seattle.png')
    batch = pyglet.graphics.Batch()
    # rectangle = pyglet.shapes.Rectangle(0, 0, 100, 200, color=(255, 255, 255), batch=batch)

    @window.event
    def on_draw():
        window.clear()
        image.blit(window.width//4, window.height//4)
        batch.draw()
        window.rectangle.draw()

    pyglet.app.run()

    return


if __name__ == "__main__":
    main()



