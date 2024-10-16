extends Node2D

# this is the main scene where the game actually occurs for the players to play

var GRID_WIDTH = PuzzleVar.col
var GRID_HEIGHT = PuzzleVar.row

# Called when the node enters the scene tree for the first time.
func _ready():
			
	# load up reference image
	$referenceImage.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	
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
	
	
	# add puzzle to active puzzle or add user to currently active puzzle
	var puzzleCollection: FirestoreCollection = Firebase.Firestore.collection("puzzles")
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var puzzleId = hash(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]+str(PuzzleVar.col)+str(PuzzleVar.row))
	if (await puzzleCollection.get_doc(str(puzzleId)) == null):
		# add doc here
		puzzleCollection.add(str(puzzleId), {'complete': false, 'users': [FireAuth.get_user_id()], 'pieces': [], 'xDimension': GRID_WIDTH, 'yDimension': GRID_HEIGHT, 'size': GRID_HEIGHT*GRID_WIDTH})
	else:
		# get current doc and add new user
		var puzzleDoc = await puzzleCollection.get_doc(str(puzzleId))
		var userField = await puzzleDoc.document.get("users")
		var usersArray = []
		if userField and "arrayValue" in userField:
			for value in userField["arrayValue"]["values"]:
				if "stringValue" in value:
					usersArray.append(value["stringValue"])
		
		var currentUser = FireAuth.get_user_id()
		if currentUser not in usersArray:
			usersArray.append(FireAuth.get_user_id())
			puzzleDoc.add_or_update_field("users", usersArray)
			puzzleCollection.update(puzzleDoc)
	
	# add to user active puzzle list
	var userDoc = await FireAuth.get_user_puzzle_list(FireAuth.get_user_id())
	var userActivePuzzleField = userDoc.document.get("activePuzzles")
	var activePuzzleList = []
	if userActivePuzzleField and "arrayValue" in userActivePuzzleField:
			for value in userActivePuzzleField["arrayValue"]["values"]:
				if "stringValue" in value:
					activePuzzleList.append(value["stringValue"])
				
	if str(puzzleId) not in activePuzzleList:
		activePuzzleList.append(str(puzzleId))
		userDoc.add_or_update_field("activePuzzles", activePuzzleList)
		userCollection.update(userDoc)


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
		
			
