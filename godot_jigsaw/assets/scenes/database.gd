extends Control
var collection1: FirestoreCollection = Firebase.Firestore.collection('coordinates')
# Called when the node enters the scene tree for the first time.
func _ready():
	var add_task = await collection1.add("Coord", {'NCoord': '1', 'WCoord': '1'})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var document1 = await collection1.get_doc("Coord")
	document1.add_or_update_field('NCoord', '2')
	var update: FirestoreDocument = await collection1.update(document1)
	
