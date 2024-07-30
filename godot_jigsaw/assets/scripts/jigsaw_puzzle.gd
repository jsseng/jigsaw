extends Node2D

var GRID_WIDTH = PuzzleVar.col
var GRID_HEIGHT = PuzzleVar.row

var debug = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var pp = preload("res://assets/scenes/puzzle_piece.tscn")
	
	#load up Image so that you can split it into puzzle pieces
	#$Image.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	#load up reference image for reference
	$referenceImage.texture = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	
	#need to chop up the image according to GRID_WIDTH and GRID_HEIGHT and make it so they have circular pegs to attach to each other
	#need to create the puzzle pieces from puzzle_piece and then scatter them around the board
	
	#create the puzzle pieces by using masking
	
	var puzzle_image = load(PuzzleVar.path+"/"+PuzzleVar.images[PuzzleVar.choice])
	var image_size = puzzle_image.get_size()
	print(image_size)
	
	# Calculate the size of each grid cell
	var cell_width = image_size.x / GRID_WIDTH
	var cell_height = image_size.y / GRID_HEIGHT
	
	#cut up the puzzle in order to create the pieces
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var piece = pp.instantiate()
			piece.add_to_group("puzzle_pieces")
			piece.id = debug #set the id of piece using debug for now
			debug += 1
			
			var sprite = piece.get_node("Sprite2D")
			
			#areas
			var top = piece.get_node("Area2D/Area2D1")
			var right = piece.get_node("Area2D/Area2D2")
			var bottom = piece.get_node("Area2D/Area2D3")
			var left = piece.get_node("Area2D/Area2D4")
			
			#collision boxes
			#var topcol = piece.get_node("Area2D/Area2D1/CollisionShape2D")
			#var rightcol = piece.get_node("Area2D/Area2D2/CollisionShape2D")
			#var bottomcol = piece.get_node("Area2D/Area2D3/CollisionShape2D")
			#var leftcol = piece.get_node("Area2D/Area2D4/CollisionShape2D")
			
			sprite.set_region_enabled(true) #makes it so it takes only a portion of the whole image, a piece of the puzzle
			# Set the texture rect for the sprite
			var rect = Rect2(x * cell_width, y * cell_height, cell_width, cell_height)
			sprite.set_region_rect(rect)
			
			#setting collision areas
			#set top position
			top.position = Vector2(cell_width/2, -10) #may need to tweak
			#topcol.shape = top
			#topcol.shape.set_extents(Vector2(cell_width/2,10))

			#set right position
			right.position = Vector2(cell_width +10, cell_height/2)
			#rightcol.shape.set_extents(Vector2(10,cell_height/2))
			
			#set bottom position
			bottom.position = Vector2(cell_width/2,cell_height+10)
			#bottomcol.shape.set_extents(Vector2(cell_width/2,10))
			
			#set left position
			left.position = Vector2(-10,cell_height/2)
			#leftcol.shape.set_extents(Vector2(10,cell_height/2))
			
			#set up matching sides
			
			#put into random location
			#piece.position = Vector2(randf()*get_viewport_rect().size.x,randf()*get_viewport_rect().size.y)
			piece.position = Vector2(100,100)
			#add piece to board
			#get_parent().call_deferred("add_child", piece)
			add_child(piece)
	
	
	# Calculate the size of each grid cell
	#var cell_width = image_size.x / GRID_WIDTH
	#var cell_height = image_size.y / GRID_HEIGHT
	
	# preload the scenes
	#var sprite_scene = preload("res://assets/scenes/DraggableSprite.tscn")
	
	
	#need to figure out where to place platform, also need to figure out how to scramble platform and not
	
	#platform is not one single platform, it is actually representative of a single interactive piece of the puzzle that is then put together into a grid
	#inorder to create the full thing, hence why they have to constantly instantiate it.
	
	
	
	
	#need to load up platform and figure out how to scramble and apportion pieces properly
	#place platform in the scene so that it just directly loads things


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#put in win condition
	#have a lable saying that you won
	#show a picture of the finished puzzle
	#hide the platform and reference image
	pass

#have a function to call that will split up the puzzle pieces
#have a function to call that will scramble up all the puzzle pieces
