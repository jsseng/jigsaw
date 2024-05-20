extends Label

var val = 4
var format_string = "Number of Pieces: %d"

func _ready():
	# Ensure Label node exists and is accessible
	print(self)

func _process(delta):
	# This function runs every frame; you can update label text here if needed
	self.text = format_string % val

func _on_row_value_changed(value):
	# Example function to show how to modify 'val'
	val = value * value
