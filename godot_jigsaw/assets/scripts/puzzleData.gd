extends Node2D

# these are global variables

class_name PuzzleData

var open_first_time = true

var row = 2
var col = 2

var size = 0

# I coopted active_piece into a boolean value for Piece_2d in order to isolate
# the pieces so that you couldn't hold two at a time if there was overlap
var active_piece= -1

# choice corresponds to the index of a piece in the list images
var choice = -1

var path = "res://assets/puzzles/jigsawpuzzleimages" # path for the images
var images = [] # this will be loaded up in the new menu scene

# these are the actual size of the puzzle piece, I am putting them in here so
# that piece_2d can access them and use them for sizing upon instantiation
var pieceWidth
var pieceHeight

# boolean value to trigger debug mode
var debug = false

var global_coordinates_list = {} #a dictionary of global coordinates for each piece
var adjacent_pieces_list = {} #a dictionary of adjacent pieces for each piece
var image_file_names = {} #a dictionary containing a mapping of selection numbers to image names
var global_num_pieces = 0 #the number of pieces in the current puzzle
var ordered_pieces_array = []
var draw_green_check = false
