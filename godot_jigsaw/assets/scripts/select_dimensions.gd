extends Control

var wstring = "Width: %d"
var hstring = "Height: %d"

@onready var wlabel = $"background texture/VBoxContainer/Labelw"
@onready var hlabel = $"background texture/VBoxContainer/Labelh"

# Called when the node enters the scene tree for the first time.
func _ready():
	var image_texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice]) #may not need any of this code
	var image_size = image_texture.get_size()
	PuzzleVar.size = image_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wlabel.text = wstring %PuzzleVar.col
	hlabel.text = hstring %PuzzleVar.row


func _on_button_pressed():
	#feed the numbers into puzzleVar so that it can dice up the puzzle and make it a thing
	get_tree().change_scene_to_file("res://assets/scenes/jigsaw_puzzle.tscn") #go to jigsaw_puzzle


#what needs to happen is to make it so that the sliders select the width and height of the jigsaw puzzle
#the labels will display what the dimension are and these dimensions will then be fed into the system upon the button press

func _on_h_slider_width_value_changed(value):
	PuzzleVar.col = value
	

func _on_h_slider_height_value_changed(value):
	PuzzleVar.row = value
