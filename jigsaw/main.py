import app
import pyglet


def main():
    window = pyglet.window.Window(caption="jigsaw", fullscreen=False)
    window = app.App(1000, 700)
    pyglet.app.run()
    return


if __name__ == "__main__":
    main()