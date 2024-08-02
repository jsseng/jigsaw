extends Node2D

class_name PuzzleData

var row = 2
var col = 2

var size = 0

var valid_count = 0

var active_piece= -1 #I coopted this into a boolean value for jigsaw puzzle piece 2d in order to isolate the pieces

var slot_ref = -1

var choice = -1 #this is how you will choose which puzzle to do

var path = "res://assets/puzzles/jigsawpuzzleimages" #path for the images
var images = [] #this will be loaded up in the new menu scene

var pieceWidth #these are the actual size of the puzzle piece, I am putting them in here so that jigsaw_puzzle_piece_2d can access them and use them for sizing upon instantiation
var pieceHeight
