extends Camera2D

var zoom_speed = 100
var zoom_margin = 0.3

var zoom_min = 0.2
var zoom_max = 1

var zoom_pos = Vector2()
var zoom_factor = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom.x = lerp(zoom.x, zoom.x * zoom_factor, zoom_speed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoom_factor, zoom_speed * delta)

	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)
	
	#print(zoom_factor)

func _input(event):
	if abs(zoom_pos.x - get_global_mouse_position().x) > zoom_margin:
		zoom_factor = 1.0
	if abs(zoom_pos.y - get_global_mouse_position().y) > zoom_margin:
		zoom_factor = 1.0
		
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_J && zoom_factor > 0.99:
				if (zoom_factor == 1.01):
					zoom_factor -= 0.02
				else:
					zoom_factor -= 0.01
				zoom_pos = get_global_mouse_position()
			if event.keycode == KEY_K && zoom_factor < 1.01:
				if (zoom_factor == 0.99):
					zoom_factor += 0.02
				else:
					zoom_factor += 0.01
				zoom_pos = get_global_mouse_position()
