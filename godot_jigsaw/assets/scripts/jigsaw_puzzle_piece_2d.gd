extends Node2D

#coords of where the borders of the piece are
var NCoord: Vector2 #calculate these using the width and height of the block
var SCoord: Vector2
var ECoord: Vector2
var WCoord: Vector2

#coords of where the borders of the matching pieces are
#var NMatch: Vector2
#var SMatch: Vector2
#var EMatch: Vector2
#var WMatch: Vector2

#ID's that associate with the jigsaw puzzle piece
var NID #if null that means that it doesn't have a matching piece, it is an edge piece
var SID
var EID
var WID


#distance that pieces will snap together within
var snap_distance = 50

var ID: int #piece id for identification

var original_parent
var original_index

# Define the status of the sprite: "none", "clicked", "released", or "dragging".
var selected = false

var group_number #this is the number that will be used to organize it into groups
#var connected_with = []

#var target_position = Vector2()
#var speed = 10000
#var status = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D/Area2D/CollisionShape2D.shape.extents = Vector2(PuzzleVar.pieceWidth,PuzzleVar.pieceHeight)/2 #collision box size set here
	PuzzleVar.active_piece = 0 #0 is false, 1 is true
	#need to set the piece ID
	ID = get_tree().get_nodes_in_group("puzzle_pieces").size()
	group_number = ID
	#instantiate the associated ID matches
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#handle the coordinate changes here
	NCoord = global_position + Vector2(PuzzleVar.pieceWidth/2,0)
	SCoord = global_position + Vector2(PuzzleVar.pieceWidth/2,PuzzleVar.pieceHeight)
	ECoord = global_position + Vector2(PuzzleVar.pieceWidth,PuzzleVar.pieceHeight/2)
	WCoord = global_position + Vector2(0,PuzzleVar.pieceHeight/2)
	
	if selected:
		#global_position = get_global_mouse_position()
		
		var distance = get_global_mouse_position() - global_position
		
		#global_position = global_position + distance
		
		var group = get_tree().get_nodes_in_group("puzzle_pieces")
		#need to iterate through all the nodes and get group_number to move the appropriate ones
		#if they have the same group number as the one that has been selected then all the nodes in the same group move
		
		for nodes in group: #just change this line to accomodate group_number instead of connected_with
			if nodes.group_number == group_number:
				nodes.global_position += distance
	

#func _physics_process(delta):
	##if status == "dragging":
	#if selected:
		##global_position = get_global_mouse_position()
		#
		#var distance = get_global_mouse_position() - global_position
		#
		##global_position = global_position + distance
		#
		#var group = get_tree().get_nodes_in_group("puzzle_pieces")
		##need to iterate through all the nodes and get group_number to move the appropriate ones
		##if they have the same group number as the one that has been selected then all the nodes in the same group move
		#
		#for nodes in group: #just change this line to accomodate group_number instead of connected_with
			#if nodes.group_number == group_number:
				#nodes.global_position += distance
		
		#var direction = (target_position - position).normalized()
		#
		#position += direction * speed * delta
		
		#var distance = get_global_mouse_position() - global_position
		#var curr = global_position
		#calc_components(global_position, get_global_mouse_position())
		#get_global_mouse_position() - global_position
		#global_position = curr + distance
		
		#global_position = lerp(global_position, get_global_mouse_position(),25*delta) #will need to change this so that it moves as the mouse moves, not to the mouse position
		#print(get_piece_id()) #was for testing purposes


#func _input(event):
	#if selected:
		#if event is InputEventMouseMotion:
			#var mous_pos = event.position
			#var delta_vector = event.relative
			#move_nodes_by_delta(delta_vector)
		#
#func move_nodes_by_delta(delta):
	#for node in connected_with:
		#var glob_pos = node.global_position
		#glob_pos += delta
		#node.global_position = glob_pos

func _on_area_2d_input_event(viewport, event, shape_idx):
	if not PuzzleVar.active_piece:
		if Input.is_action_just_pressed("click"):
			
			var group = get_tree().get_nodes_in_group("puzzle_pieces")
			
			#bring_to_front()
			PuzzleVar.active_piece = 1
			selected = true
			
			#clean_connections(group) #this is brutish but seems to work
			
			#if not connected_with.is_empty():
				#for node in connected_with:
					#node.selected = true
		
		#if selected:
			#selected = false
		#else:
			#selected = true
		
		#add toggle if they want to just click hold and then click to release
		
	if Input.is_action_just_released("click"): #comment this out if want to click click
		#restore_original_index() #will change this later so that it remains on the top but for now this will do
		selected = false
		PuzzleVar.active_piece = 0
		
		#if not connected_with.is_empty():
				#for node in connected_with:
					#node.selected = false
			
		#need to get the group
		var group = get_tree().get_nodes_in_group("puzzle_pieces")
		#for i in range(0, group.size()):
			#print(group[i].ID)
		#var test1 = Vector2(10,10)
		#var test2 = Vector2(20,20)
		#print(calc_distance(test1,test2))
		
		
		#will also maybe want to change how you get the nodes in the group
		
		#need to make it so that it checks for all the connected nodes so that it can connect properly
		var stop_checking = false
		
		if NID:
			stop_checking = snap_and_connect(NID, NCoord, group, "n")
			#print(continue_checking)
			#print(NCoord)
			
		if SID and stop_checking == false:
			stop_checking = snap_and_connect(SID, SCoord, group, "s")
				
		if EID and stop_checking == false:
			stop_checking = snap_and_connect(EID, ECoord, group, "e")
				
		if WID and stop_checking == false:
			snap_and_connect(WID, WCoord, group, "w")
			
			
func snap_and_connect(id: int, coord: Vector2, group: Array, direction: String) -> bool: #return true if connected successfully
	#var coord_direction
	
	var connected = false
	
	var matching
	
	if direction == "n":
		#coord_direction = "SCoord"
		matching = group[id-1].SCoord
		#print("snap north")
		
	elif direction == "s":
		#coord_direction = "NCoord"
		matching = group[id-1].NCoord
		#print("snap south")
		
	elif direction == "e":
		#coord_direction = "WCoord"
		matching = group[id-1].WCoord
		#print("snap east")
		
	else:
		#coord_direction = "ECoord"
		matching = group[id-1].ECoord
		#print("snap west")
		
	#var match = group[id-1]
	var dist = calc_distance(coord, matching)
	if dist < snap_distance and dist != 0:
		connected = true
		print("snap")
		dist = calc_components(coord, matching)
		#group[id-1].set_global_position(group[id-1].get_global_position() - dist)
		
		var prev_number = group[id-1].group_number #something is messed up with how I am setting and getting my group number
		
		var iterate = group.duplicate()
		iterate.erase(self)
		
		for nodes in iterate: #need to change this to use group_number
			if nodes.group_number == prev_number:
				nodes.set_global_position(nodes.get_global_position() - dist)
		
		for nodes in group:
			if nodes.group_number == prev_number:
				#iterate.erase(nodes)
				nodes.group_number = group_number
				#print(nodes.group_number)
		#group[id-1].group_number = group_number
		
	return connected
		
		#issue is now here, need to make it so that they snap together properly
		#shift all in group
		
		#need to make it so that all the pieces except for the selected piece move to snap
		#var iterate = group.duplicate()
		#iterate.erase(self)
		
		
		
		
		
		
		
		#if connected_with.count(group[id-1]) == 0: #make more elegant later
			
			#var place_holder = connected_with.duplicate()
			#place_holder.append(group[id-1])
			#place_holder.append_array(group[id-1].connected_with)
			
			#connected_with.append(group[id-1]) #add the connected piece so that they will follow each other
			#connected_with.append_array(group[id-1].connected_with) #connect with other connections
			#
			#for nodes in connected_with:
				#nodes.connected_with.append(group[ID-1]) #add the connected piece so that they will follow each other
				#nodes.connected_with.append_array(group[ID-1].connected_with) #connect with other connections
				##this will lead to a messy array that needs to always be cleaned up on click and unclick
				#clean_connections(group) #this is very brutish
				
				#if nodes.connected_with.count(nodes) > 1:
				#var self_count = nodes.connected_with.count(nodes)
				#for i in range(self_count):
					#nodes.connected_with.erase(nodes) #erase own instance so it doesn't reference itself
				#remove duplicates
				#for k in nodes.connected_with:
					#var counter = nodes.connected_with.count(k)
					#for i in range(counter-1):
						#nodes.connected_with.erase(k)
				#
			#remove reference to itself
			#var self_count = connected_with.count(group[ID-1])
			#for i in range(self_count):
				#connected_with.erase(group[ID-1]) #remove itself from array


#func clean_connections(group: Array): #this is a brutish function but seems to work
	#for nodes in connected_with:
		#var self_count = nodes.connected_with.count(nodes)
		#for i in range(self_count):
			#nodes.connected_with.erase(nodes) #erase own instance so it doesn't reference itself
		##remove duplicates
		#for k in nodes.connected_with:
			#var counter = nodes.connected_with.count(k)
			#for i in range(counter-1):
				#nodes.connected_with.erase(k)
				#
	##remove reference to itself
	#var self_count = connected_with.count(group[ID-1])
	#for i in range(self_count):
		#connected_with.erase(group[ID-1]) #remove itself from array
				
			#connected_with = place_holder
				
			#group[id-1].connected_with.append(group[ID-1])
			
			#for nodes in group[id-1].connected_with:
				#if connected_with.count(nodes) == 0:
					#connected_with.append(nodes)
					#nodes.connected_with.append(group[ID-1])

#func _input(event): #this is all created to handle drag and drop
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			
			#selected = false
			#PuzzleVar.active_piece = 0
			
			#need to get the group
			#var group = get_tree().get_nodes_in_group("puzzle_pieces")
			#for i in range(0, group.size()):
				#print(group[i].ID)
			#var test1 = Vector2(10,10)
			#var test2 = Vector2(20,20)
			#print(calc_distance(test1,test2))
			
			#may need to tweak it as it seems quite janky
			#if NID: #for some reason this is all reversed
				#print(group[NID-1].ID)
				#var NMatch = group[NID-1].SCoord
				#var Ndist = calc_distance(NCoord, NMatch)
				#if Ndist < snap_distance:
					#print("snapN")
			#if SID:
				#var SMatch = group[SID-1].NCoord
				#var Sdist = calc_distance(SCoord, SMatch)
				#if Sdist < snap_distance:
					#print("snapS")
			#if EID:
				#var EMatch = group[EID-1].WCoord
				#var Edist = calc_distance(ECoord, EMatch)
				#if Edist < snap_distance:
					#print("snapE")
			#if WID:
				#var WMatch = group[WID-1].ECoord
				#var Wdist = calc_distance(WCoord, WMatch)
				#if Wdist < snap_distance:
					#print("snapW")
			

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
	
