extends Control

#for changing Page Indicator
var val = 1
var total_pages #calculate in ready
var page_string = "%d out of %d"
@onready var pageind = $PageIndicator

#buttons
@onready var left_button = $"HBoxContainer/left button"
@onready var right_button = $"HBoxContainer/right button"

#grid
#have an array of images to pull from that will correspond to an integer returned by the buttons
#for each page take the integer and add a multiple of 9
@onready var grid = $"HBoxContainer/GridContainer"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in grid.get_children(): #linking up grid buttons
		var button := i as BaseButton
		if is_instance_valid(button):
			button.text = "" #set them all to have no text
			
			button.pressed.connect(button_pressed.bind(button)) #calls button pressed which will handle grid stuff
			
	
	var num_buttons = grid.get_child_count()
	var imgsize = float(PuzzleVar.images.size())
	var nb = float(num_buttons)
	total_pages = ceil(imgsize/nb) #round up always
	left_button.hide() #for visual
	if total_pages == 1:
		right_button.hide()
	
	self.populate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pageind.text = page_string %[val,total_pages]


func _on_left_button_pressed():
	if val > 1:
		val -= 1
		
	if val == 1: #hide left button if on page 1 and show right
		left_button.hide()
		right_button.show()
		
	self.populate_grid()


func _on_right_button_pressed():
	if val < total_pages:
		val += 1
		
	if val == total_pages: #hide button
		right_button.hide()
		left_button.show()
		
	else:
		right_button.show()
		left_button.show()
		
	self.populate_grid()
		
func button_pressed(button): #selects the image that the button represents
	#should make this return an integer that will represent the index of the image that needs to be loaded in
	#need to take val into account
	#do stuff to pick image
	var index = (val-1) * grid.get_child_count()
	#need to add the value that corresponds with the button pressed add 0-8 currently
	var name = String(button.name)
	PuzzleVar.choice = index + int(name[-1])
	#if valid pick change the scene, otherwise do nothing
	get_tree().change_scene_to_file("res://assets/scenes/menu.tscn") #filler for now
	
	
func populate_grid():
	var index = (val-1) * grid.get_child_count()
	for i in grid.get_children():
		var button := i as BaseButton
		if is_instance_valid(button):
			if index < PuzzleVar.images.size():
				var res = load(PuzzleVar.path+"/"+PuzzleVar.images[index])
				button.icon = res
			else:
				button.icon = null
			index += 1 #iterate index to get next
	
#potentially need to handle exiting out of the scene to go back

