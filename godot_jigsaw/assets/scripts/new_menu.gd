extends Control

@export var ADDRESS = "127.0.0.1"
@export var PORT = 1235
var image_texture #Stores image of puzzle
var image_size #Store size of image

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#this is where the images in the folder get put into the array for reference
	var dir = DirAccess.open(PuzzleVar.path) #maybe see if can simplify later
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !file_name.begins_with(".") and !file_name.ends_with(".import"):
				PuzzleVar.images.append(file_name) #append the image into the image list
			file_name = dir.get_next()
		
	else:
		print("An error occured trying to access the path")
		
	#Randomize puzzle selection if no puzzle is selected
	if PuzzleVar.choice == -1:
		randomize()
		PuzzleVar.choice = randi_range(0,PuzzleVar.images.size()-1)
		
	
	#MULTIPLAYER CONNECTIONs
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_server_connection)
	multiplayer.connection_failed.connect(_on_connection_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnect)
	
func _on_peer_connected(id:int):
	print("Player Connected: %s" % id)
	
func _on_peer_disconnected(id:int):
	pass
	
func _on_server_connection():
	pass
	
func _on_connection_fail():
	pass
	
func _on_server_disconnect():
	pass
	
func start_puzzle():
	get_tree().change_scene_to_file("res://assets/scenes/world.tscn")

func _on_start_random_pressed():
	#need to change to a new scene that is a random game
	image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	image_size = image_texture.get_size()
	PuzzleVar.size = image_size	
	start_puzzle()

func _on_select_puzzle_pressed():
	#need to change to do a new scene that is the selection screen for a puzzle
	get_tree().change_scene_to_file("res://assets/scenes/select_puzzle.tscn")

func _on_quit_pressed():
	#quit the game
	#get_tree().root.propogate_notification(NOTIFICATION_WM_CLOSE_REQUEST) #should figure out what this does
	get_tree().quit()


func _on_host_button_button_down():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 4)
	if error:
		print("Hosting Error: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) #Godot's built-in Compression Algorithm
	multiplayer.set_multiplayer_peer(peer)
	print("Now Hosting")
	pass


func _on_join_button_button_down():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ADDRESS, PORT)
	if error:
		print("Cannot join")
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Now Joining")
	pass
	
	# Handle esc
func _input(event):
	# Check if the event is a key press event
	if event is InputEventKey:
		# Check if the pressed key is the Escape key
		if event.keycode == KEY_ESCAPE:
			# Exit the game
			get_tree().quit()

func _on_row_value_changed(value):
	PuzzleVar.row = value
	PuzzleVar.col = value
	%PieceNumberLabel.format_string = "Number of Pieces: %d" % (value * value)
	
