extends Camera2D

var zoom_speed = 100
var zoom_margin = 0.3

var zoom_min = 0.2
var zoom_max = 1

var zoom_pos = Vector2()
var zoom_factor = 1.0

var is_panning = false
var last_mouse_position = Vector2()

# Bounds for constraining movement to background
var camera_bounds = Rect2(Vector2(-3700, -2700), Vector2(6000, 4100))

# Reference image path and texture loading
var reference_image_path = (PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
var reference_texture = load(reference_image_path) 

# Called when the node enters the scene tree for the first time.
func _ready():
	#position_smoothing_enabled = true
	limit_smoothed = true
	# Add the CanvasLayer or Control node dynamically (if not already in the scene)
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

	# Create a TextureRect for the reference image
	var reference_image = TextureRect.new()
	reference_image.texture = load(reference_image_path) # Dynamically load the image
	reference_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT # Keep aspect ratio
	var texture_size = reference_image.texture.get_size()

	
	# Define the target size (in pixels) that you want all images to be
	var target_size = Vector2(400, 400)  # Example target size: 200x200 pixels

	# Calculate the scale factors to make the image fit the target size
	var scale_x = target_size.x / texture_size.x
	var scale_y = target_size.y / texture_size.y

	# Use the smaller scale factor to maintain aspect ratio
	var uniform_scale = min(scale_x, scale_y)
	#var desired_width = texture_size.x * 0.001# Adjust as needed
	#var desired_height = texture_size.y * 0.001# Adjust as needed
	reference_image.set_scale(Vector2(uniform_scale, uniform_scale))
	# Add the TextureRect to the CanvasLayer
	canvas_layer.add_child(reference_image)

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
			# Check if both J and K are pressed
			if Input.is_key_pressed(KEY_J) and Input.is_key_pressed(KEY_K):
				return  # Skip zoom functionality when both are pressed
				
			if event.keycode == KEY_J && zoom_factor > 0.99:
				if (zoom_factor == 1.01):
					zoom_factor -= 0.02
				else:
					zoom_factor -= 0.01
					
				# Adjust camera position to keep the mouse world position consistent
				#position = get_global_mouse_position()
	
			if event.keycode == KEY_K && zoom_factor < 1.01:
				if (zoom_factor == 0.99):
					zoom_factor += 0.02
				else:
					zoom_factor += 0.01
				
				#position = get_global_mouse_position()
				
	##panning test
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if event.is_pressed() and PuzzleVar.background_clicked == true:
				## Start panning
				#is_panning = true
				#last_mouse_position = event.position
			#else:
				## Stop panning
				#is_panning = false
	##elif event is InputEventMouseMotion and is_panning: # if currently panning
	#elif event is InputEventMouseMotion and PuzzleVar.background_clicked == true: # if currently panning
		#var mouse_delta = event.position - last_mouse_position
		#position -= mouse_delta / zoom # move the camera position based on how zoomed in
		#last_mouse_position = event.position # set the last mouse position

	#elif event is InputEventMouseMotion and is_panning: # if currently panning
	if event is InputEventMouseMotion:
		if PuzzleVar.background_clicked == true: # if currently panning
			var mouse_delta = event.position - last_mouse_position
			position -= mouse_delta / zoom # move the camera position based on how zoomed in
			
			# Clamp the camera position within the bounds
			position.x = clamp(position.x, camera_bounds.position.x, camera_bounds.position.x + camera_bounds.size.x)
			position.y = clamp(position.y, camera_bounds.position.y, camera_bounds.position.y + camera_bounds.size.y)
			
		last_mouse_position = event.position # set the last mouse position
