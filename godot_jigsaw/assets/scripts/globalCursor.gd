# Script added and written by Peter N.
extends Node2D

# Global variables for the cursor
var cursor_image = preload("res://assets/images/cross.png")  # Preloaded cursor image
var resized_cursor: ImageTexture
var cursor_hotspot: Vector2
var popup_window

# Add threshold check for minimum movement
var threshold = 5

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
	
	# Create and configure the popup window
	create_sensitivity_popup()

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
	
func create_sensitivity_popup():
	popup_window = Window.new()
	popup_window.title = "Adjust Sensitivity"
	popup_window.min_size = Vector2(500, 300)
	popup_window.position = get_viewport().size / 2 - popup_window.min_size / 2
	popup_window.visible = false
	add_child(popup_window)

	# VBoxContainer for vertical alignment
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.anchor_bottom = 1
	vbox.anchor_right = 1
	popup_window.add_child(vbox)

	# Label for the title
	var title_label = Label.new()
	title_label.text = "Adjust Cursor Sensitivity"
	title_label.horizontal_alignment = Label.PRESET_CENTER
	vbox.add_child(title_label)

	# Slider for sensitivity adjustment with tick marks
	var slider = HSlider.new()
	slider.min_value = 0.1
	slider.max_value = 1.0
	slider.step = 0.1
	slider.value = cursor_sensitivity
	slider.tick_count = 10  
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(slider)
	
	# Create a single long label for all tick values
	var long_label = Label.new()
	long_label.text = "0.1       0.2       0.3       0.4        0.5       0.6       0.7       0.8         0.9       1.0"
	long_label.horizontal_alignment = Label.PRESET_CENTER
	long_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(long_label)
	
	# Label for the title
	var thresh_label = Label.new()
	thresh_label.text = "Adjust Cursor Threshold"
	thresh_label.horizontal_alignment = Label.PRESET_CENTER
	vbox.add_child(thresh_label)
	
	# Slider for cursor threshold adjustment with tick marks
	var threshold_slider = HSlider.new()
	threshold_slider.min_value = 1.0
	threshold_slider.max_value = 10.0
	threshold_slider.step = 1.0
	threshold_slider.value = threshold
	threshold_slider.tick_count = 10  
	threshold_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(threshold_slider)
	
	# Create a single long label for all tick values
	var thresh_longlabel = Label.new()
	thresh_longlabel.text = " 1           2           3          4           5           6           7           8           9        10"
	thresh_longlabel.horizontal_alignment = Label.PRESET_CENTER
	thresh_longlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(thresh_longlabel)

	# Button to close the popup
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(close_button)

	# Connect slider to update cursor sensitivity
	slider.connect("value_changed", Callable(self, "_on_sensitivity_changed"))
	threshold_slider.connect("value_changed", Callable(self, "_on_threshold_changed"))

	# Connect button to hide the popup
	close_button.connect("pressed", Callable(popup_window, "hide"))

# Update sensitivity when the slider value changes
func _on_sensitivity_changed(value):
	cursor_sensitivity = value
	print("Cursor sensitivity set to: ", cursor_sensitivity)

# Update threshold when the slider changes
func _on_threshold_changed(value):
	threshold = value
	print("Cursor threshold set to: ", threshold)
	
# Cursor sensitivity
func _input(event):
	if event is InputEventMouseMotion:
		# Get the absolute values of movement for checking threshold
		var abs_x = abs(event.relative.x)
		var abs_y = abs(event.relative.y)
		
		# Check if motion is below threshold (both X AND Y)
		if abs_x < threshold and abs_y < threshold:
			# Mark the input as handled to prevent default behavior
			get_viewport().set_input_as_handled()
			return  # Exit the function early to prevent any movement
		
		# If we're here, at least one dimension is above threshold
		# Scale the mouse movement by sensitivity
		var adjusted_motion = Vector2.ZERO
		
		# Only apply sensitivity to dimensions that exceed threshold
		if abs_x >= threshold:
			adjusted_motion.x = event.relative.x * cursor_sensitivity
			# Compensate rightward movement if needed
			if event.relative.x > 0 and event.relative.x > threshold * 1.5:
				adjusted_motion.x += 2.5
		
		if abs_y >= threshold:
			adjusted_motion.y = event.relative.y * cursor_sensitivity
		
		# Only warp the mouse if we have some movement to apply
		if adjusted_motion != Vector2.ZERO:
			# Get the current cursor position
			var current_position = get_viewport().get_mouse_position()
			
			# Update the cursor position based on sensitivity
			var new_position = current_position + adjusted_motion
			
			# Move the cursor to the new position
			get_viewport().warp_mouse(new_position)
		
		# Always mark the input as handled to ensure full control
		get_viewport().set_input_as_handled()

	# Check for keyboard input to adjust sensitivity
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			cursor_sensitivity += 0.1
			print("Sensitivity increased to: ", cursor_sensitivity)  # Optional debug print
		elif event.keycode == KEY_Q:
			cursor_sensitivity = max(0.1, cursor_sensitivity - 0.1)  # Prevent negative sensitivity
			print("Sensitivity decreased to: ", cursor_sensitivity)  # Optional debug print
		#elif event.keycode == KEY_O:
		elif Input.is_key_pressed(KEY_J) and Input.is_key_pressed(KEY_K):
			popup_window.show()  # Show the sensitivity adjustment popup
		elif event.keycode == KEY_F:
			# Toggle fullscreen
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
