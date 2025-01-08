extends Control

# this menu is the start screen
# Called when the node enters the scene tree for the first time.
func _ready():	
	# below is where the user anonymous login happens	
	# if the user doesn't need to log in, check their stored auth data
	
	
	if not FireAuth.needs_login():		
		FireAuth.check_auth_file()
		print("\n Account Found: ", FireAuth.get_user_id())
	else:
		# attempt anonymous login if login is required
		print("Making new account")
		FireAuth.attempt_anonymous_login()

			
	# this is where the images in the folder get put into the
	# list PuzzleVar.images for reference
	
	# Prevents pieces from being loaded multiple times
	if(PuzzleVar.open_first_time):
		load(PuzzleVar.path)
		var dir = DirAccess.open(PuzzleVar.path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			# the below code is to parse through the image folder in order to put
			# the appropriate image files into the list for reference for the puzzle
			while file_name != "":
				if !file_name.begins_with(".") and file_name.ends_with(".import"):
					# apend the image into the image list
					PuzzleVar.images.append(file_name.replace(".import",""))
				file_name = dir.get_next()
			
		else:
			print("An error occured trying to access the path")
			
		PuzzleVar.open_first_time = false
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_random_pressed():
	await FireAuth.addUserMode("Single Player")
	$AudioStreamPlayer.play()
	randomize() # initialize a random seed for the random number generator
	# choose a random image from the list PuzzleVar.images
	PuzzleVar.choice = randi_range(0,PuzzleVar.images.size()-1)
	# choose a random size for the puzzle ranging from 2x2 to 10x10
	var val = randi_range(2,10)
	PuzzleVar.col = val
	PuzzleVar.row = val
	# load the texture and get the size of the puzzle image so that the game
	# can slice it up into pieces and start the puzzle
	var image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_size = image_texture.get_size()
	PuzzleVar.size = image_size
	# change to actual game scene
	get_tree().change_scene_to_file("res://assets/scenes/jigsaw_puzzle_1.tscn")

func _on_logged_in() -> void:
	pass

func _on_select_puzzle_pressed():
	$AudioStreamPlayer.play() # doesn't work, switches scenes too fast
	# switches to a new scene  that will ask you to
	# actually select what image you want to solve
	FireAuth.addUserMode("Single Player")
	get_tree().change_scene_to_file("res://assets/scenes/select_puzzle.tscn")


func _on_quit_pressed():
	# quit the game
	$AudioStreamPlayer.play() # doesn't work, quits too fast
	get_tree().quit() # closes the scene tree to leave the game


# this is used to check for events such as a key press
func _input(event):
	if event is InputEventKey and event.pressed and event.echo == false:
		if event.keycode == 68: # if key that is pressed is d
				# toggle debug mode
				PuzzleVar.debug = !PuzzleVar.debug
				if PuzzleVar.debug:
					$Label.show()
				else:
					$Label.hide()
				print("debug mode is: "+str(PuzzleVar.debug))


# this will need to change to have more functionality later
# it is still in a testing phase
func _on_multiplayer_pressed():
	# for now, default to choose a size of 4x4 and use
	# the image of the great wall
	PuzzleVar.col = 4
	PuzzleVar.row = 4
	PuzzleVar.choice = 4
	
	# loads up the images and the sizes needed for the puzzle to happen
	var image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_size = image_texture.get_size()
	PuzzleVar.size = image_size
	FireAuth.addUserMode("Multiplayer")
	
	get_tree().change_scene_to_file("res://assets/scenes/MultiplayerController.tscn")
