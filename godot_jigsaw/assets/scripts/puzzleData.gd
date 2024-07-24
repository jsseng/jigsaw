extends Node2D

class_name PuzzleData

#Puzzle Dimensions
var row = 2
var col = 2
var size = 0

var active_piece:int = -1 #Stores id for current puzzle piece held
var slot_ref = null #Stores current platform
var choice:int = -1 #Stores puzzle image id
var correct_pieces:Array = [] #Stores ID's of correctly placed pieces, used to check for victory

var path = "res://assets/puzzles/jigsawpuzzleimages" #path for the images
var images = [] #this will be loaded up in the new menu scene

#PLAYER(S) INFORMATION
var players:Dictionary = {}
var player_info:Dictionary = {
	"active_piece" : active_piece,
	"slot_ref" : slot_ref,
	"choice" : choice,
	"correct_pieces" : correct_pieces
}

func _ready():
	player_info["id"] = multiplayer.get_unique_id()

