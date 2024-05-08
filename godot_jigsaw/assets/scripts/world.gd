extends Node2D

var GRID_WIDTH = PuzzleVar.col
var GRID_HEIGHT = PuzzleVar.row

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(PuzzleVar.row)
	print(PuzzleVar.col)
	print(PuzzleVar.size)
	
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
			platform.position.x = (get_viewport_rect().size.x / 2) + (cell_width * x) - (image_size.x / 2) + (cell_width / 2)
			platform.position.y = (get_viewport_rect().size.y / 2) + (cell_height * y) - (image_size.y / 2) + (cell_height / 2)
			
			var platform_shape = platform.get_node("ColorRect")
			#platform_shape.set_shape(shape)
			
			get_parent().call_deferred("add_child", platform)

	# Iterate through the grid for the pieces
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			# Create a new sprite for each cell
			var piece = sprite_scene.instantiate()
			
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

			# Position the sprite in the grid
			# viewport.size.x /2 = halfway across screen
			# subtract x * cellwidth
			piece.position.x = (get_viewport_rect().size.x / 2) + (cell_width * x) - (image_size.x / 2) + (cell_width / 2)
			piece.position.y = (get_viewport_rect().size.y / 2) + (cell_height * y) - (image_size.y / 2) + (cell_height / 2)
			
			# Add the sprite to the Grid node	
			get_parent().call_deferred("add_child", piece)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
