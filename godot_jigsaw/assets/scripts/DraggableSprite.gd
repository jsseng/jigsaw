# DESCRIPTION
#
#  This is a simple Godot game that lets you move a sprite around in two ways:
#
#     * by clicking, and then without moving, releasing. Then you can drag
#       the sprite around without holding down the mouse button. When you
#       want to drop the sprite, release the mouse button.
#
#     * by clicking, and then while holding the mouse button down, dragging
#       the sprite to where you want it by moving the mouse. When you want
#       to drop the sprite, release the mouse.
#

# This line of code is what lets you use methods and properties Sprite has,
# like set_process_input, and global_position.
extends Node2D

# Define the status of the sprite: "none", "clicked", "released", or "dragging".
var status = "none"
var inside

# Define the vector that will contain the (width, height) of the sprite
var tsize = Vector2()

# Define the mouse position.
var mpos = Vector2()

@onready var sprite = get_node("Sprite2D")

var body_ref
var droppable
var debug = 0
var piece_id : int # Unique identifier for the piece
var original_parent
var original_index

# The is one of Godot's "hooks" or "callbacks" - a function called at a certain
# time in another program's execution. You can search for the functions that
# start with an underscore "_" in the Godot documentation online. This function
# gets called whenever your sprite enters the scene tree.
func _ready():
	#tsize = get_texture().get_size()

	tsize = sprite.get_region_rect().size
	
	# Set the initial global position of the sprite to be the center of the
	# viewport. Note GDScript supports vector math.
	#global_position = get_viewport_rect().size / 2
	
	# Assign a unique ID to the puzzle piece
	piece_id = get_tree().get_nodes_in_group("puzzle_pieces").size()
	#print(piece_id)


# This is another Godot hook. It is called every single frame!
func _process(_delta):
	# If the sprite is being dragged in either of the two modes, update its
	# position every frame. To update the position, we use the position of
	# the mouse
	if status == "dragging":
		global_position = mpos
	
	#if (debug % 50) == 0:
		#print(global_position)
		#debug += 1
	#else:
		#debug += 1

# Yet another Godot hook. It is called every time an input event @ev is
# received. The input events we care about are clicks (InputEventMouseButton)
# and movement (InputEventMouseButton). We do something special for each event,
# in order control the state of the game. No matter what, every time this
# hook is called, we update the mouse position to match the position at which
# the input event was generated.
func _unhandled_input(ev):
	# This is the Godot 3.1.5 way to check event type. There is no longer a
	# "type" property on @ev. That's going to break a lot of people's code...
	# If the event is for a left-button click, do things.
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		# If the sprite is not being dragged, and if the mouse button was
		# clicked (as opposed to released, or "unclicked"), do things.
		# Do nothing if piece was correctly placed
		if status == "correct":
			pass
		elif status != "dragging" and ev.is_action_released("click"):
			
			# Define a event position variable (scoped to this if block)
			var evpos = ev.global_position
			
			# Define a global sprite position variable (scopedd to this if
			# block)
			var gpos = global_position
			
			# This is where we actually check if the sprite was clicked or not,
			# by checking if the clicked point is in the Sprite's rectangle.
			if inside:
				# If the sprite's rectangle was clicked, update the sprite
				# status to "clicked", and bring the sprite to the front.
				if status != "correct" and PuzzleVar.active_piece == -1:
					status = "clicked"
					PuzzleVar.active_piece = get_piece_id()
					bring_to_front()
				
		# If the sprite is being dragged and the mouse button is being released,
		# set the sprite status to "released" to stop dragging and drop the
		# sprite.
		elif status == "dragging" and not ev.pressed:
			# Check if within a platform, if it is then tween that shit
			status = "released"
			PuzzleVar.active_piece = -1
			restore_original_index() # Restore the original index when released
			if droppable:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
				if (get_piece_id() == body_ref.get_slot_id()):
					PuzzleVar.valid_count += 1
					status = "correct"
					body_ref.queue_free()
			bring_to_front()
	
	# If the card status is "clicked" and the mouse is being moved, set the
	# sprite status to "dragging", so the appropriate loop can run when a mouse
	# button click or release event is next received.
	
	if status == "clicked" and ev is InputEventMouseMotion:
		status = "dragging"

	# Not matter what, every time an input event is received, update the mouse
	# position with the event's global position. This may need to be moved
	# into the other "if" statements when we start handling other input events
	# here.
	if ev is InputEventMouseMotion:
		# matrix multiply with the 
		mpos = get_viewport().canvas_transform.affine_inverse() * ev.position
		#print(mpos)

func _on_area_2d_mouse_entered():
	inside = true

func _on_area_2d_mouse_exited():
	inside = false
	
func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	body_ref = body
	#print(get_piece_id())
	#print(body.get_slot_id())
	#print(get_piece_id())
	#print(body.get_slot_id())
	body.modulate = Color(Color.TAN, 0.8)
	droppable = true
	#print(droppable)
	
func _on_area_2d_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body:
		body.modulate = Color(Color.DIM_GRAY, 0.8)
		if body == body_ref:
			droppable = false
			#print(droppable)

# Method to get the piece ID
func get_piece_id() -> int:
	return piece_id

func bring_to_front():
	original_index = get_index() # Store the original index
	var parent = get_parent()
	parent.remove_child(self) # Remove the piece from its parent
	parent.add_child(self) # Add the piece back to the parent, which places it at the end of the list

func restore_original_index():
	var parent = get_parent()
	parent.move_child(self, original_index) # Move the piece back to its original index
