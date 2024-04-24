extends Node2D

const GRID_WIDTH = 2
const GRID_HEIGHT = 2

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
	
	# Create a tilemap node
	var tilemap = TileMap.new()
	get_parent().call_deferred("add_child", tilemap)

	# Iterate through the grid
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			# Create a new sprite for each cell
			var piece = sprite_scene.instantiate()
			
			var sprite = piece.get_node("Sprite2D")
			var collision = piece.get_node("Area2D/CollisionShape2D")
					
			# ------- TILEMAP --------
			tilemap.set_cell(0, Vector2i(0, 0))
			# ------------------------
			
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
			piece.position.x = (cell_width * x) - (cell_width / 2) + (get_viewport_rect().size.x / 2)
			piece.position.y = (cell_height * y) - (cell_height / 2) + (get_viewport_rect().size.y / 2)
			
			# Add the sprite to the Grid node
			get_parent().call_deferred("add_child", piece)
			
			# Add the platform for each puzzle piece
			var platform = platform_scene.instantiate()
			platform.position.x = (cell_width * x) - (cell_width / 2) + (get_viewport_rect().size.x / 2)
			platform.position.y = (cell_height * y) - (cell_height / 2) + (get_viewport_rect().size.y / 2)
			
			var platform_shape = platform.get_node("ColorRect")
			#platform_shape.set_shape(shape)
			
			get_parent().call_deferred("add_child", platform)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
