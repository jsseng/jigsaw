extends Node

signal logged_in
signal signup_succeeded
signal login_failed

var user_id = ""

# Firebase Data Model Below
# https://lucid.app/lucidchart/af25e9e6-c77e-4969-81fa-34510e32dcd6/edit?viewport_loc=-1197%2C-1440%2C3604%2C2292%2C0_0&invitationId=inv_20e62aec-9604-4bed-b2af-4882babbe404

# called when the node enters the scene tree for the first time
func _ready() -> void:
	Firebase.Auth.signup_succeeded.connect(_on_signup_succeeded)
	Firebase.Auth.login_failed.connect(_on_login_failed)
	
# attempt anonymous login
func attempt_anonymous_login() -> void:
	Firebase.Auth.login_anonymous()

# check if there's an existing auth session
func check_auth_file() -> void:
	Firebase.Auth.check_auth_file()

# check if login is needed
func needs_login() -> bool:
	return Firebase.Auth.needs_login()

# get current user id
func get_user_id() -> String:
	return Firebase.Auth.get_user_id()
	
# get current user puzzle list
func get_user_puzzle_list(user_id: String) -> FirestoreDocument:
	var collection: FirestoreCollection = Firebase.Firestore.collection("users")
	return (await collection.get_doc(user_id))
	
# handle successful anonymous login
func _on_signup_succeeded(auth_info: Dictionary) -> void:
	user_id = auth_info.get("localid") # extract the user id
	Firebase.Auth.save_auth(auth_info)  # save auth information locally
	logged_in.emit()
	
	# add user to firebase
	var collection: FirestoreCollection = Firebase.Firestore.collection("users")
	var document = await collection.add(user_id, {'activePuzzles': ["temp"], 'lastLogin': "", "totalPlayingTime": 0})
	print("Anonymous login succeeded. User ID: ", user_id)
	

# handle login failure
func _on_login_failed(code: String, message: String) -> void:
	login_failed.emit()
	print("Login failed with code: ", code, " message: ", message)

# gen id from a puzzle image to store
func generate_id_from_string(input: String) -> int:
	return hash(input)
	
	
func add_active_puzzle(puzzleId: int, GRID_WIDTH: int, GRID_HEIGHT: int) -> void:
	# add puzzle to active puzzle or add user to currently active puzzle
	var puzzleCollection: FirestoreCollection = Firebase.Firestore.collection("puzzles")
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	if (await puzzleCollection.get_doc(str(puzzleId)) == null):
		# add doc here
		puzzleCollection.add(str(puzzleId), {'complete': false, 'users': [FireAuth.get_user_id()], 'pieces': [], 'xDimension': GRID_WIDTH, 'yDimension': GRID_HEIGHT, 'size': GRID_HEIGHT*GRID_WIDTH})
	else:
		# get current doc and add new user
		var puzzleDoc = await puzzleCollection.get_doc(str(puzzleId))
		var userField = await puzzleDoc.document.get("users")
		var usersArray = []
		if userField and "arrayValue" in userField:
			for value in userField["arrayValue"]["values"]:
				if "stringValue" in value:
					usersArray.append(value["stringValue"])
		
		var currentUser = FireAuth.get_user_id()
		if currentUser not in usersArray:
			usersArray.append(FireAuth.get_user_id())
			puzzleDoc.add_or_update_field("users", usersArray)
			puzzleCollection.update(puzzleDoc)
	
	# add to user active puzzle list
	var userDoc = await FireAuth.get_user_puzzle_list(FireAuth.get_user_id())
	var userActivePuzzleField = userDoc.document.get("activePuzzles")
	var activePuzzleList = []
	if userActivePuzzleField and "arrayValue" in userActivePuzzleField:
			for value in userActivePuzzleField["arrayValue"]["values"]:
				if "stringValue" in value:
					activePuzzleList.append(value["stringValue"])
				
	if str(puzzleId) not in activePuzzleList:
		activePuzzleList.append(str(puzzleId))
		userDoc.add_or_update_field("activePuzzles", activePuzzleList)
		userCollection.update(userDoc)
	
