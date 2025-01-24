extends Node2D

# this is the main scene where the game actually occurs for the players to play

var is_muted
var mute_button: Button
var unmute_button : Button
var offline_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	name = "JigsawPuzzleNode"
	
	is_muted = false
	
	# load up reference image
	#$referenceImage.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	print ("ref_image: " + (PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]))
	print ("image choice: " + str(PuzzleVar.choice))
	
	# Load the image
	$Image.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	#var image_texture = $Image.texture #will probably simplify later
	#var image_size = image_texture.get_size()
	
	PuzzleVar.background_clicked = false
	PuzzleVar.piece_clicked = false
	
	offline_button_show()

	# preload the scenes
	var sprite_scene = preload("res://assets/scenes/Piece_2d.tscn")
	
	parse_pieces_json()
	parse_adjacent_json()
	
	z_index = 0
	
	# Iterate through and create puzzle pieces
	for x in range(PuzzleVar.global_num_pieces):
		# Create a new sprite for each cell
		var piece = sprite_scene.instantiate()
			
		# add the piece to the group puzzle_pieces so that connection logic can work
		piece.add_to_group("puzzle_pieces")
		PuzzleVar.ordered_pieces_array.append(piece)
		
		#sets the texture of the sprite to the image
		var sprite = piece.get_node("Sprite2D")
		
		# Set the texture rect for the sprite
		var piece_image_path = PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]
		#print ("full path:  " + piece_image_path)
		piece_image_path = piece_image_path.split('.') # remove the trailing .jpg extension
		piece_image_path = piece_image_path[0] + "/size-100/raster/" + str(x) + ".png" 
		piece.ID = x # set the piece ID here
		piece.z_index = 2
		#print ("piece_image_path: " + piece_image_path)
		sprite.texture = load(piece_image_path) # load the image
		
		# set the height and width for each piece
		piece.piece_height = sprite.texture.get_height()
		piece.piece_width = sprite.texture.get_width()
		
		#set the collision box for the sprite
		var collision_box = piece.get_node("Sprite2D/Area2D/CollisionShape2D")

		#set the collision box to the bounding box of the sprite
		collision_box.shape.extents = Vector2(sprite.texture.get_width() / 2, sprite.texture.get_height() / 2)
	
		var spawnarea = get_viewport_rect()

		piece.position = Vector2(randi_range(50,spawnarea.size.x),randi_range(50,spawnarea.size.y))
		
		# Add the sprite to the Grid node	
		get_parent().call_deferred("add_child", piece)
		#add_child(piece)
		
	var puzzleId = hash(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]+str(PuzzleVar.col)+str(PuzzleVar.row))

	if(FireAuth.offlineMode == 0):
		FireAuth.add_active_puzzle(PuzzleVar.choice)
		FireAuth.add_favorite_puzzle(PuzzleVar.choice)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#TODO: add a win function
	# ideally have it check if all the pieces are the part of the same group
	# if so then have it display that they won
	pass

# Handle esc
func _input(event):
	# Check if the event is a key press event
	if event is InputEventKey and event.is_pressed() and event.echo == false:
		# Check if the pressed key is the Escape key
		if event.keycode == KEY_ESCAPE:
			# Exit the game
			get_tree().quit()
			
		if event.keycode == 76: #if key press is l
			print("load pieces")
			pass # load the puzzle pieces here from the database
			
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_P:
				# Arrange grid
				arrange_grid()
			elif event.keycode == KEY_M:
				if is_muted == false:
					on_mute_button_press()
					is_muted = true
				else:
					on_unmute_button_press()
					is_muted = false
			elif event.keycode == KEY_MINUS: # lower volume
				adjust_volume(-4)
			elif event.keycode == KEY_EQUAL: # raise volume
				adjust_volume(4)
				
	if PuzzleVar.snap_found == true:
		print ("snap found")
		PuzzleVar.snap_found = false
		
	if event is InputEventMouseButton and event.pressed:
		if PuzzleVar.background_clicked == false:
			PuzzleVar.background_clicked = true
		else:
			PuzzleVar.background_clicked = false
		
# This function parses pieces.json which contains the bounding boxes around each piece.  The
# bounding box coordinates are given as pixel coordinates in the global image.
func parse_pieces_json():
	print("Calling parse_pieces_json")
	
	PuzzleVar.image_file_names["0"] = "china_10"
	PuzzleVar.image_file_names["1"] = "china_100"
	PuzzleVar.image_file_names["2"] = "china_1000"
	PuzzleVar.image_file_names["3"] = "elephant_10"
	PuzzleVar.image_file_names["4"] = "elephant_100"
	PuzzleVar.image_file_names["5"] = "elephant_1000"
	PuzzleVar.image_file_names["6"] = "fpeacock_10"
	PuzzleVar.image_file_names["7"] = "fpeacock_100"
	PuzzleVar.image_file_names["8"] = "fpeacock_1000"
	
	
	# Load the JSON file for the pieces.json
	var json_path = "res://assets/puzzles/jigsawpuzzleimages/" + PuzzleVar.image_file_names[str(PuzzleVar.choice)] + "/size-100/pieces.json"
	var file = FileAccess.open(json_path, FileAccess.READ)

	if file:
		var json = file.get_as_text()
		file.close()

		# Parse the JSON data
		var json_parser = JSON.new()
		var data = json_parser.parse(json)
		
		if data == OK: # if the data is valid, go ahead and parse
			var temp_id = 0
			var num_pieces = json_parser.data.size()
			print ("Number of pieces" + str(num_pieces))
			
			for n in num_pieces: # for each piece, add it to the global coordinates list
				PuzzleVar.global_coordinates_list[str(n)] =  json_parser.data[str(n)]
			
# This function parses adjacent.json which contains information about which pieces are 
# adjacent to a given piece
func parse_adjacent_json():
	print("Calling parse_adjacent_json")
	
	# Load the JSON file for the pieces.json
	var json_path = "res://assets/puzzles/jigsawpuzzleimages/" + PuzzleVar.image_file_names[str(PuzzleVar.choice)] + "/adjacent.json"
	var file = FileAccess.open(json_path, FileAccess.READ)

	if file: #if the file was opened successfully
		var json = file.get_as_text()
		file.close()

		# Parse the JSON data
		var json_parser = JSON.new()
		var data = json_parser.parse(json)
		print("starting reading adjacent.json")
		if data == OK:
			var temp_id = 0
			var num_pieces = json_parser.data.size()
			PuzzleVar.global_num_pieces = num_pieces
			print ("Number of pieces" + str(num_pieces))
			for n in num_pieces: # for each piece, add the adjacent pieces to the list
				PuzzleVar.adjacent_pieces_list[str(n)] =  json_parser.data[str(n)]
				
				
# The purpose of this function is to build a grid of the puzzle piece numbers
func build_grid(): 
	var grid = {}
	var midpoints = []
	var temp_grid = []
	var final_grid = []

	#create an entry for each puzzle piece
	for x in range(PuzzleVar.global_num_pieces):
		grid[x] = [x]
		
	# compute the midpoint of all pieces
	for x in range(PuzzleVar.global_num_pieces):
		#compute the midpont of each piece
		var node_bounding_box = PuzzleVar.global_coordinates_list[str(x)]
		var midpoint = Vector2((node_bounding_box[2]+node_bounding_box[0])/2, (node_bounding_box[3]+node_bounding_box[1])/2)
		midpoints.append(midpoint) # append the midpoint of each piece

	var row_join_counter = 1
	while row_join_counter != 0:
		row_join_counter = 0
		
		for x in range(PuzzleVar.global_num_pieces): # run through all the piece groups
			var cur_pieces_list = grid[x]
			
			if cur_pieces_list.size() > 0:
				var adjacent_list = PuzzleVar.adjacent_pieces_list[str(cur_pieces_list[-1])] #get the adjacent list of the rightmost piece

				var current_midpoint = midpoints[int(cur_pieces_list[-1])] # get the midpoint of the rightmost piece
				
				for a in adjacent_list:
					#compute the difference in midpoint
					#print (a)
					#print("angle: " + str(current_midpoint.angle_to_point(midpoints[int(a)])))
					var angle = current_midpoint.angle_to_point(midpoints[int(a)])
					
					#get adjacent bounding box
					var node_bounding_box = PuzzleVar.global_coordinates_list[str(cur_pieces_list[-1])]
					
					if midpoints[int(a)][0] > node_bounding_box[2]: # adjacent piece is to the right
						if grid[int(a)].size() > 0:
							var temp_list = cur_pieces_list
							temp_list += grid[int(a)]
							grid[x] = temp_list
							grid[int(a)] = [] # remove entries from this piece
							row_join_counter += 1
			
	# add the rows to a temporary grid
	for x in range(PuzzleVar.global_num_pieces):
		if (grid[x]).size() > 0:
			temp_grid.append(grid[x])
			
	#find the top row
	for row_num in range(temp_grid.size()):
		var first_element = (temp_grid[row_num])[0] # get the first element of the row
		if (PuzzleVar.global_coordinates_list[str(first_element)])[1] == 0: # get y-coordinate of first element
			final_grid.append(temp_grid[row_num]) # add the row to the final grid
			temp_grid.remove_at(row_num) # remove the row from the temporary grid
			break
			
	#sort the rows
	var row_y_values = []
	var unsorted_rows = {}
	
	# build an array of Y-values of the bounding boxes of the first element and
	# build a corresponding dictionary 
	for row_num in range(temp_grid.size()):
		var first_element = (temp_grid[row_num])[0] # get the first element of the row
		var y_value = (PuzzleVar.global_coordinates_list[str(first_element)])[1] # get the upper left Y coordinate
		row_y_values.append(y_value)
		unsorted_rows[y_value] = temp_grid[row_num]
			
	row_y_values.sort() # sort the y-values
	for x in range(row_y_values.size()):
		var row = unsorted_rows[row_y_values[x]]
		final_grid.append(row) # add the rows in sorted order
	
	# print the final grid
	for x in range(final_grid.size()):
		print (final_grid[x])
	return final_grid

# Arrange puzzle pieces based on the 2D grid returned by build_grid , Peter Nguyen
func arrange_grid():
	# Get the 2D grid from build_grid
	var grid = build_grid()
	var cell_piece = PuzzleVar.ordered_pieces_array[0]
	var cell_width = cell_piece.piece_width
	var cell_height = cell_piece.piece_height
	
	# Loop through the grid and arrange pieces
	for row in range(grid.size()):
		for col in range(grid[row].size()):
			var piece_id = grid[row][col]
			var piece = PuzzleVar.ordered_pieces_array[piece_id]
			
			# Compute new position based on the grid cell
			var new_position = Vector2(col * cell_width * 1.05, row * cell_height * 1.05)
			piece.move_to_position(new_position)
			
func play_snap_sound(): # Peter Nguyen
	var snap_sound = preload("res://assets/sounds/ding.mp3")
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = snap_sound
	add_child(audio_player)
	audio_player.play()
	# Manually queue_free after sound finishes
	await audio_player.finished
	audio_player.queue_free()
	
func on_mute_button_press():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)  # Mute the audio
		
func on_unmute_button_press():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)  # Mute the audio

#Logic for showing the winning labels and buttons
func show_win_screen():
	#-------------------------LABEL LOGIC------------------------#
	var label = Label.new()
	
	# Set the text for the Label
	label.text = "You've Finished the Puzzle!"
	
	# Set the font size as well as the color
	label.add_theme_font_size_override("font_size", 200)
	label.add_theme_color_override("font_color", Color(0, 204, 0))
	
	# Load the font file 
	var font = load("res://assets/fonts/KiriFont.ttf") as FontFile
	label.add_theme_font_override("font", font)
	
	# Change label poistion and add the label to the current scene
	label.position = Vector2(-1000, -700)
	get_tree().current_scene.add_child(label)

	#-------------------------BUTTON LOGIC-----------------------#
	var button = $MainMenu
	button.visible = true
	# Change the font size
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", 120)
	# Change the text color to white
	var font_color = Color(1, 1, 1)  # RGB (1, 1, 1) = white
	button.add_theme_color_override("font_color", font_color)
	button.connect("pressed", Callable(self, "on_main_menu_button_pressed")) 
 
# Function to change scenes when button is pressed
func on_main_menu_button_pressed():
	# Load the new scene
	#await get_tree().create_timer(2.0).timeout
	reset_puzzle_state()
	get_tree().change_scene_to_file("res://assets/scenes/new_menu.tscn")
	
#This function clears all puzzle pieces and resets global variables
func reset_puzzle_state():
	# Get all puzzle pieces and remove them
	var all_pieces = get_tree().get_nodes_in_group("puzzle_pieces")
	for node in all_pieces:
		node.queue_free() # Removes puzzle pieces from the scene
	
	# Reset global variables related to the puzzle
	PuzzleVar.active_piece = -1
	PuzzleVar.ordered_pieces_array = [] # Peter added this
	PuzzleVar.global_coordinates_list = {} #a dictionary of global coordinates for each piece
	PuzzleVar.adjacent_pieces_list = {} #a dictionary of adjacent pieces for each piece
	PuzzleVar.image_file_names = {} #a dictionary containing a mapping of selection numbers to image names
	PuzzleVar.global_num_pieces = 0 #the number of pieces in the current puzzle
	PuzzleVar.draw_green_check = false
	
func offline_button_show():
	if FireAuth.offlineMode == 1:
		offline_button = Button.new()
		offline_button.text = "OFFLINE"
		# loading in the font to use for text
		var font = load("res://assets/fonts/KiriFont.ttf") as FontFile
		# Set the font type for the Button
		offline_button.add_theme_font_override("font", font)
		# Setting the font size
		offline_button.add_theme_font_size_override("font_size", 60)
		var button_texture = StyleBoxTexture.new()
		var texture = preload("res://assets/images/wood_button_normal.png")
	
		# Adjust the content margins of the style box
		button_texture.content_margin_left = 200  # Adjust left margin
		button_texture.content_margin_top = 200   # Adjust top margin
		button_texture.content_margin_right = 200  # Adjust right margin
		button_texture.content_margin_bottom = 200  # Adjust bottom margin
		#Apply the texture to the button and stylebox
		button_texture.texture = texture
		offline_button.add_theme_stylebox_override("normal", button_texture)
		
		var hover_stylebox = StyleBoxTexture.new()
		var hover_texture = preload("res://assets/images/wood_button_pressed.png")
		hover_stylebox.texture = hover_texture
		hover_stylebox.content_margin_left = 200
		hover_stylebox.content_margin_top = 200
		hover_stylebox.content_margin_right = 200
		hover_stylebox.content_margin_bottom = 200
		offline_button.add_theme_stylebox_override("hover", hover_stylebox)
		# Set text colors for normal and hover states
		offline_button.add_theme_color_override("font_color", Color(1, 1, 1))  # Normal state (white)
		offline_button.add_theme_color_override("font_color_hover", Color(0.8, 0.8, 0.0))  # Hover state (yellow)
		offline_button.position = Vector2(-1650, 700)
		get_tree().current_scene.add_child(offline_button)
	return
	
func adjust_volume(change_in_db):
	var current_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) # get current volume
	
	if current_volume >= 20: # limit maximum volume
		return
		
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), current_volume + change_in_db)
  
