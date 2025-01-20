# Script added and written by Peter N.
extends Node

# Global variables for the cursor
var cursor_image = preload("res://assets/images/cross.png")  # Preloaded cursor image
var resized_cursor: ImageTexture
var cursor_hotspot: Vector2

func _ready():
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
