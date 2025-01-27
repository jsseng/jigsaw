# Script added and written by Peter N.
extends Node2D

# Global variables for the cursor
var cursor_image = preload("res://assets/images/cross.png")  # Preloaded cursor image
var resized_cursor: ImageTexture
var cursor_hotspot: Vector2

# Sensitivity multiplier (adjustable)
var cursor_sensitivity: float = 0.3

func _ready():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Prepare resized cursor and hotspot
	prepare_cursor()

	# Set the cursor with the resized texture and centered hotspot
	Input.set_custom_mouse_cursor(resized_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	
	# Override cursor for all existing nodes
	override_cursor_for_all_nodes(get_tree().root)

	# Connect to the node added signal to handle dynamically added nodes
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

# Prepare the resized cursor texture and hotspot
func prepare_cursor():
	# Convert to Image to resize
	var image = cursor_image.get_image()
	
	# Resize the image
	var new_width = image.get_width() / 15
	var new_height = image.get_height() / 15
	image.resize(new_width, new_height)

	# Convert back to ImageTexture
	resized_cursor = ImageTexture.create_from_image(image)

	# Set the centered hotspot
	cursor_hotspot = Vector2(new_width / 2, new_height / 2)

# Recursively override the cursor for all Control nodes
func override_cursor_for_all_nodes(node):
	if node is Control:
		Input.set_custom_mouse_cursor(resized_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	for child in node.get_children():
		override_cursor_for_all_nodes(child)

# Handle dynamically added nodes
func _on_node_added(node):
	if node is Control:
		Input.set_custom_mouse_cursor(resized_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	if node.get_children().size() > 0:
		override_cursor_for_all_nodes(node)

# Force the custom cursor every frame
func _process(_delta):
	Input.set_custom_mouse_cursor(resized_cursor, Input.CURSOR_ARROW, cursor_hotspot)
	
# Cursor sensitivity
func _input(event):
	if event is InputEventMouseMotion:
		
		# Scale the mouse movement by sensitivity
		var adjusted_motion = event.relative * cursor_sensitivity
		# Make movement to right stronger to even out
		if event.relative.x > 0:
			adjusted_motion += Vector2(2.5,0)
			
		# Get the current cursor position
		var current_position = get_viewport().get_mouse_position()

		# Update the cursor position based on sensitivity
		var new_position = current_position + adjusted_motion
		
		# Move the cursor to the new position
		get_viewport().warp_mouse(new_position)

	# Check for keyboard input to adjust sensitivity
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			cursor_sensitivity += 0.1
			print("Sensitivity increased to: ", cursor_sensitivity)  # Optional debug print
		elif event.keycode == KEY_Q:
			cursor_sensitivity = max(0.1, cursor_sensitivity - 0.1)  # Prevent negative sensitivity
			print("Sensitivity decreased to: ", cursor_sensitivity)  # Optional debug print
		elif event.keycode == KEY_F:
			# Toggle fullscreen
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
