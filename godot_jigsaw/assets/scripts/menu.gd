extends Control

# this menu is used to determine the size of the puzzle that the player wants
# to play, currently 2x2 to 10x10 puzzles are supported

# Called when the node enters the scene tree for the first time.
func _ready():
	# loads the image textures and the sizes needed into variables so that
	# they can be chopped up properly into pieces
	##var image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	#var image_size = image_texture.get_size()
	#PuzzleVar.size = image_size
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/jigsaw_puzzle_1.tscn")
	
func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/new_menu.tscn")

#func SetRow(row : int) -> void:
	#PuzzleVar.row = row
	#
#func SetCol(col : int) -> void:
	#PuzzleVar.col = col
	#
#func _on_row_value_changed(value):
	#SetRow(value)
	#SetCol(value)
	#
## Handle input events
#func _input(event):
	## Check if the event is a key press event
	#if event is InputEventKey:
		## Check if the pressed key is the Escape key
		#if event.keycode == KEY_ESCAPE:
			## Exit the game
			#get_tree().quit()
		
		
