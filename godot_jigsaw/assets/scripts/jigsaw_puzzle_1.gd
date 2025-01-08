extends Node2D

# this is the main scene where the game actually occurs for the players to play

var GRID_WIDTH = PuzzleVar.col
var GRID_HEIGHT = PuzzleVar.row

# Called when the node enters the scene tree for the first time.
func _ready():
			
	# load up reference image
	$referenceImage.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	print ("ref_image: " + (PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]))
	print ("image choice: " + str(PuzzleVar.choice))
	
	# Load the image
	$Image.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_texture = $Image.texture #will probably simplify later
	var image_size = image_texture.get_size()
	
	# Calculate the size of each grid cell
	var cell_width = image_size.x / GRID_WIDTH
	var cell_height = image_size.y / GRID_HEIGHT
	
	# load the cell width and height into these global variables so that
	# the collision box of each piece can be computed
	PuzzleVar.pieceWidth = cell_width
	PuzzleVar.pieceHeight = cell_height
	
	# preload the scenes
	var sprite_scene = preload("res://assets/scenes/Piece_2d.tscn")
	
	parse_pieces_json()
	parse_adjacent_json()
	#build_grid()
	#print (PuzzleVar.image_file_names)
	
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
		#print ("piece_image_path: " + piece_image_path)
		sprite.texture = load(piece_image_path) # load the image
		
		# set the height and width for each piece
		piece.piece_height = sprite.texture.get_height()
		piece.piece_width = sprite.texture.get_width()
		
		PuzzleVar.pieceWidth = piece.piece_width
		PuzzleVar.pieceHeight = piece.piece_height
		
		#set the collision box for the sprite
		var collision_box = piece.get_node("Sprite2D/Area2D/CollisionShape2D")

		#set the collision box to the bounding box of the sprite
		collision_box.shape.extents = Vector2(sprite.texture.get_width() / 2, sprite.texture.get_height() / 2)
	
		var spawnarea = get_viewport_rect()

		piece.position = Vector2(randi_range(50,spawnarea.size.x),randi_range(50,spawnarea.size.y))
		
		# Add the sprite to the Grid node	
		get_parent().call_deferred("add_child", piece)

	var puzzleId = hash(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]+str(PuzzleVar.col)+str(PuzzleVar.row))

	#FireAuth.add_active_puzzle(puzzleId, GRID_WIDTH, GRID_HEIGHT)
	#FireAuth.add_favorite_puzzle(str(puzzleId))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#TODO: add a win function
	# ideally have it check if all the pieces are the part of the same group
	# if so then have it display that they won
	
	#print(PuzzleVar.valid_count)
	#if PuzzleVar.valid_count == GRID_WIDTH * GRID_HEIGHT:
		#$Label.text = "YOU COMPLETED THE PUZZLE!!!"
		
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
		
# This function parses pieces.json which contains the bounding boxes around each piece.  The
# bounding box coordinates are given as pixel coordinates in the global image.
func parse_pieces_json():
	print("Calling parse_pieces_json")
	
	PuzzleVar.image_file_names["3"] = "peacock"
	PuzzleVar.image_file_names["4"] = "peacock"
	
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
			#print (grid[x])
			#if 251 in grid[x]:
				#print ("---found upper left corner---")
			#if 167 in grid[x]:
				#print ("---found lower left corner---")
			#if 895 in grid[x]:
				#print ("---missing piece---")
			
	#find the top row
	for row_num in range(temp_grid.size()):
		var first_element = (temp_grid[row_num])[0] # get the first element of the row
		if (PuzzleVar.global_coordinates_list[str(first_element)])[1] == 0:
			#print("first row is:" + str(row_num))
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
	print("Arranging grid...")
	# Get the 2D grid from build_grid
	var grid = build_grid()
	var cell_width = PuzzleVar.pieceWidth
	var cell_height = PuzzleVar.pieceHeight
	
	# Loop through the grid and arrange pieces
	for row in range(grid.size()):
		for col in range(grid[row].size()):
			var piece_id = grid[row][col]
			var piece = PuzzleVar.ordered_pieces_array[piece_id]
			
			# Compute new position based on the grid cell
			var new_position = Vector2(col * cell_width * 1.05, row * cell_height * 1.05)
			piece.move_to_position(new_position)
