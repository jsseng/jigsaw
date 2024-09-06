extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	
	#this is where the images in the folder get put into the array for reference
	
	#for some reason there is a leak at exit, the issue is somewhere, but I'm not sure
	
	load(PuzzleVar.path) #use @GD load
	var dir = DirAccess.open(PuzzleVar.path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !file_name.begins_with(".") and file_name.ends_with(".import"):
				PuzzleVar.images.append(file_name.replace(".import","")) #append the image into the image list
			file_name = dir.get_next()
		
	else:
		print("An error occured trying to access the path")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_random_pressed():
	#need to change to a new scene that is a random game
	
	$AudioStreamPlayer.play() #works
	
	randomize()
	
	PuzzleVar.choice = randi_range(0,PuzzleVar.images.size()-1) #choose a random image to use
	var val = randi_range(2,10)
	PuzzleVar.col = val
	PuzzleVar.row = val
	
	var image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_size = image_texture.get_size()
	PuzzleVar.size = image_size
	
	get_tree().change_scene_to_file("res://assets/scenes/jigsaw_puzzle_1.tscn") #this may keep changing
	#get_tree().change_scene_to_file("res://assets/scenes/world.tscn") #for testing

func _on_select_puzzle_pressed():
	#need to change to do a new scene that is the selection screen for a puzzle
	$AudioStreamPlayer.play() #doesn't work
	get_tree().change_scene_to_file("res://assets/scenes/select_puzzle.tscn")

func _on_quit_pressed():
	#quit the game
	#get_tree().root.propogate_notification(NOTIFICATION_WM_CLOSE_REQUEST) #should figure out what this does
	$AudioStreamPlayer.play() #doesn't work
	get_tree().quit()

func _input(event):
	if event is InputEventKey and event.pressed and event.echo == false:
		#print(event.keycode)
		if event.keycode == 68: #if key is d
				PuzzleVar.debug = !PuzzleVar.debug
				if PuzzleVar.debug:
					$Label.show()
				else:
					$Label.hide()
				#print("debug mode activated")
				print("debug mode is: "+str(PuzzleVar.debug))

func _on_tree_exiting():
	#place a destructor here maybe
	pass


func _on_multiplayer_pressed():
	#for now, default to choose a size of 16 and the great wall
	PuzzleVar.col = 4
	PuzzleVar.row = 4
	
	PuzzleVar.choice = 4
	
	var image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_size = image_texture.get_size()
	PuzzleVar.size = image_size
	
	get_tree().change_scene_to_file("res://assets/scenes/MultiplayerController.tscn")
	pass # Replace with function body.
