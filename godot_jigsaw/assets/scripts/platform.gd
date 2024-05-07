extends StaticBody2D

var slot_id : int # Unique identifier for the slot

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(Color.BLANCHED_ALMOND, 0.7)
	
	# Assign a unique ID to the slot
	slot_id = get_tree().get_nodes_in_group("platform").size()
	#print(slot_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if global.is_dragging:
		#visible = true
	#else:
		#visible = false
	pass

# Method to get the slot ID
func get_slot_id() -> int:
	return slot_id
