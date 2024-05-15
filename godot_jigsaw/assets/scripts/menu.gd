extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var image_texture = $Seattle.texture
	var image_size = image_texture.get_size()
	PuzzleVar.size = image_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/world.tscn")

func SetRow(row : int) -> void:
	PuzzleVar.row = row
	
func SetCol(col : int) -> void:
	PuzzleVar.col = col
	
func _on_row_value_changed(value):
	SetRow(value)
	
func _on_col_value_changed(value):
	SetCol(value)
	
# Handle input events
func _input(event):
	# Check if the event is a key press event
	if event is InputEventKey:
		# Check if the pressed key is the Escape key
		if event.keycode == KEY_ESCAPE:
			# Exit the game
			get_tree().quit()
