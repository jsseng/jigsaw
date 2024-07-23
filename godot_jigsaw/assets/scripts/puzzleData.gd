extends Node2D

class_name PuzzleData

#Puzzle Dimensions
var row = 2
var col = 2
var size = 0

#Number of pieces placed correctly, used to check for victory
var valid_count = 0

var active_piece= -1 #Stores id for current puzzle piece held

var slot_ref = -1 #Stores id for current slot hovered over

var choice = -1 #Stores puzzle image id

var path = "res://assets/puzzles/jigsawpuzzleimages" #path for the images
var images = [] #this will be loaded up in the new menu scene
