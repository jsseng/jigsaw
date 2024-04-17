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

	# Iterate through the grid
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			# Create a new sprite for each cell
			var sprite = load("res://assets/scripts/DraggableSprite.gd").new()
			sprite.texture = image_texture
			
			# Needed for Rect 2
			sprite.set_region_enabled(true)
			
			# Set the texture rect for the sprite
			var rect = Rect2(x * cell_width, y * cell_height, cell_width, cell_height)
			sprite.set_region_rect(rect)

			# Position the sprite in the grid
			sprite.position.x = (cell_width * x) + (cell_width / 2) + 100
			sprite.position.y = (cell_height * y) + (cell_height / 2) + 100
			
			#print(sprite.get_frame_coords())
			#print(cell_width)
			#print(cell_height)
			#print(sprite.position.x)
			#print(sprite.position.y)
			
			# Add the sprite to the Grid node
			get_parent().call_deferred("add_child", sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
