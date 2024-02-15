import pyglet
from draggableRectangle import DraggableRectangle

class Window(pyglet.window.Window):
    def __init__(self, *args, **kwargs):
        super(Window, self).__init__(*args, **kwargs)
        self.rectangle = DraggableRectangle(500, 500, 50, 50)

    def on_draw(self):
        self.clear()
        self.rectangle.draw()

    def on_mouse_press(self, x, y, button, modifiers):
        if button == pyglet.window.mouse.LEFT:
            if self.rectangle.is_point_inside(x, y):
                self.rectangle.is_dragging = not self.rectangle.is_dragging
                print(self.rectangle.is_dragging)

    def on_mouse_release(self, x, y, button, modifiers):
        # if button == pyglet.window.mouse.LEFT:
        #     self.rectangle.is_dragging = False
        pass

    def on_mouse_motion(self, x, y, dx, dy):
        if self.rectangle.is_dragging is True:
            # self.rectangle.x += dx
            # self.rectangle.y += dy
            self.rectangle.x = x - self.rectangle.width / 2
            self.rectangle.y = y - self.rectangle.height / 2