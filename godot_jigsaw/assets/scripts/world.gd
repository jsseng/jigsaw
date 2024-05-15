extends Node2D

var GRID_WIDTH = PuzzleVar.col
var GRID_HEIGHT = PuzzleVar.row

var debug = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Load the image
	var image_texture = $Image.texture
	var image_size = image_texture.get_size()
	
	# Calculate the size of each grid cell
	var cell_width = image_size.x / GRID_WIDTH
	var cell_height = image_size.y / GRID_HEIGHT
	
	# preload the scenes
	var sprite_scene = preload("res://assets/scenes/DraggableSprite.tscn")
	var platform_scene = preload("res://assets/scenes/platform.tscn")
	
	# Iterate through the grid for the platforms
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			# Add the platform for each puzzle piece
			var platform = platform_scene.instantiate()
			platform.add_to_group("platforms")
			platform.position.x = (get_viewport_rect().size.x / 2) + (cell_width * x) - (image_size.x / 2) + (cell_width / 2)
			platform.position.y = (get_viewport_rect().size.y / 2) + (cell_height * y) - (image_size.y / 2) + (cell_height / 2)

			#var platform_shape = platform.get_node("ColorRect")
			#platform_shape.set_shape(shape)
			
			get_parent().call_deferred("add_child", platform)
			
	
	# Shuffle the grid positions
	var grid_positions = []

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			# Calculate the position for each grid cell
			var pos_x = (get_viewport_rect().size.x / 2) + (cell_width * x) - (image_size.x / 2) + (cell_width / 2)
			var pos_y = (get_viewport_rect().size.y / 2) + (cell_height * y) - (image_size.y / 2) + (cell_height / 2)
			
			# Apply vertical offset based on column position
			if y >= (GRID_WIDTH / 2):
				pos_y += 500
			else:
				pos_y -= 450
			
			# Add the position to the list
			grid_positions.append(Vector2(pos_x, pos_y))

	# Shuffle the grid positions
	grid_positions.shuffle()

	# Iterate through the grid for the pieces
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			# Create a new sprite for each cell
			var piece = sprite_scene.instantiate()
			
			piece.add_to_group("puzzle_pieces")
			debug += 1;
			#print(piece.get_piece_id())
			
			var sprite = piece.get_node("Sprite2D")
			var collision = piece.get_node("Area2D/CollisionShape2D")

			sprite.texture = image_texture
			# in script, configure the collisionshape of our sprites, so that we can use the signal
			# to check if were inside a platform area/droppable then use tween to do the suck

			# Needed for Rect 2
			sprite.set_region_enabled(true)
			
			# Set the texture rect for the sprite
			var rect = Rect2(x * cell_width, y * cell_height, cell_width, cell_height)
			sprite.set_region_rect(rect)
			
			# Set the shape of the collision2D node for pieces
			var shape = RectangleShape2D.new()
			shape.size = Vector2(cell_width, cell_height)
			collision.set_shape(shape)

			piece.position = grid_positions.pop_back()
			
			# Add the sprite to the Grid node	
			get_parent().call_deferred("add_child", piece)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(PuzzleVar.valid_count)
	if PuzzleVar.valid_count == 4:
		$Label.text = "YOU COMPLETED THE PUZZLE!!!"

# Handle esc
func _input(event):
	# Check if the event is a key press event
	if event is InputEventKey:
		# Check if the pressed key is the Escape key
		if event.keycode == KEY_ESCAPE:
			# Exit the game
			get_tree().quit()

