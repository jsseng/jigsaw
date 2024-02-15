import pyglet


class DraggableRectangle(pyglet.shapes.Rectangle):
    def __init__(self, x, y, width, height):
        super(DraggableRectangle, self).__init__(x, y, width, height)
        self.is_dragging = False

    def is_point_inside(self, x, y):
        return self.x < x < self.x + self.width and self.y < y < self.y + self.height
