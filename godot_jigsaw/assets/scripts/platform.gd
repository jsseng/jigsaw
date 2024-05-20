extends StaticBody2D


var slot_id : int # Unique identifier for the slot
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(Color.DIM_GRAY, 0.8)
	# Assign a unique ID to the slot
	slot_id = get_tree().get_nodes_in_group("platform").size() - 1
	#print(slot_id)
	var piece_size = Rect2(0, 0, (PuzzleVar.size.x / PuzzleVar.col), (PuzzleVar.size.y / PuzzleVar.row))
	
	# Set the size of the ColorRect
	$ColorRect.size = piece_size.size
	
	# Calculate the position to center the ColorRect relative to the collision shape
	var center_offset = ($ColorRect.size / 2) * -1
	# Centered at center of collision piece, so position should be center of size.
	$ColorRect.position = center_offset
	#print("slot: ", slot_id)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Method to get the slot ID
func get_slot_id() -> int:
	return slot_id
