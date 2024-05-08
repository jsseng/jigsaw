extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(Color.BLANCHED_ALMOND, 0.7)
	var piece_size = Rect2(0, 0, (PuzzleVar.size.x / PuzzleVar.row), (PuzzleVar.size.y / PuzzleVar.col))
	$ColorRect.size = piece_size.size
	print(piece_size.size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

