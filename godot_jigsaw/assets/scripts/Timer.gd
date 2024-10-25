extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	update_user_playing_time()

# runs periodically to update user playing time
func update_user_playing_time() -> void:
	while true:
		await get_tree().create_timer(60.0).timeout
		FireAuth.write_playing_time()
		
	
