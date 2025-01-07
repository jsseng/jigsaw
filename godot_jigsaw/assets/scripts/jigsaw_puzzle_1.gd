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
	print (PuzzleVar.image_file_names)
	
	# Iterate through and create puzzle pieces
	print (PuzzleVar)
	for x in range(PuzzleVar.global_num_pieces):
		# Create a new sprite for each cell
		var piece = sprite_scene.instantiate()
			
		# add the piece to the group puzzle_pieces so that connection logic can work
		piece.add_to_group("puzzle_pieces")
		PuzzleVar.ordered_pieces_array.append(piece)
		
		#sets the texture of the sprite to the image
		var sprite = piece.get_node("Sprite2D")
		
		sprite.centered = false
		
		# Set the texture rect for the sprite
		# Load the image
		var piece_image_path = PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]
		#print ("full path:  " + piece_image_path)
		piece_image_path = piece_image_path.split('.') # remove the trailing .jpg extension
		piece_image_path = piece_image_path[0] + "/size-100/raster/" + str(x) + ".png" 
		piece.ID = x # set the piece ID here
		#print ("piece_image_path: " + piece_image_path)
		sprite.texture = load(piece_image_path)
		
		#set the collision box for the sprite
		var collision_box = piece.get_node("Sprite2D/Area2D/CollisionShape2D")

		#set the collision box to the bounding box of the sprite
		collision_box.shape.extents = Vector2(sprite.texture.get_width() / 2, sprite.texture.get_height() / 2)
			
		var spawnarea = get_viewport_rect()

		piece.position = Vector2(randi_range(50,spawnarea.size.x),randi_range(50,spawnarea.size.y))
				
		# Add the sprite to the Grid node	
		get_parent().call_deferred("add_child", piece)

	if 1 == 0:
		# Iterate through the grid to create the pieces
		for y in range(GRID_WIDTH):
			for x in range(GRID_HEIGHT):
				# Create a new sprite for each cell
				var piece = sprite_scene.instantiate()
				# add the piece to the group puzzle_pieces so that connection logic
				# can work
				piece.add_to_group("puzzle_pieces")
				
				#sets the texture of the sprite to the image
				var sprite = piece.get_node("Sprite2D")
				sprite.texture = image_texture

				# Needed for Rect 2
				sprite.set_region_enabled(true)
				
				# Set the texture rect for the sprite
				var rect = Rect2(x * cell_width, y * cell_height, cell_width, cell_height)
				sprite.set_region_rect(rect)
				# the above makes it so that it looks like a chunk of the image,
				# like a piece of the puzzle
				
				# I currently set the collision of each piece within the scene
				# Piece_2d using the global variables of PuzzleVar.pieceWidth and PuzzleVar.pieceHeight
				# maybe someone can reconfigure the code using the code below as a template to set the
				# collision box in here for more simplicity
				
				# Set the shape of the collision2D node for pieces
				#var shape = RectangleShape2D.new() #will probably reuse this code
				#shape.size = Vector2(cell_width, cell_height)
				#collision.set_shape(shape)
				
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
		print("starting reading pieces.json")
		if data == OK:
			var temp_id = 0
			var num_pieces = json_parser.data.size()
			print ("Number of pieces" + str(num_pieces))
			for n in num_pieces:
				#print (str(n) + ":   " + str(json_parser.data[str(n)]))
				PuzzleVar.global_coordinates_list[str(n)] =  json_parser.data[str(n)]
			
			#print (global_coordinates_list)
			
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
			for n in num_pieces:
				#print (str(n) + ":   " + str(json_parser.data[str(n)]))
				PuzzleVar.adjacent_pieces_list[str(n)] =  json_parser.data[str(n)]
			
			#print (adjacent_pieces_list)			
