extends Control

# this menu is used to select which puzzle the player wants to play

# these are variables for changing PageIndicator which is used
# to display the current page you are on
# ex:
#	PageIndicator will display:
#	1 out of 2
#	if you are on the first page out of
#	two pages total

var page_num = 1
# total_pages gets calculated in ready and is based off the amount
# of images in the image list
var total_pages # gets calculated in ready, is based off the amount of images
var page_string = "%d out of %d"
@onready var pageind = $PageIndicator # actual reference for PageIndicator

# buttons reference:
@onready var left_button = $"HBoxContainer/left button"
@onready var right_button = $"HBoxContainer/right button"

# grid reference:
#have an array of images to pull from that will correspond to an integer returned by the buttons
#for each page take the integer and add a multiple of 9
@onready var grid = $"HBoxContainer/GridContainer"


# Called when the node enters the scene tree for the first time.
func _ready():
	# this code will iterate through the children of the grid which are buttons
	# and will link them so that they all carry out the same function
	# that function being button_pressed
	for i in grid.get_children():
		var button := i as BaseButton
		if is_instance_valid(button):
			button.text = "" # set all buttons to have no text for formatting
			# actual code connecting the button_pressed function to
			# the buttons in the grid
			button.pressed.connect(button_pressed.bind(button))
	
	# this code gets the number of total pages
	var num_buttons = grid.get_child_count()
	var imgsize = float(PuzzleVar.images.size())
	var nb = float(num_buttons)
	total_pages = ceil(imgsize/nb) # round up always to get total_pages
	# disable the buttons logic that controls switching pages depending on
	# how many pages there are
	left_button.disabled = true 
	if total_pages == 1:
		right_button.disabled = true
	# the await is required so that the pages have time to load in
	await get_tree().process_frame
	# populates the buttons in the grid with actual images so that you can
	# preview which puzzle you want to select
	self.populate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# this code updates the display so that you know which page you are on
	pageind.text = page_string %[page_num,total_pages]


func _on_left_button_pressed():
	$AudioStreamPlayer.play()
	
	# decrements the current page you are on
	if page_num > 1:
		page_num -= 1
	
	# disables left button if you switch to page 1 and enables the right button
	if page_num == 1:
		left_button.disabled = true
		right_button.disabled = false
	
	# repopulates the grid with a new selection of images
	self.populate_grid()


func _on_right_button_pressed():
	$AudioStreamPlayer.play()
	
	# adds 1 to the current page you are on
	if page_num < total_pages:
		page_num += 1
	
	# if reach the last page, disables the right button and enables the left button
	if page_num == total_pages:
		right_button.disabled = true
		left_button.disabled = false
	
	# if it is some page in between 1 and the total number of pages
	# then have both buttons be enabled
	else:
		right_button.disabled = false
		left_button.disabled = false
	
	# repopulates the grid with a new selection of images
	self.populate_grid()


# this function selects the image that is previewed on the button for the puzzle
func button_pressed(button):
	#need to take val into account
	#do stuff to pick image
	
	#$AudioStreamPlayer.play() #this doesn't currently work because it switches scenes too quickly
	# index is initially set as the page number subtracted by 1 and then
	# multiplied by the number of buttons which is 9
	# ex:
	#	if you select something from page 2, you will currently
	#	have an index of 9
	var index = (page_num-1) * grid.get_child_count()
	# how this works is by taking the name of the button and taking the
	# number from the last character as per naming convention: gridx
	# ex:
	#	if you select the image in the button that is labeled grid1 then it
	#	takes the 1 at the end and adds it to the index to get the actual index
	#	of the image as it would be in the list PuzzleVar.images
	
	# ex for total thing:
	#	if you select an image on page 2 and pick grid1, then the actual index
	#	of the image is 10 and that will be put into PuzzleVar.choice so that
	#	the appropriate image can be loaded in
	
	var name = String(button.name)
	var chosen = index + int(name[-1])
	# if the selection is valid, proceed to the puzzle size selection menu
	if chosen < PuzzleVar.images.size():
		PuzzleVar.choice = index + int(name[-1])
		get_tree().change_scene_to_file("res://assets/scenes/menu.tscn")


# this function is what populates the grid with images so that you can
# preview which image you want to select
func populate_grid():
	# function starts by calculating the index of the image to start with
	# when populating the grid with 9 images
	var index = (page_num-1) * grid.get_child_count()
	
	# iterates through each child (button) of the grid and sets the buttons
	# texture to the appropriate image
	for i in grid.get_children():
		var button := i as BaseButton
		if is_instance_valid(button):
			if index < PuzzleVar.images.size():
				var res = load(PuzzleVar.path+"/"+PuzzleVar.images[index])
				button.get_child(0).texture = res
				button.get_child(0).size = button.size
			else:
				button.get_child(0).texture = null
			# iterates the index to get the next image after the image is
			# loaded in
			index += 1
