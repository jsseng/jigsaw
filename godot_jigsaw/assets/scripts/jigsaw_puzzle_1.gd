extends Node2D

var GRID_WIDTH = PuzzleVar.col
var GRID_HEIGHT = PuzzleVar.row

var debug = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#load up reference
	$referenceImage.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	
	# Load the image
	$Image.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_texture = $Image.texture #will probably simplify later
	var image_size = image_texture.get_size()
	
	# Calculate the size of each grid cell
	var cell_width = image_size.x / GRID_WIDTH
	var cell_height = image_size.y / GRID_HEIGHT
	
	PuzzleVar.pieceWidth = cell_width #may change this eventualy when can think of a better way to instantiate collision box but for now this will do
	PuzzleVar.pieceHeight = cell_height
	
	# preload the scenes
	var sprite_scene = preload("res://assets/scenes/Piece_2d.tscn")
	
	# Iterate through the grid for the pieces
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			# Create a new sprite for each cell
			var piece = sprite_scene.instantiate()
			
			piece.add_to_group("puzzle_pieces")
			debug += 1;
			#print(piece.get_piece_id())
			
			var sprite = piece.get_node("Sprite2D")
			#var collision = piece.get_node("Area2D/CollisionShape2D")

			sprite.texture = image_texture
			# in script, configure the collisionshape of our sprites, so that we can use the signal
			# to check if were inside a platform area/droppable then use tween to do the suck

			# Needed for Rect 2
			sprite.set_region_enabled(true)
			
			# Set the texture rect for the sprite
			var rect = Rect2(x * cell_width, y * cell_height, cell_width, cell_height)
			sprite.set_region_rect(rect)
			
			# Set the shape of the collision2D node for pieces
			#var shape = RectangleShape2D.new() #will probably reuse this code
			#shape.size = Vector2(cell_width, cell_height)
			#collision.set_shape(shape)
			
			var spawnarea = get_viewport_rect()

			piece.position = Vector2(randi_range(50,spawnarea.size.x),randi_range(50,spawnarea.size.y))
			
			# Add the sprite to the Grid node	
			get_parent().call_deferred("add_child", piece)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
			pass #load the puzzle pieces here from the database
		
			
