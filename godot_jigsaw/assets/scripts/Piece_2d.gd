extends Node2D

# this scene is each individual puzzle piece that can snap together to form
# the jigsaw

# neighbor list
var neighbor_list = {} # This is the list of neighboring IDs for a piece.

# distance that pieces will snap together within
var snap_threshold = 25

var ID: int # The actual ID of the current puzzle piece

# this is for becomes true when the piece is clicked on and is used for movement
# this becomes false when the piece is set down by the player
var selected = false

# this is the number that will be used to organize
#	all the pieces into groups so that they all move in tandem
var group_number

# height and width of this puzzle piece
var piece_height
var piece_width

# to calculate velocity:
var prev_position = Vector2()
var velocity = Vector2()

var is_muted
var mute_button: Button
var unmute_button : Button

# Figure out if user finished the puzzle
#var finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	PuzzleVar.active_piece = 0 # 0 is false, any other number is true
	
	group_number = ID # group number is initially set to the piece ID
	prev_position = position # this is to calculate velocity
	mute_sound()
		
	neighbor_list = 	PuzzleVar.adjacent_pieces_list[str(ID)] # set the list of adjacent pieces

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = (position - prev_position) / delta # velocity is calculated here
	prev_position = position


# this is the actual logic to move a piece when you select it
@rpc("any_peer", "call_local")
func move(distance: Vector2):
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	for node in group:
		if node.group_number == group_number:
			node.global_position += distance

#this is called whenever an event occurs within the area of the piece
#	Example events include a key press within the area of the piece or
#	a piece being clicked or even mouse movement
func _on_area_2d_input_event(viewport, event, shape_idx):
	# check if the event is a mouse button and see if it is pressed
	if event is InputEventMouseButton and event.pressed:
		# check if it was the left button pressed
		if event.button_index == MOUSE_BUTTON_LEFT:
			# if no other puzzle piece is currently active
			if not PuzzleVar.active_piece:
				# if this piece is currently not selected
				if selected == false:
					# get all nodes from puzzle pieces
					var all_pieces = get_tree().get_nodes_in_group("puzzle_pieces")
					
					# grab all pieces in the same group number
					for piece in all_pieces:
						if piece.group_number == group_number:
							piece.bring_to_front()
					# set this piece as the active puzzle piece
					PuzzleVar.active_piece = self
					# mark as selected
					selected = true
					
			# if a piece is already selected
			else:
				var run_delay = false # if true, pause after so another mouse event is not detected
				
				if selected == true:
					# deselect the current piece
					selected = false
					# clear active piece reference
					PuzzleVar.active_piece = 0
					
					run_delay = true
			
				# get all nodes from puzzle pieces
				var all_pieces = get_tree().get_nodes_in_group("puzzle_pieces")
				var num = group_number
				#print ("current group number: " + str(num))
				var connection_found = false
			
				for node in all_pieces: 
					if node.group_number == group_number:
						var n_list = node.neighbor_list
						#run through each of the pieces that should be adjacent to the selected piece
						#for adjacent_piece in neighbor_list:
						for adjacent_piece in n_list:
							#print (adjacent_piece)
							var adjacent_node = PuzzleVar.ordered_pieces_array[int(adjacent_piece)]
							#print ("adjacent node:" + str(adjacent_node.ID))
							if await check_connections(adjacent_node.ID) == true:
								run_delay = true # run a delay afterward if there was a connection found
				
				# the following loop is where the actual match checking occurs
				for piece in all_pieces:
					# TODO: here check debug flag and then write the piece positions to the database
					if PuzzleVar.debug:
					# write all piece positions in group to database here
						print("write to database")
				
			# Set to original color from gray/transparent movement for all players, Peter Nguyen
			rpc("remove_transparency")


# this is where the actual movement of the puzzle piece is handled
# when the mouse moves
func _input(event):
	if event is InputEventMouseMotion and selected == true:
		# Peter Nguyen adding transparent effect
		rpc("apply_transparency")
		
		var distance = get_global_mouse_position() - global_position
		# move is called as an rpc function so that both the host and client
		# in a multiplayer game can see the movement
		move.rpc(distance)
		

# this is a basic function to check if a side can snap to another side of a
# puzzle piece
func snap_and_connect(adjacent_piece_id: int):
	var group = get_tree().get_nodes_in_group("puzzle_pieces") # group is all the pieces
	var prev_group_number
	
	var new_group_number = group_number
	
	# Get the global position of the current node
	var current_global_pos = self.get_global_position() # coordinates centered on the piece
	var current_ref_coord = PuzzleVar.global_coordinates_list[str(ID)]
	
	# get the global position of the adjacent node
	var adjacent_node = PuzzleVar.ordered_pieces_array[adjacent_piece_id]
	var adjacent_global_pos = adjacent_node.get_global_position() # coordinates centered on the piece
	
	var adjacent_ref_coord = PuzzleVar.global_coordinates_list[str(adjacent_piece_id)]
	
	prev_group_number = adjacent_node.group_number
	
	#calculate the amount to move the current piece to snap
	var ref_upper_left_diff = Vector2(current_ref_coord[0]-adjacent_ref_coord[0], current_ref_coord[1]-adjacent_ref_coord[1])
	
	# compute the upper left position of the current piece
	var adjusted_current_left_x = current_global_pos[0] - (piece_width/2)
	var adjusted_current_left_y = current_global_pos[1] - (piece_height/2)
	var adjusted_current_upper_left = Vector2(adjusted_current_left_x, adjusted_current_left_y)
	
	#compute the upper left position of the adjacent piece
	var adjusted_adjacent_left_x = adjacent_global_pos[0] - (adjacent_node.piece_width/2)
	var adjusted_adjacent_left_y = adjacent_global_pos[1] - (adjacent_node.piece_height/2)
	var adjusted_adjacent_upper_left = Vector2(adjusted_adjacent_left_x, adjusted_adjacent_left_y)
	
	var current_left_diff = Vector2(adjusted_current_upper_left - adjusted_adjacent_upper_left)
	var dist = current_left_diff - ref_upper_left_diff
	print ("dist: " + str(dist))
	
	if dist[0] > 0.001 or dist[0] < -0.001: # if there was a snapping movement, then play the sound and check
		# Calculate the midpoint between the two connecting sides
		var green_check_midpoint = (current_global_pos + adjacent_global_pos) / 2
		# Pass the midpoint to show_image_on_snap() so the green checkmark appears
		show_image_on_snap(green_check_midpoint)
		play_sound()
	
	# here is the code to decide which group to move
	# this code will have it so that the smaller group will always
	# move to the larger group to snap and connect
	var countprev = 0
	var countcurr = 0
	
	for node in group:
		if node.group_number == group_number:
			countcurr += 1
		elif node.group_number == prev_group_number:
			countprev += 1
			
	#if countcurr < countprev:
		#new_group_number = prev_group_number
		#prev_group_number = group_number
		#dist *= -1
	
	# The function below is called to physically move the piece and join it to the 
	# appropriate group.  This is an rpc call so that the movement and joining of 
	# the group is reflected for all players in a multiplayer game
	move_pieces_to_connect.rpc(dist, prev_group_number, new_group_number)
	
	var finished = true
	
	for node in group:
		if node.group_number != group_number:
			finished = false
			break
	
	if (finished):
		show_win_screen()
		FireAuth.remove_current_user_from_activePuzzle(FireAuth.get_current_puzzle())


# This is the function that actually moves the piece (in the current group)
# to connect it and is called as an rpc so that it can be reflected for all players
@rpc("any_peer", "call_local")
func move_pieces_to_connect(distance: Vector2, prev_group_number: int, new_group_number: int):
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	var show_check_mark = false
	for node in group:
		
		if node.group_number == prev_group_number:
			# this is where the piece is actually moved so
			# that it looks like it is connecting, this is also where
			# the proper group number is associated with the piece so that it
			# moves in tandem with the other joined pieces
			node.set_global_position(node.get_global_position() + distance)
			node.group_number = new_group_number
			show_check_mark = true

func check_connections(adjacent_piece_ID: int) -> bool:
	var snap_found = false
	
	# this if statement below is so that the piece stops moving so that the
	# position remains constant when it checks for an available connection
	if velocity != Vector2(0,0):
		await get_tree().create_timer(.05).timeout
		
	#get reference bounding box for current piece (in coordinate from the image)
	var current_ref_bounding_box = PuzzleVar.global_coordinates_list[str(ID)]
	var current_ref_midpoint = Vector2((current_ref_bounding_box[2] + current_ref_bounding_box[0]) / 2, 
	(current_ref_bounding_box[3] + current_ref_bounding_box[1]) / 2)
	
	#compute dynamic positions
	var current_global_position = self.global_position # this is centered on the piece
	var adjusted_current_left_x = current_global_position[0] - (piece_width/2) # adjust to upper left corner
	var adjusted_current_left_y = current_global_position[1] - (piece_height/2) # adjust to upper left corner
	var adjusted_current_upper_left = Vector2(adjusted_current_left_x, adjusted_current_left_y)
	#print ("adjusted current upper left: " + str(adjusted_current_upper_left))
	
	#get reference bounding box for adjacent piece (in coordinates from the image)
	var adjacent_ref_bounding_box = PuzzleVar.global_coordinates_list[str(adjacent_piece_ID)]
	var adjacent_ref_midpoint = Vector2((adjacent_ref_bounding_box[2] + adjacent_ref_bounding_box[0]) / 2, 
	(adjacent_ref_bounding_box[3] + adjacent_ref_bounding_box[1]) / 2)
	
	#compute dynamic positions for adjacent piece
	var adjacent_node = PuzzleVar.ordered_pieces_array[adjacent_piece_ID]
	var adjacent_global_position = adjacent_node.global_position # these coordinates are centered on the piece
	var adjusted_adjacent_left_x = adjacent_global_position[0] - (adjacent_node.piece_width/2) # adjust to the upper left corner
	var adjusted_adjacent_left_y = adjacent_global_position[1] - (adjacent_node.piece_height/2) # adjust to the upper left corner
	var adjusted_adjacent_upper_left = Vector2(adjusted_adjacent_left_x, adjusted_adjacent_left_y)
	#print ("adjusted adjacent upper left: " + str(adjusted_adjacent_upper_left))
	
	#compute slope of midpoints - the slope of the midpoints is used to determine the direction of
	#snapping to the adjacent piece (right,left,top,bottom) 
	var slope = (adjacent_ref_midpoint[1] - current_ref_midpoint[1]) / (adjacent_ref_midpoint[0] - current_ref_midpoint[0])
	#print (slope)
	
	#compute the relative position difference (of the center points) 
	# between the current piece and adjacent
	var current_relative_position = current_global_position - adjacent_global_position
	
	#compute the relative position difference between the matching pieces in the reference image
	var current_ref_upper_left = Vector2(current_ref_bounding_box[0], current_ref_bounding_box[1])
	var adjacent_ref_upper_left = Vector2(adjacent_ref_bounding_box[0], adjacent_ref_bounding_box[1])
	var ref_relative_position = current_ref_upper_left - adjacent_ref_upper_left
	#print ("ref relative_position:" + str(ref_relative_position))
	
	#compute the difference in the relative position between reference and actual bounding boxes
	#This snap distance is how much the piece needs to be moved to be in the correct location
	var snap_distance =	 calc_distance(ref_relative_position, adjusted_current_upper_left-adjusted_adjacent_upper_left)
	print("snap distance: " + str(snap_distance))
	
	# The following if-statement checks for snapping in 4 directions
	if slope < 2 and slope > -2: #if the midpoints are on the same Y value
		if current_ref_midpoint[0] > adjacent_ref_midpoint[0]: #if the current piece is to the right
			if (snap_distance < snap_threshold):  #pieces are close, so connect
				print("----snapping----")
				print ("right to left snap:" + str(ID) + "-->" + str(adjacent_piece_ID))
				print("current_ref_upper_left: " + str(current_ref_upper_left))
				print("adjacent_ref_upper_left: " + str(adjacent_ref_upper_left))
				print ("current global position: " + str(adjusted_current_upper_left))
				print ("adjacent global position: " + str(adjusted_adjacent_upper_left))
				print ("current sprite rect: " + str($Sprite2D/Area2D/CollisionShape2D.shape.extents * 2))
				print("snap_distance: " + str(snap_distance))
				snap_and_connect(adjacent_piece_ID)
				print("----snapping----")
				snap_found = true
				#print ("snap_distance: " + str(snap_distance))
		else: #if the current piece is to the left
			if (snap_distance < snap_threshold):
				print ("left to right snap:" + str(ID) + "-->" + str(adjacent_piece_ID))
				snap_and_connect(adjacent_piece_ID)
				snap_found = true
	else: #if the midpoints are on the same X value
		if current_ref_midpoint[1] > adjacent_ref_midpoint[1]: #if the current piece is below
			if (snap_distance < snap_threshold):
				print ("bottom to top snap: " + str(ID) + "-->" + str(adjacent_piece_ID))
				snap_and_connect(adjacent_piece_ID)
				snap_found = true
		else: #if the current piece is above
			if (snap_distance < snap_threshold):
				print ("top to bottom snap: " + str(ID) + "-->" + str(adjacent_piece_ID))
				snap_and_connect(adjacent_piece_ID)
				snap_found = true
				
	if snap_found == true:
		return true
			
	return false


# this is the function that brings the piece to the front of the screen
func bring_to_front():
	var parent = get_parent()
	# removes the piece from the screen
	parent.remove_child(self) # Remove the piece from its parent
	# adds the piece back to the screen so that it looks like it is on top
	parent.add_child(self)

# this function calculates the distance between two points and returns the
# distance as a scalar value
func calc_distance(a: Vector2, b: Vector2) -> float:
	return ((b.y-a.y)**2 + (b.x-a.x)**2)**0.5
	
# this function calculates the distance between two points and returns the
# distance as a vector
func calc_components(a: Vector2, b: Vector2) -> Vector2:
	return Vector2(b.x-a.x,b.y-a.y)

func show_image_on_snap(position: Vector2): # Peter Nguyen wrote this function
	var popup = Sprite2D.new()
	# Load texture
	popup.texture = preload("res://assets/images/checkmark2.0.png")
	
	# Center the sprite in the viewport
	popup.position = get_viewport().get_visible_rect().size / 2
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

#Logic for showing the winning labels and buttons
func show_win_screen():
	#-------------------------LABEL LOGIC------------------------#
	var label = Label.new()
	
	# Set the text for the Label
	label.text = "You've Finished the Puzzle!"
	
	# Set the font size as well as the color
	label.add_theme_font_size_override("font_size", 200)
	label.add_theme_color_override("font_color", Color(0, 204, 0))
	
	# Load the font file 
	var font = load("res://assets/fonts/KiriFont.ttf") as FontFile
	label.add_theme_font_override("font", font)
	
	# Change label poistion and add the label to the current scene
	label.position = Vector2(-1000, -400)
	get_tree().current_scene.add_child(label)

	#-------------------------BUTTON LOGIC-----------------------#
	var button = Button.new()
	# Change the position, size, text, and image of button
	button.text = "Main Menu"
	## Set the font type for the Button
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", 150)
	
	#Load button texture
	var button_texture = StyleBoxTexture.new()
	var texture = preload("res://assets/images/wood_button_normal.png")
	
	# Adjust the content margins of the style box
	button_texture.content_margin_left = 350  # Adjust left margin
	button_texture.content_margin_top = 350   # Adjust top margin
	button_texture.content_margin_right = 350  # Adjust right margin
	button_texture.content_margin_bottom = 350  # Adjust bottom margin

	# Load the button_pressed texture
	var hover_texture = preload("res://assets/images/wood_button_pressed.png")

	# Configure hovered state style box
	var hover_stylebox = StyleBoxTexture.new()
	hover_stylebox.texture = hover_texture
	hover_stylebox.content_margin_left = 350
	hover_stylebox.content_margin_top = 350
	hover_stylebox.content_margin_right = 350
	hover_stylebox.content_margin_bottom = 350
	button.add_theme_stylebox_override("hover", hover_stylebox)

	#Apply the texture to the button and stylebox
	button_texture.texture = texture
	button.add_theme_stylebox_override("normal", button_texture)
	button.position = Vector2(0, -200)
	
	var empty_stylebox = StyleBoxEmpty.new()
	button.add_theme_stylebox_override("focus", empty_stylebox)
	button.add_theme_stylebox_override("pressed", empty_stylebox)
	
	# Connect the button's pressed signal to the scene change function
	button.connect("pressed", Callable(self, "on_button_pressed")) 
	#Add button to the scene
	get_tree().current_scene.add_child(button)
 
# Function to change scenes when button is pressed
func on_button_pressed():
	# Load the new scene
	await get_tree().create_timer(2.0).timeout
	#_ready()
	reset_puzzle_state()
	get_tree().change_scene_to_file("res://assets/scenes/new_menu.tscn")
	get_tree().reload_current_scene()

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

#This function clears all puzzle pieces and resets global variables
func reset_puzzle_state():
	# Get all puzzle pieces and remove them
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	for nodes in group:
		nodes.queue_free() # Removes puzzle pieces from the scene
	
	# Reset global variables related to the puzzle
	PuzzleVar.active_piece = 0
	#Node_association_complete = false
	prev_position = Vector2()
	velocity = Vector2()
  
func play_sound(): # Peter Nguyen
	var snap_sound = preload("res://assets/sounds/ding.mp3")
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = snap_sound
	add_child(audio_player)
	audio_player.play()
	# Manually queue_free after sound finishes
	await audio_player.finished
	audio_player.queue_free()
	
func mute_sound(): # Ray Lui
	
	mute_button = Button.new()
	mute_button.text = "Mute"
	unmute_button = Button.new()
	unmute_button.text = "Unmute"
	# loading in the font to use for text
	var font = load("res://assets/fonts/KiriFont.ttf") as FontFile
	# Set the font type for the Button
	mute_button.add_theme_font_override("font", font)
	# Setting the font size
	mute_button.add_theme_font_size_override("font_size", 60)
	
	unmute_button.add_theme_font_override("font", font)
	# Setting the font size
	unmute_button.add_theme_font_size_override("font_size", 60)
	# Load button texture
	var button_texture = StyleBoxTexture.new()
	var texture = preload("res://assets/images/wood_button_normal.png")
	
	# Adjust the content margins of the style box
	button_texture.content_margin_left = 200  # Adjust left margin
	button_texture.content_margin_top = 200   # Adjust top margin
	button_texture.content_margin_right = 200  # Adjust right margin
	button_texture.content_margin_bottom = 200  # Adjust bottom margin
	#Apply the texture to the button and stylebox
	button_texture.texture = texture
	mute_button.add_theme_stylebox_override("normal", button_texture)
	unmute_button.add_theme_stylebox_override("normal", button_texture)

	# Load the button_pressed texture
	var hover_texture = preload("res://assets/images/wood_button_pressed.png")
	# Configure hovered state style box
	var hover_stylebox = StyleBoxTexture.new()
	hover_stylebox.texture = hover_texture
	hover_stylebox.content_margin_left = 200
	hover_stylebox.content_margin_top = 200
	hover_stylebox.content_margin_right = 200
	hover_stylebox.content_margin_bottom = 200
	mute_button.add_theme_stylebox_override("hover", hover_stylebox)
	# Set text colors for normal and hover states
	mute_button.add_theme_color_override("font_color", Color(1, 1, 1))  # Normal state (white)
	mute_button.add_theme_color_override("font_color_hover", Color(0.8, 0.8, 0.0))  # Hover state (yellow)
	
	unmute_button.add_theme_stylebox_override("hover", hover_stylebox)
	# Set text colors for normal and hover states
	unmute_button.add_theme_color_override("font_color", Color(1, 1, 1))  # Normal state (white)
	unmute_button.add_theme_color_override("font_color_hover", Color(0.8, 0.8, 0.0))  # Hover state (yellow)

	var empty_stylebox = StyleBoxEmpty.new()
	mute_button.add_theme_stylebox_override("focus", empty_stylebox)
	mute_button.add_theme_stylebox_override("pressed", empty_stylebox)
	mute_button.position = Vector2(-1650, 1700)
	mute_button.scale = Vector2(1, 1)
	
	unmute_button.add_theme_stylebox_override("focus", empty_stylebox)
	unmute_button.add_theme_stylebox_override("pressed", empty_stylebox)
	unmute_button.position = Vector2(-1650, 1400)
	unmute_button.scale = Vector2(1, 1)
		
	# Connect the button's pressed signal to the scene change function
	mute_button.connect("pressed", Callable(self, "on_mute_button_press")) 
	unmute_button.connect("pressed", Callable(self, "on_unmute_button_press")) 
	#Add button to the scene
	get_tree().current_scene.add_child(mute_button)
	get_tree().current_scene.add_child(unmute_button)
	
func on_mute_button_press():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)  # Mute the audio
		
func on_unmute_button_press():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)  # Mute the audio
