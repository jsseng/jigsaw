extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$referenceImage.texture = load("res://assets/puzzles/jigsawpuzzleimages/1200px-Mount_Washington_Cascades.jpg") #change it so that it takes in puzzlevar.choice
	
	var jigsawpp = preload("res://assets/scenes/jigsaw_puzzle_piece.tscn")
	var jigsaw_puzzle_piece = jigsawpp.instantiate()
	get_parent().call_deferred("add_child", jigsaw_puzzle_piece)
	jigsaw_puzzle_piece.get_child(0).texture = load("res://assets/puzzles/jigsawpuzzleimages/1200px-Mount_Washington_Cascades.jpg")
	#slice up the pieces and spawn them in
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
