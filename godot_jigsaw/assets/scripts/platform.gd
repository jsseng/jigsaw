extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(Color.BLANCHED_ALMOND, 0.5)
	var piece_size = Rect2(0, 0, (PuzzleVar.size.x / PuzzleVar.col), (PuzzleVar.size.y / PuzzleVar.row))
	
	# Set the size of the ColorRect
	$ColorRect.size = piece_size.size
	
	# Calculate the position to center the ColorRect relative to the collision shape
	var center_offset = (piece_size.size - ($CollisionShape2D.shape.extents * 2))
	print(center_offset)
	print($CollisionShape2D.shape.extents)
	$ColorRect.position = $CollisionShape2D.shape.extents - center_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
