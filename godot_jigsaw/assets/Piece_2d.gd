extends Node2D

#coords of where the borders of the piece are
var NCoord: Vector2 #calculate these using the width and height of the block
var SCoord: Vector2
var ECoord: Vector2
var WCoord: Vector2

#ID's that associate with the jigsaw puzzle piece
var NID #if null that means that it doesn't have a matching piece, it is an edge piece
var SID
var EID
var WID #see if can cut out later

#store the actual nodes as the appropriate matches
var NNode #if null that means there isn't a matching piece
var SNode
var ENode
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
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#handle the coordinate changes here
	update_coordinates_for_self()
	velocity = (position - prev_position) / delta
	prev_position = position
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	
	
	if Node_stored == false and group.size() == PuzzleVar.col * PuzzleVar.row:
		#this should result in them having proper matching and snapping
		set_appropriate_node()
			
	if selected:
		#global_position = get_global_mouse_position()
		#print(velocity)
		var distance = get_global_mouse_position() - global_position
		
		#global_position = global_position + distance
		#need to iterate through all the nodes and get group_number to move the appropriate ones
		#if they have the same group number as the one that has been selected then all the nodes in the same group move
		
		for nodes in group:
			if nodes.group_number == group_number:
				nodes.global_position += distance


func _on_area_2d_input_event(viewport, event, shape_idx):
	if not PuzzleVar.active_piece:
		if Input.is_action_just_pressed("click"):
			bring_to_front() #maybe bring all the pieces in the group to front later once other errors have been figured out
			PuzzleVar.active_piece = 1
			selected = true
	
	if PuzzleVar.active_piece: #this fixes the multiple click issue
		
		#try to get the velocity of he piece itself
		#need to calculate the speed of the sprite
		
		#don't use mouse velocity, use sprite velocity
		
		#var velo = Input.get_last_mouse_velocity()
		#print(velo)
		#var abs_velo = Vector2(abs(velo.x),abs(velo.y))
		
		
		#if abs_velo > Vector2(500,500):
			#PuzzleVar.active_piece = 0
			#selected = false
			
		if Input.is_action_just_released("click"):
			print(Input.get_last_mouse_velocity())
			var velo = Input.get_last_mouse_velocity()
			var abs_velo = Vector2(abs(velo.x), abs(velo.y))
			if velocity == Vector2(0,0) and abs_velo < Vector2(5,5): #other people can change and adjust this to make it better
			
				#this is not getting the position that it is truly settling in
				PuzzleVar.active_piece = 0
				selected = false
				var num = group_number
				var group = get_tree().get_nodes_in_group("puzzle_pieces")
				#print(group_number)
				for nodes in group:
					#print("getting group")
					if nodes.group_number == num:
						#print("check group")
						nodes.check_connections(group)
			else:
				print("don't throw")
				PuzzleVar.active_piece = 0
				selected = false
			
			
		
		#if Input.is_action_just_released("click"):
			#if Input.get_last_mouse_velocity() < Vector2(10,10):
				##this is not getting the position that it is truly settling in
				#PuzzleVar.active_piece = 0
				#selected = false
				#var num = group_number
				#var group = get_tree().get_nodes_in_group("puzzle_pieces")
				##print(group_number)
				#for nodes in group:
					##print("getting group")
					#if nodes.group_number == num:
						##print("check group")
						#nodes.check_connections(group)
			#else:
				#PuzzleVar.active_piece = 0
				#selected = false
					
			#align_groups(group)


func snap_and_connect(group: Array, direction: String) -> bool:
	var connected = false
	
	var coord
	var matching
	var prev_group_number
	
	if direction == "n":
		coord = NCoord
		matching = NNode.SCoord
		prev_group_number = NNode.group_number
	elif direction == "s":
		coord = SCoord
		matching = SNode.NCoord
		prev_group_number = SNode.group_number
	elif direction == "e":
		coord = ECoord
		matching = ENode.WCoord
		prev_group_number = ENode.group_number
	else: #if west
		coord = WCoord
		matching = WNode.ECoord
		prev_group_number = WNode.group_number
	
	var dist = calc_distance(coord, matching)
	if dist < snap_distance and dist != 0:
		connected = true
		#print("snap")
		dist = calc_components(coord, matching)
		
		for nodes in group:
			#print(str(nodes.ID)+" and "+str(nodes.group_number))
			
			if nodes.group_number == prev_group_number:
				nodes.set_global_position(nodes.get_global_position() - dist)
				#print("shift")
				nodes.group_number = group_number
				#print("if change: "+str(nodes.ID)+" and "+str(nodes.group_number))
		
	return connected



func check_connections(group: Array):
	#need to make it so that it checks for all the connected nodes so that it can connect properly
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
	
func calc_components(a: Vector2, b: Vector2) -> Vector2:
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
	NCoord = global_position + Vector2(PuzzleVar.pieceWidth/2,0) #make it so that they round
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
		
#prev is the node that was previously called, curr is the node that is currently in play
func align_groups(group: Array): #this will trigger upon moving and releasing a piece or block and will only affect those pieces and blocks in that group
	#start by aligning all the pieces around the selected piece so that they are all in proper line
	group.sort_custom(sort_by_ID) #start by sorting the group
	for nodes in group:
		if nodes.group_number == group_number:
			if nodes.NNode and nodes.NNode.group_number == group_number:
				print("align north"+str(nodes.ID)+" "+str(nodes.group_number))
				var dist = calc_distance(nodes.NCoord, nodes.NNode.SCoord)
				if dist > .25:
					print("Nshift")
					dist = calc_components(nodes.NCoord, nodes.NNode.SCoord)
					nodes.NNode.set_global_position(nodes.NNode.get_global_position() - dist)
			if nodes.SNode and nodes.SNode.group_number == group_number:
				print("align south"+str(nodes.ID)+" "+str(nodes.group_number))
				var dist = calc_distance(nodes.SCoord, nodes.SNode.NCoord)
				if dist > .25:
					print("SShift")
					dist = calc_components(nodes.SCoord, nodes.SNode.NCoord)
					nodes.SNode.set_global_position(nodes.SNode.get_global_position() - dist)
			#if nodes.ENode and nodes.ENode.group_number == group_number:
				#print("align east"+str(nodes.ID)+" "+str(nodes.group_number))
				#var dist = calc_distance(nodes.ECoord, nodes.ENode.WCoord)
				#if dist > .25:
					#print("EShift")
					#dist = calc_components(nodes.ECoord, nodes.ENode.WCoord)
					#nodes.ENode.set_global_position(nodes.ENode.get_global_position() - dist)
			if nodes.WNode and nodes.WNode.group_number == group_number:
				print("align west"+str(nodes.ID)+" "+str(nodes.group_number))
				var dist = calc_distance(nodes.WCoord, nodes.WNode.ECoord)
				if dist > 1:
					print("WShift")
					dist = calc_components(nodes.WCoord, nodes.WNode.ECoord)
					nodes.WNode.set_global_position(nodes.WNode.get_global_position() - dist)
	
	
	
	#if curr.NNode and curr.NNode != prev:
		#if curr.NNode.group_number == group_number:
			#var dist = calc_components(curr.NCoord, curr.NNode.SCoord)
			#if dist != Vector2(0,0):
				#curr.NNode.set_global_position(curr.NNode.get_global_position() - dist)
			#align_groups(curr, curr.NNode, group)
	#if curr.SNode and curr.SNode != prev:
		#if curr.SNode.group_number == group_number:
			#var dist = calc_components(curr.SCoord, curr.SNode.NCoord)
			#if dist != Vector2(0,0):
				#curr.SNode.set_global_position(curr.SNode.get_global_position() - dist)
			#align_groups(curr, curr.SNode, group)
	#if curr.ENode and curr.ENode != prev:
		#if curr.ENode.group_number == group_number:
			#var dist = calc_components(curr.ECoord, curr.ENode.WCoord)
			#if dist != Vector2(0,0):
				#curr.ENode.set_global_position(curr.ENode.get_global_position() - dist)
			#align_groups(curr, curr.ENode, group)
	#if curr.WNode and curr.WNode != prev:
		#if curr.WNode.group_number == group_number:
			#var dist = calc_components(curr.WCoord, curr.WNode.ECoord)
			#if dist != Vector2(0,0):
				#curr.WNode.set_global_position(curr.WNode.get_global_position() - dist)
			#align_groups(curr, curr.WNode, group)
	
	#the current issue for the above code is that when the puzzle is completed it starts to do infinite recursion
	
	#for nodes in group:
		#if nodes.group_number == group_number and nodes != self: #this doesn't work currently, need to make it so that all the pieces move to align with the piece that I pick
			#if nodes.NNode:
				#if nodes.NNode.group_number == group_number:
					#var dist = calc_distance(nodes.NCoord, nodes.NNode.SCoord)
					#if dist != 0:
						#dist = calc_components(nodes.NCoord, nodes.NNode.SCoord)
						#nodes.NNode.set_global_position(nodes.NNode.get_global_position() - dist)
			#if nodes.SNode:
				#if nodes.SNode.group_number == group_number:
					#var dist = calc_distance(nodes.SCoord, nodes.SNode.NCoord)
					#if dist != 0:
						#dist = calc_components(nodes.SCoord, nodes.SNode.NCoord)
						#nodes.SNode.set_global_position(nodes.SNode.get_global_position() - dist)
			#if nodes.ENode:
				#if nodes.ENode.group_number == group_number:
					#var dist = calc_distance(nodes.ECoord, nodes.ENode.WCoord)
					#if dist != 0:
						#dist = calc_components(nodes.ECoord, nodes.ENode.WCoord)
						#nodes.ENode.set_global_position(nodes.ENode.get_global_position() - dist)
			#if nodes.WNode:
				#if nodes.WNode.group_number == group_number:
					#var dist = calc_distance(nodes.WCoord, nodes.WNode.ECoord)
					#if dist != 0:
						#dist = calc_components(nodes.WCoord, nodes.WNode.ECoord)
						#nodes.WNode.set_global_position(nodes.WNode.get_global_position() - dist)

func sort_by_ID(a,b):
	if a.get_piece_id() < b.get_piece_id():
		return true
	return false
