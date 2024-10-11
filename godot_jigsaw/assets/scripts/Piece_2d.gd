extends Node2D

# this scene is each individual puzzle piece that can snap together to form
# the jigsaw

# these are the (x,y) coords of the midpoints of the four sides of the piece
var NCoord: Vector2 # midpoint of the top side
var SCoord: Vector2 # midpoint of the bottom side
var ECoord: Vector2 # midpoint of the right side
var WCoord: Vector2 # midpoint of the left side

# ID's that associate with the jigsaw puzzle piece
# these are ID's that associate with each of the four sides of the piece
# for example:
#	the EID of a piece with an ID of 1 would be 2
#	the WID of a piece with an ID of 2 would be 1
#	the SID of a piece with an ID of 1 would be 9 assuming it is an 8x8 puzzle
#	the NID of a piece with an ID of 4 would be 1 assuming it is a 3x3 puzzle
#	the WID of a piece with an ID of 1 would be null as it is an edge piece
var NID
var SID
var EID
var WID

# store the actual node that associates with the ID's listed above for matches
#	if these are null then that means there is no matching piece for that side
var NNode
var SNode
var ENode
var WNode

# Node_association_complete will become true when all the pieces have been
#	initialized and the edges of each piece are associated properly with the
#	other pieces for matching
var Node_association_complete = false


# distance that pieces will snap together within
var snap_distance = 75

var ID: int # The actual ID of the current puzzle piece

# this is for becomes true when the piece is clicked on and is used for movement
# this becomes false when the piece is set down by the player
var selected = false

# this is the number that will be used to organize
#	all the pieces into groups so that they all move in tandem
var group_number

# to calculate velocity:
var prev_position = Vector2()
var velocity = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D/Area2D/CollisionShape2D.shape.extents = Vector2(PuzzleVar.pieceWidth,PuzzleVar.pieceHeight)/2 #collision box size set here
	PuzzleVar.active_piece = 0 # 0 is false, any other number is true
	# piece ID is set here
	ID = get_tree().get_nodes_in_group("puzzle_pieces").size()
	group_number = ID
	#instantiate the associated ID matches with the function below
	set_appropriate_node_id()
	prev_position = position # this is to calculate velocity
	update_coordinates_for_self() # initially update the coordinates
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = (position - prev_position) / delta # velocity is calculated here
	prev_position = position
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	# this if statement will only run once and is for when all the pieces
	# are instantiated. When they are instantiated, they will be associated
	# with each other so that they can snap to each other properly
	if Node_association_complete == false and group.size() == PuzzleVar.col * PuzzleVar.row:
		set_appropriate_node()


# this is the actual logic to move a piece when you select it
@rpc("any_peer", "call_local")
func move(distance: Vector2):
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	for nodes in group:
		if nodes.group_number == group_number:
			nodes.global_position += distance


#this is called whenever an event occurs within the area of the piece
#	Example events include a key press within the area of the piece or
#	a piece being clicked or even mouse movement
func _on_area_2d_input_event(viewport, event, shape_idx):
	# get all nodes from puzzle pieces
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	# check if the event is a mouse button and see if it is pressed
	if event is InputEventMouseButton and event.pressed:
		# check if it was the left button pressed
		if event.button_index == MOUSE_BUTTON_LEFT:
			# if no other puzzle piece is currently active
			if not PuzzleVar.active_piece:
				# if this piece is currently not selected
				if selected == false:
					# grab all pieces in the same group number
					for nodes in group:
						if nodes.group_number == group_number:
							nodes.bring_to_front()
					# set this piece as the active puzzle piece
					PuzzleVar.active_piece = self
					# mark as selected
					selected = true
					
			# if a piece is already selected
			else:
				if selected == true:
					# deselect the current piece
					selected = false
					# clear active piece reference
					PuzzleVar.active_piece = 0
			
				var num = group_number
				var connection_found = false
			
				# the following loop is where the actual match checking occurs
				for nodes in group:
				
					nodes.update_coordinates_for_self() # you only need to update the coordinates here to check
				
				# TODO: here check debug flag and then right the piece positions to the database
					if PuzzleVar.debug:
					# write all piece positions in group to database here
						print("write to database")
				
					if nodes.group_number == num and connection_found == false:
						connection_found = await nodes.check_connections(group)
				
			# Set to original color from gray/transparent movement for all players, Peter Nguyen
				rpc("remove_transparency")

# this is where the actual movement of the puzzle piece is handled
# when the mouse moves
func _input(event):
	if event is InputEventMouseMotion and selected == true:
		var group = get_tree().get_nodes_in_group("puzzle_pieces")
		
		# Peter Nguyen adding transparent effect
		rpc("apply_transparency")
		
		var distance = get_global_mouse_position() - global_position
		# move is called as an rpc function so that both the host and client
		# in a multiplayer game can see the movement
		move.rpc(distance)


# this is a basic function to check if a side can snap to another side of a
# puzzle piece
func snap_and_connect(group: Array, direction: String) -> bool:
	var connected = false
	var coord
	var matching
	var prev_group_number
	
	var new_group_number = group_number
	
	# Get the global position of the current node
	var current_global_pos = self.get_global_position()
	var matching_global_pos
	
	if direction == "n":
		coord = NCoord
		matching = NNode.SCoord
		prev_group_number = NNode.group_number
		matching_global_pos = NNode.get_global_position()
		
	elif direction == "s":
		coord = SCoord
		matching = SNode.NCoord
		prev_group_number = SNode.group_number
		matching_global_pos = SNode.get_global_position()
		
	elif direction == "e":
		coord = ECoord
		matching = ENode.WCoord
		prev_group_number = ENode.group_number
		matching_global_pos = ENode.get_global_position()
		
	else: #if west
		coord = WCoord
		matching = WNode.ECoord
		prev_group_number = WNode.group_number
		matching_global_pos = WNode.get_global_position()
	
	# this if statement determines whether the appropriate
	# sides are within the correct distance of each other to snap and connect
	var dist = calc_distance(coord, matching)
	if dist < snap_distance and dist != 0:
		connected = true
		
		# Calculate the midpoint between the two connecting sides
		var midpoint = (current_global_pos + matching_global_pos) / 2
		# Pass the midpoint to show_image_on_snap() so the image appears at the connection
		show_image_on_snap(midpoint)
		
		#$AudioStreamPlayer.play()
		play_sound()
		
		dist = calc_components(coord, matching)
		
		
		# here is the code to decide which group to move
		# this code will have it so that the smaller group will always
		# move to the larger group to snap and connect
		var countprev = 0
		var countcurr = 0
		
		for nodes in group:
			if nodes.group_number == group_number:
				countcurr += 1
			elif nodes.group_number == prev_group_number:
				countprev += 1
				
		if countcurr < countprev:
			new_group_number = prev_group_number
			prev_group_number = group_number
			dist *= -1
		
		# if it can actually snap and connect, the function below is called
		# to physically move the piece and join it to the appropriate group
		# this is an rpc call so that the movement and joining of the group
		# is reflected for all players in a multiplayer game
		move_pieces_to_connect.rpc(dist, prev_group_number, new_group_number)
		
	return connected


# This is the function that actually moves the piece (in the current group)
# to connect it and is called as an rpc so that it can be reflected for all players
@rpc("any_peer", "call_local")
func move_pieces_to_connect(distance: Vector2, prev_group_number: int, new_group_number: int):
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	for nodes in group:
		
		if nodes.group_number == prev_group_number:
			# this is where the piece is actually moved so
			# that it looks like it is connecting, this is also where
			# the proper group number is associated with the piece so that it
			# moves in tandem with the other joined pieces
			nodes.set_global_position(nodes.get_global_position() - distance)
			nodes.group_number = new_group_number


# this function checks each of the four sides of the piece to determine
# if there is a connection that can be made to another piece
func check_connections(group: Array) -> bool:
	# this if statement below is so that the piece stops moving so that the
	# position remains constant when it checks for an available connection
	if velocity != Vector2(0,0):
		await get_tree().create_timer(.05).timeout
	
	var stop_checking = false
	
	if NNode:
		stop_checking = snap_and_connect(group, "n")
		
	if SNode and stop_checking == false:
		stop_checking = snap_and_connect(group, "s")
			
	if ENode and stop_checking == false:
		stop_checking = snap_and_connect(group, "e")
			
	if WNode and stop_checking == false:
		stop_checking = snap_and_connect(group, "w")
		
	return stop_checking

# Method to get the piece ID
func get_piece_id() -> int:
	return ID


# this is the function that brings the piece to the front of the screen
func bring_to_front():
	var parent = get_parent()
	# removes the piece from the screen
	parent.remove_child(self) # Remove the piece from its parent
	# adds the piece back to the screen so that it looks like it is on top
	parent.add_child(self)

# this function calculates the distance between two points and returns the
# distance as a scalar value
func calc_distance(a: Vector2, b: Vector2) -> int:
	return ((b.y-a.y)**2 + (b.x-a.x)**2)**0.5
	
# this function calculates the distance between two points and returns the
# distance as a vector
func calc_components(a: Vector2, b: Vector2) -> Vector2:
	return Vector2(b.x-a.x,b.y-a.y)
	
# this function sets the appropriate associated ID for each of the four sides
# of a puzzle piece
func set_appropriate_node_id():
	NID = ID - PuzzleVar.row
	if NID <= 0:
		NID = null
	
	SID = ID + PuzzleVar.row
	if SID > PuzzleVar.row * PuzzleVar.col:
		SID = null
	
	EID = ID + 1
	if EID > PuzzleVar.row * PuzzleVar.col:
		EID = null
	
	WID = ID - 1
	if WID <= 0:
		WID = null


# this function updates the coordinates of the midpoints of the four sides
# of the puzzle piece so that they can be compared with other sides of another
# puzzle piece
func update_coordinates_for_self():
	# coordinates are not updated until piece has stopped moving
	if velocity != Vector2(0,0):
		await get_tree().create_timer(.05).timeout
	
	NCoord = global_position + Vector2(PuzzleVar.pieceWidth/2,0)
	SCoord = global_position + Vector2(PuzzleVar.pieceWidth/2,PuzzleVar.pieceHeight)
	ECoord = global_position + Vector2(PuzzleVar.pieceWidth,PuzzleVar.pieceHeight/2)
	WCoord = global_position + Vector2(0,PuzzleVar.pieceHeight/2)

# this function associates the proper node to each side of the piece
# based on the ID 
func set_appropriate_node():
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	Node_association_complete = true
	if NID:
		NNode = group[NID-1]
	if SID:
		SNode = group[SID-1]
	if EID:
		ENode = group[EID-1]
	if WID:
		WNode = group[WID-1]
		

func show_image_on_snap(position: Vector2): # Peter Nguyen wrote this function
	var popup = Sprite2D.new()
	# Load texture
	popup.texture = preload("res://assets/images/checkmark2.0.png")
	
	# Center the sprite in the viewport
	# popup.position = get_viewport().get_visible_rect().size / 2
	# Using midpoint between connecting nodes
	popup.position = position
	
	# Make the sprite larger
	popup.scale = Vector2(1.5, 1.5) 
	# Ensure visibility
	popup.visible = true
	# This adds it to the main scene
	get_tree().current_scene.add_child(popup)  
	# Make image be at the top
	popup.z_index = 10
	# Optional: Make the image disappear after a while
	# Show image for 2 seconds
	await get_tree().create_timer(2.0).timeout
	popup.queue_free()

# This function is called to apply the transparency effect to the pieces for all players to see
# Written by Peter Nguyen
@rpc("any_peer", "call_local")
func apply_transparency():
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	for nodes in group:
		if nodes.group_number == group_number:
			nodes.modulate = Color(0.7, 0.7, 0.7, 0.5)

# This function is called to remove the transparency effect of the pieces for all players to see
# Written by Peter Nguyen
@rpc("any_peer", "call_local")
func remove_transparency():
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	for nodes in group:
		if nodes.group_number == group_number:
			nodes.modulate = Color(1, 1, 1, 1)

func play_sound(): # Peter Nguyen
	var snap_sound = preload("res://assets/sounds/ding.mp3")
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = snap_sound
	add_child(audio_player)
	audio_player.play()
	# Manually queue_free after sound finishes
	await audio_player.finished
	audio_player.queue_free()
