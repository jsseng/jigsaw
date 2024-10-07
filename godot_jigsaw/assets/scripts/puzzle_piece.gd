extends Node2D

#@onready var top = $Area2D1
#@onready var right = $Area2D2
#@onready var bottom = $Area2D3
#@onready var left = $Area2D4

#@onready var topcol = $Area2D1/CollisionShape2D
#@onready var rightcol = $Area2D2/CollisionShape2D
#@onready var bottomcol = $Area2D3/CollisionShape2D
#@onready var leftcol = $Area2D4/CollisionShape2D

#none means that there is no match, otherwise populate them with a number that corresponds with the piece they match with inorder to snap to the proper side
var top_match
var right_match
var bottom_match
var left_match

var piece_id : int # Unique identifier for the piece

# Define the status of the sprite: "none", "clicked", "released", or "dragging".
var status = "none"
var inside

# Define the mouse position.
var mpos = Vector2()

#number assigned to piece based on position in grid
var id


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#may shift this into the actual puzzle as a method called configure size
	#var size = $Sprite2D.texture.get_size() #texture will be the size of the puzzle piece
	
	#setting collision areas
	#set top position
	#top.position = Vector2(size.x/2, -10)
	#topcol.shape.set_extents(Vector2(size.x/2,10))

	#set right position
	#right.position = Vector2(size.x +10, size.y/2)
	#rightcol.shape.set_extents(Vector2(10,size.y/2))
	
	#set bottom position
	#bottom.position = Vector2(size.x/2,size.y+10)
	#bottomcol.shape.set_extents(Vector2(size.x/2,10))
	
	#set left position
	#left.position = Vector2(-10,size.y/2)
	#leftcol.shape.set_extents(Vector2(10,size.y/2))
	
	#setting up matches
	
	#what needs to happen here is that there needs to be an array representing the connections in the puzzle so that each side has a set of matches that it can connect with

#need to handle click and drag and stuff, just take from draggable sprite
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and inside:
				status = "dragging"
			else:
				status = "none"
				
	#status = "none"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If the sprite is being dragged in either of the two modes, update its
	# position every frame. To update the position, we use the position of
	# the mouse
	if status == "dragging":
		global_position = mpos #need a way to move the whole puzzle piece
		
	#need to handle the collisions of the bottom top and stuff
	#need to make it so that they clip together and move as a unit
	#check if the match is correct and if it is merge them or connect them somehow

#need to create a function to handle actually moving the piece around and how to handle connecting stuff


func _on_area_2d_mouse_entered():
	inside = true


func _on_area_2d_mouse_exited():
	inside = false
