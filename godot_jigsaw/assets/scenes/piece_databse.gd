extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var group = get_tree().get_nodes_in_group("puzzle_pieces")
	var collection: FirestoreCollection = Firebase.Firestore.collection('Coordinates')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Piece2d.snap_and_connect(Piece2d.group, 'n'):
		var add_task = await collection.add('Coords', {'Ncoord': Piece2d.NCoord, 'name': document_name})
		var document = await collection.get_doc(document_name)
		document.add_or_update_field('time', timestamp)
		var update: FirestoreDocument = await collection.update(document)
