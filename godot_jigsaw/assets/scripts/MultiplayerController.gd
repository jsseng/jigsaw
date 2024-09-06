extends Control

#all code courtsey of a helpful tutorial by FinePointCGI

@export var Address = "127.0.0.1" #temp address
@export var port = 8910

var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#this gets called on the server and clients
func peer_connected(id):
	print("Player Connected " + str(id))

#this gets called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))

#called only from clients
func connected_to_server():
	print("connected to Server")
	SendPlayerInformation.rpc_id(1, multiplayer.get_unique_id())
	

#called only from clients
func connection_failed():
	print("connection failed")
	
	
@rpc("any_peer")
func SendPlayerInformation(id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"id": id,
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].id,i)


@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://assets/scenes/jigsaw_puzzle_1.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 5) # five players for the jigsaw game, max could be 32
	if error != OK:
		print("cannot host:" + error)
		return
	#compression needs to be the same across the board, so if change host compression, need to change join compression as well
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) #may replace with no compression
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for Players!")
	SendPlayerInformation(multiplayer.get_unique_id())
	
	pass # Replace with function body.


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) #may replace with no compression
	multiplayer.set_multiplayer_peer(peer)
	
	pass # Replace with function body.


func _on_start_game_button_down():
	StartGame.rpc() #call all people
	
	pass # Replace with function body.
