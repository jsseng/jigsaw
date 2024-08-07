extends Control



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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_random_pressed():
	var auth = Firebase.Auth.auth
	var timestamp = Time.get_unix_time_from_system()
	var collection: FirestoreCollection = Firebase.Firestore.collection(auth.localid)
	var add_task = await collection.add("user", {'time': timestamp, 'name': auth.localid})
	#need to change to a new scene that is a random game
	randomize()
	
	PuzzleVar.choice = randi_range(0,PuzzleVar.images.size()-1)
	
	get_tree().change_scene_to_file("res://assets/scenes/menu.tscn") #this is filler for now

func _on_select_puzzle_pressed():
	#need to change to do a new scene that is the selection screen for a puzzle
	get_tree().change_scene_to_file("res://assets/scenes/select_puzzle.tscn")

func _on_quit_pressed():
	#quit the game
	#get_tree().root.propogate_notification(NOTIFICATION_WM_CLOSE_REQUEST) #should figure out what this does
	get_tree().quit()


func _on_tree_exiting():
	#place a destructor here maybe
	pass
