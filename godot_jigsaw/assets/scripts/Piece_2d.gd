extends Node2D

#coords of where the borders of the piece are
var NCoord: Vector2 #calculate these using the width and height of the block
var SCoord: Vector2
var ECoord: Vector2
var WCoord: Vector2

#in order to get the position of the pieces in accordance with the board, use global_position

#ID's that associate with the jigsaw puzzle piece
var NID #if null that means that it doesn't have a matching piece, it is an edge piece
var SID
var EID
var WID #see if can cut out later

#store the actual nodes as the appropriate matches
var NNode #if null that means there isn't a matching piece
var SNode
var ENode #the issue is that these need to be stored as whole numbers, not as decimals
var WNode

var Node_stored = false #this will be switched to true when the appropriate nodes are stored

#distance that pieces will snap together within
var snap_distance = 75

var ID: int #piece id for identification

var selected = false

var group_number #this is the number that will be used to organize it into groups

#var original_parent
var original_index #this is for the bringing the images to the front stuff

#to calculate velocity:
var prev_position = Vector2()
var velocity = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D/Area2D/CollisionShape2D.shape.extents = Vector2(PuzzleVar.pieceWidth,PuzzleVar.pieceHeight)/2 #collision box size set here
	PuzzleVar.active_piece = 0 #0 is false, 1 is true
	#need to set the piece ID
	ID = get_tree().get_nodes_in_group("puzzle_pieces").size()
	group_number = ID
	#instantiate the associated ID matches
	set_appropriate_node_id()
	prev_position = position #for velocity
	
	update_coordinates_for_self() #initially update the coordinates, reupdate when released after dragging
	
	#for i in GameManager.Players:
		#print(GameManager.Players[i].id)
		#$MultiplayerSynchronizer.set_multiplayer_authority(GameManager.Players[i].id) #sets it so that all players have authority over piece2d

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#handle the coordinate changes here
	
	
	#update_coordinates_for_self()
	
	
	velocity = (position - prev_position) / delta
	prev_position = position
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	
	
	if Node_stored == false and group.size() == PuzzleVar.col * PuzzleVar.row:
		#this should result in them having proper matching and snapping
		set_appropriate_node()
			
	if selected:
		
		#move_puzzle_piece.rpc()
		
		#print(velocity)
		var distance = get_global_mouse_position() - global_position
		#iterate through all the nodes and get group_number to move the appropriate ones
		#if they have the same group number as the one that has been selected then all the nodes in the same group move
		#print(NCoord) #test
		for nodes in group:
			if nodes.group_number == group_number:
				nodes.global_position += distance
				
#@rpc("any_peer", "call_local")
#func move_puzzle_piece():
	#var group = get_tree().get_nodes_in_group("puzzle_pieces")
	#var distance = get_global_mouse_position() - global_position
		##iterate through all the nodes and get group_number to move the appropriate ones
		##if they have the same group number as the one that has been selected then all the nodes in the same group move
		##print(NCoord) #test
	#for nodes in group:
		#if nodes.group_number == group_number:
			#nodes.global_position += distance


func _on_area_2d_input_event(viewport, event, shape_idx):
	
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	
	if not PuzzleVar.active_piece:
		if Input.is_action_just_pressed("click") and selected == false:
			
			for nodes in group:
				if nodes.group_number == group_number:
					nodes.bring_to_front()
			PuzzleVar.active_piece = self
			selected = true
	else:
		if Input.is_action_just_pressed("click") and selected == true:
			#print("release")
			#the issue is here
			
			#var piece = PuzzleVar.active_piece #see if this will be needed
			selected = false
			#print(piece.ID)
			PuzzleVar.active_piece = 0
			
			var num = group_number
			
			
			for nodes in group:
				#print("getting group")
				
				#nodes.global_position = Vector2(nodes.global_position.x, nodes.global_position.y)
				
				#nodes.global_position = Vector2(round(nodes.global_position.x),round(nodes.global_position.y)) #rounds it so that they are all 
				nodes.update_coordinates_for_self() #you only need to update the coordinates here to check
				
				#here check debug flag and then right the piece positions to the database
				if PuzzleVar.debug:
					#write all piece positions in group to database here
					print("write to database")
				
				if nodes.group_number == num: #change this so that it just checks all its children
					#print("check group")
					nodes.check_connections(group)
	
	
	
	#cut out the below and have it handled as a general event
	#if PuzzleVar.active_piece: #this fixes the multiple click issue
			#
		#if Input.is_action_just_released("click"): #fix the release as well
			#
			##need to make it so that it rounds and snaps to a whole pixel
			##global_position = Vector2(round(global_position.x),round(global_position.y))
			#
			##print(Input.get_last_mouse_velocity())
			##var velo = Input.get_last_mouse_velocity() #remove all the calculating mouse velocity and put the velocity check into the check distance and stuff
			##var abs_velo = Vector2(abs(velo.x), abs(velo.y))
			#
			#
			##if velocity == Vector2(0,0) and abs_velo < Vector2(5,5): #remove this if statement
			#
			##this is not getting the position that it is truly settling in
			#PuzzleVar.active_piece = 0
			#selected = false
			#var num = group_number
			#var group = get_tree().get_nodes_in_group("puzzle_pieces")
			##print(group_number)
			#for nodes in group:
				##print("getting group")
				#
				#
				#nodes.global_position = Vector2(nodes.global_position.x, nodes.global_position.y)
				#
				##nodes.global_position = Vector2(round(nodes.global_position.x),round(nodes.global_position.y)) #rounds it so that they are all 
				#nodes.update_coordinates_for_self() #you only need to update the coordinates here to check
				#
				##wait for piece to have a velocity of zero
				##await get_tree().create_timer(.05).timeout #this appears to be working
				#
				##the await function is causing weird things to happen when it is called multiple times in a row by clicking things really fast
				#
				#if nodes.group_number == num: #change this so that it just checks all its children
					##print("check group")
					#nodes.check_connections(group)
			##else:
				##print("don't throw")
				##PuzzleVar.active_piece = 0
				##selected = false

#the code below is for a click drag implementation
#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and PuzzleVar.active_piece:
			#print("release")
			##the issue is here
			#
			#var piece = PuzzleVar.active_piece #see if this will be needed
			#piece.selected = false
			##print(piece.ID)
			#PuzzleVar.active_piece = 0
			#
			#var num = piece.group_number
			#var group = get_tree().get_nodes_in_group("puzzle_pieces")
			#
			#for nodes in group:
				##print("getting group")
				#
				##nodes.global_position = Vector2(nodes.global_position.x, nodes.global_position.y)
				#
				##nodes.global_position = Vector2(round(nodes.global_position.x),round(nodes.global_position.y)) #rounds it so that they are all 
				#nodes.update_coordinates_for_self() #you only need to update the coordinates here to check
				#
				##here check debug flag and then right the piece positions to the database
				#if PuzzleVar.debug:
					##write all piece positions in group to database here
					#print("write to database")
				#
				#
				#
				#if nodes.group_number == num: #change this so that it just checks all its children
					##print("check group")
					#nodes.check_connections(group)



func snap_and_connect(group: Array, direction: String) -> bool: #have this not run until the velocity of the piece is zero
	var connected = false
	
	var coord
	var matching
	var prev_group_number
	
	#may remove the mp variable
	#var mp
	
	if direction == "n":
		coord = NCoord
		matching = NNode.SCoord
		prev_group_number = NNode.group_number
		
		#have a variable here to determine where to respawn the puzzle piece based on global position
		#mp = Vector2(global_position.x, global_position.y + PuzzleVar.pieceHeight)
		
	elif direction == "s":
		coord = SCoord
		matching = SNode.NCoord
		prev_group_number = SNode.group_number
		
		#mp = Vector2(global_position.x, global_position.y - PuzzleVar.pieceHeight)
		
	elif direction == "e":
		coord = ECoord
		matching = ENode.WCoord
		prev_group_number = ENode.group_number
		
		#mp = Vector2(global_position.x + PuzzleVar.pieceWidth, global_position.y)
		
	else: #if west
		coord = WCoord
		matching = WNode.ECoord
		prev_group_number = WNode.group_number
		
		#mp = Vector2(global_position.x - PuzzleVar.pieceWidth, global_position.y)
	
	var dist = calc_distance(coord, matching)
	if dist < snap_distance and dist != 0:
		connected = true
		#print("snap")
		
		$AudioStreamPlayer.play() #need to get rid of the phantom noise for when it can't connect properly
		
		dist = calc_components(coord, matching)
		
		for nodes in group:
			#print(str(nodes.ID)+" and "+str(nodes.group_number))
			
			if nodes.group_number == prev_group_number: #need to see if changing to the child implementation will improve this
				
				#the current issue is that it is shifting everything for some reason, but they do seem to be snapping properly
				
				#instead of shifting the position, just completely reset the position to what it needs to be
				
				#need to make it so that they move to their proper slots
				
				nodes.set_global_position(nodes.get_global_position() - dist)
				#print("shift")
				nodes.group_number = group_number
				#print("if change: "+str(nodes.ID)+" and "+str(nodes.group_number))
		
	return connected



func check_connections(group: Array):
	#need to make it so that it checks for all the connected nodes so that it can connect properly
	
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
		snap_and_connect(group, "w")

# Method to get the piece ID
func get_piece_id() -> int:
	return ID

func bring_to_front():
	original_index = get_index() # Store the original index
	var parent = get_parent()
	parent.remove_child(self) # Remove the piece from its parent
	parent.add_child(self) # Add the piece back to the parent, which places it at the end of the list

func restore_original_index():
	var parent = get_parent()
	parent.move_child(self, original_index) # Move the piece back to its original index

func calc_distance(a: Vector2, b: Vector2) -> int: #may want to double check this function as well
	return ((b.y-a.y)**2 + (b.x-a.x)**2)**0.5
	
func calc_components(a: Vector2, b: Vector2) -> Vector2: #add a check so that it doesn't calculate until the velocity is zero
	return Vector2(b.x-a.x,b.y-a.y)
	
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
		
func update_coordinates_for_self():
	
	#maybe change this so that, the global position is always rounded as well
	
	#maybe have it so that it gets rounded
	#have it so that it waits for velocity to be zero before recalculating this
	if velocity != Vector2(0,0):
		await get_tree().create_timer(.05).timeout
	
	NCoord = global_position + Vector2(PuzzleVar.pieceWidth/2,0) #keep tweaking with this to make sure that they will always be in the same general location
	SCoord = global_position + Vector2(PuzzleVar.pieceWidth/2,PuzzleVar.pieceHeight)
	ECoord = global_position + Vector2(PuzzleVar.pieceWidth,PuzzleVar.pieceHeight/2)
	WCoord = global_position + Vector2(0,PuzzleVar.pieceHeight/2)

func set_appropriate_node():
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	Node_stored = true
	if NID:
		NNode = group[NID-1] #sets up the proper nodes
	if SID:
		SNode = group[SID-1]
	if EID:
		ENode = group[EID-1]
	if WID:
		WNode = group[WID-1]
		
