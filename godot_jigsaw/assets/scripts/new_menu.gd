extends Control

var auth = Firebase.Auth.auth
var timestamp = Time.get_unix_time_from_system()
var collection: FirestoreCollection = Firebase.Firestore.collection('time')
var document_name = auth.localid

var document_time = await collection.get_doc(auth.localid)
# Called when the node enters the scene tree for the first time.
func _ready():
	
	#this is where the images in the folder get put into the array for reference
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
	var add_task = await collection.add(document_name, {'time': timestamp, 'name': document_name})
	var document = await collection.get_doc(document_name)
	document.add_or_update_field('time', timestamp)
	var update: FirestoreDocument = await collection.update(document)
	#need to change to a new scene that is a random game
	randomize()
	
	PuzzleVar.choice = randi_range(0,PuzzleVar.images.size()-1) #choose a random image to use
	var val = randi_range(2,10)
	PuzzleVar.col = val
	PuzzleVar.row = val
	
	var image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_size = image_texture.get_size()
	PuzzleVar.size = image_size
	
	#get_tree().change_scene_to_file("res://assets/scenes/jigsaw_puzzle_1.tscn") #this may keep changing
	get_tree().change_scene_to_file("res://assets/scenes/world.tscn") #for testing

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

