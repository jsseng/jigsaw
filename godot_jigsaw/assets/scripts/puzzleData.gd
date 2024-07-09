extends Node2D

class_name PuzzleData

var row = 2
var col = 2

var size = 0

var valid_count = 0

var active_piece= -1

var slot_ref = -1

var choice = -1 #this is how you will choose which puzzle to do

var path = "res://assets/puzzles/jigsawpuzzleimages" #path for the images
var images = [] #this will be loaded up in the new menu scene
