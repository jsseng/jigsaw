extends Control

#coords of where the borders of the piece are
var NCoord #calculate these using the width and height of the block
var SCoord
var ECoord
var WCoord

#coords of where the borders of the matching pieces are
var NMatch
var SMatch
var EMatch
var WMatch

var ID #piece id for identification

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#continually be looking to update the coords and then compare them when actually dragging them
	
	pass

func _get_drag_data(at_position):
	var drag_texture = $TextureRect
	set_drag_preview(drag_texture)
	#remove the sprite potentially so it looks like it is simply being dragged around somehow

func _can_drop_data(at_position, data):
	return true #make it so that it can drop it quite literally anywhere
	
func _drop_data(at_position, data):
	pass
