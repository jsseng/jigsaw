# importing pyglet module
import pyglet
import pyglet.window.key
from pyglet import shapes

def main():
    # width of window
    width = 1024

    # height of window
    height = 768

    # caption i.e title of the window
    title = "Seattle Jigsaw"

    image = pyglet.resource.image('images/seattle.png')
    image_width = image.width
    image_height = image.height
    # creating a window
    window = pyglet.window.Window(image_width, image_height, title)

    image_x = (window.width - image_width) // 2
    image_y = (window.height - image_height) // 2

    batch = pyglet.graphics.Batch()

    shape_list = []
    rectangle_list = []

    width_factor = 12
    height_factor = 11

    rect_width = (image_width // width_factor) + 1
    rect_height = (image_height // height_factor) + 1

    for i in range(image_width // width_factor, image_width, rect_width):
        # Vertical lines
        linex = shapes.Line(image_x + i, image_y, image_x + i, image_y + image_height,
                            width=3, color=(255, 255, 255), batch=batch)
        linex.opacity = 250
        shape_list.append(linex)

    for i in range(image_height // height_factor, image_height, rect_height):
        # Horizontal lines
        liney = shapes.Line(image_x, image_y + i, image_x + image_width, image_y + i,
                            width=3, color=(255, 255, 255), batch=batch)
        liney.opacity = 250
        shape_list.append(liney)

    # on draw event
    @window.event
    def on_draw(): 
        
        # clearing the window
        window.clear()
        image.blit(image_x, image_y)
        batch.draw()
        
    # key press event 
    @window.event
    def on_key_press(symbol, modifier):

        # key "C" get press
        if symbol == pyglet.window.key.C:
            print("Key C is pressed")

    # on mouse press event
    @window.event
    def on_mouse_press(x, y, button, modifiers):
        
        # printing some message
        print("Mouse button pressed")

        # print rectangles on mouse press
        line1 = shapes.Line(x - rect_width/2, y - rect_height/2, x + rect_width/2, y - rect_height/2, width=3, color=(255, 0, 0), batch=batch)
        line2 = shapes.Line(x + rect_width/2, y - rect_height/2, x + rect_width/2, y + rect_height/2, width=3, color=(255, 0, 0), batch=batch)
        line3 = shapes.Line(x + rect_width/2, y + rect_height/2, x - rect_width/2, y + rect_height/2, width=3, color=(255, 0, 0), batch=batch)
        line4 = shapes.Line(x - rect_width/2, y + rect_height/2, x - rect_width/2, y - rect_height/2, width=3, color=(255, 0, 0), batch=batch)
        rectangle_list.extend([line1, line2, line3, line4])

    # image for icon
    img = image = pyglet.resource.image("images/seattle.png")
    # # setting image as icon
    window.set_icon(img)
                
    # start running the application
    pyglet.app.run()

if __name__ == "__main__":
    main()
