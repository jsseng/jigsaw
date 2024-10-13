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
