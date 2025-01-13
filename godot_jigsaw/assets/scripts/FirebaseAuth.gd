extends Node

signal logged_in
signal signup_succeeded
signal login_failed

var user_id = ""
var currentPuzzle = ""
var offlineMode = 0

var puzzleNames = {
	0: ["china10", 10],
	1: ["china100", 100],
	2: ["china1000", 1000],
	3: ["elephant10", 10],
	4: ["elephant100", 100],
	5: ["elephant1000", 1000],
	6: ["peacock10", 10],
	7: ["peacock100", 100],
	8: ["peacock1000", 1000],
	9: ["hippo10", 10],
	10: ["hippo100", 100],
	11: ["hippo1000", 1000],
	12: ["mountain10", 10],
	13: ["mountain100", 100],
	14: ["mountain1000", 1000],
	15: ["nyc10", 10],
	16: ["nyc100", 100],
	17: ["nyc1000", 1000],
	18: ["rhino10", 10],
	19: ["rhino100", 100],
	20: ["rhino1000", 1000],
	21: ["seattle10", 10],
	22: ["seattle100", 100],
	23: ["seattle1000", 1000],
	24: ["taxi10", 10],
	25: ["taxi100", 100],
	26: ["taxi1000", 1000],
	27: ["tree10", 10],
	28: ["tree100", 100],
	29: ["tree1000", 1000],
};


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
	await Firebase.Auth.check_auth_file()
	FireAuth.write_last_login_time(FireAuth.get_user_id())

# check if login is needed
func needs_login() -> bool:
	return Firebase.Auth.needs_login()

# get current user id
func get_user_id() -> String:
	return Firebase.Auth.get_user_id()
	
func get_current_puzzle() -> String:
	return str(currentPuzzle)
	
# get current user puzzle list
func get_user_puzzle_list(user_id: String) -> FirestoreDocument:
	var collection: FirestoreCollection = Firebase.Firestore.collection("users")
	return (await collection.get_doc(user_id))
# handle successful anonymous login

func _on_signup_succeeded(auth_info: Dictionary) -> void:
	user_id = auth_info.get("localid") # extract the user id
	# save auth information locally
	Firebase.Auth.save_auth(auth_info)
	logged_in.emit()
	var favorite_puzzles = [{"puzzleId": "temp", "rank": 1, "timesPlayed": 0}]
	var collection: FirestoreCollection = Firebase.Firestore.collection("users")
	
	# add user to firebase
	var document = await collection.add(user_id, {'activePuzzles': [{"puzzleId": "0", "timeStarted": "0"}], 'lastLogin': Time.get_datetime_string_from_system(), "totalPlayingTime": 0, 'favoritePuzzles': favorite_puzzles, 'completedPuzzles': ["temp"], 'currentMode': 'temp'})
	print("Anon Login Success: ", user_id)

	
# write the current time to the db	
func write_last_login_time(user_id: String) -> void:
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var userTimeDoc = await userCollection.get_doc(user_id)
	userTimeDoc.add_or_update_field("lastLogin", Time.get_datetime_string_from_system())
	userCollection.update(userTimeDoc)
# handle login failure

func _on_login_failed(code: String, message: String) -> void:
	login_failed.emit()
	print("Login failed with code: ", code, " message: ", message)


func write_playing_time() -> void:
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var userDoc = await userCollection.get_doc(FireAuth.get_user_id())
	var currentUserTotalTime = int(userDoc.document.get("totalPlayingTime")["integerValue"])
	var newTime = currentUserTotalTime + 1
	userDoc.add_or_update_field("totalPlayingTime", newTime)
	userCollection.update(userDoc)
# add active puzzle to firebase

func add_active_puzzle(puzzleId: int) -> void:
	var GRID_SIZE = puzzleNames[puzzleId][1]
	var PUZZLE_NAME = puzzleNames[puzzleId][0]
	# add puzzle to active puzzle or add user to currently active puzzle
	var puzzleCollection: FirestoreCollection = Firebase.Firestore.collection("puzzles")
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var doc = await puzzleCollection.get_doc(PUZZLE_NAME)
	if (doc == null || not doc):
		# add doc here
		await puzzleCollection.add(PUZZLE_NAME, {'complete': false, 'users': ["temp", FireAuth.get_user_id()], 'pieces': [], 'xDimension': GRID_SIZE, 'yDimension': GRID_SIZE, 'size': GRID_SIZE*GRID_SIZE})
	else:
		# get current doc and add new user
		var puzzleDoc = await puzzleCollection.get_doc(PUZZLE_NAME)
		var userField = await puzzleDoc.document.get("users")
		var usersArray = []
		if userField and "arrayValue" in userField and userField["arrayValue"]:
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
	var curPuzzleAddedFlag = 0
	
	# check if the activePuzzles field exists and has array values
	if userActivePuzzleField and "arrayValue" in userActivePuzzleField:
		for puzzle in userActivePuzzleField["arrayValue"]["values"]:
			if "mapValue" in puzzle:
				var puzzleData = puzzle["mapValue"]["fields"]
				if puzzleData["puzzleId"]["stringValue"] == PUZZLE_NAME:
					curPuzzleAddedFlag = 1
				activePuzzleList.append({
					"puzzleId": puzzleData["puzzleId"]["stringValue"],
					"timeStarted": puzzleData["timeStarted"]["stringValue"]
					})

	if not curPuzzleAddedFlag:
		activePuzzleList.append({"puzzleId": PUZZLE_NAME, "timeStarted": Time.get_datetime_string_from_system()})
		userDoc.add_or_update_field("activePuzzles", activePuzzleList)
		userCollection.update(userDoc)

func remove_current_user_from_activePuzzle(puzzleID: int):
	var PUZZLE_NAME = puzzleNames[puzzleID][0]
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var puzzleCollection: FirestoreCollection = Firebase.Firestore.collection("puzzles")
	var userDoc = await userCollection.get_doc(FireAuth.get_user_id())
	var puzzleDoc = await puzzleCollection.get_doc(PUZZLE_NAME)
	# ideally when multiplayer works, doc should be deleted if one player completes
	# which will eventually replace the code below
	# delete finished puzzle from current user active puzzle
	var userActivePuzzleField = userDoc.document.get("activePuzzles")
	var activePuzzleList = []
	var completedPuzzleData = {}
	if userActivePuzzleField and "arrayValue" in userActivePuzzleField:
		for puzzle in userActivePuzzleField["arrayValue"]["values"]:
			if "mapValue" in puzzle:
				var puzzleData = puzzle["mapValue"]["fields"]
				if puzzleData["puzzleId"]["stringValue"] != PUZZLE_NAME:
					activePuzzleList.append({
						"puzzleId": puzzleData["puzzleId"]["stringValue"],
						"timeStarted": puzzleData["timeStarted"]["stringValue"]
						})
				else:
					completedPuzzleData = puzzleData
	userDoc.add_or_update_field("activePuzzles", activePuzzleList)
	await userCollection.update(userDoc)
	
	# delete current user from current activePuzzle
	var puzzleUserField = puzzleDoc.document.get("users")
	var puzzleActiveUserList = []
	if puzzleUserField and "arrayValue" in puzzleUserField:
		for value in puzzleUserField["arrayValue"]["values"]:
			if "stringValue" in value and FireAuth.get_user_id() != value["stringValue"]:
				puzzleActiveUserList.append(value["stringValue"])
				
	puzzleDoc.add_or_update_field("users", puzzleActiveUserList)
	await puzzleCollection.update(puzzleDoc)
	
	# add to user completed puzzles
	add_user_completed_puzzles(completedPuzzleData)


func add_user_completed_puzzles(completedPuzzle: Dictionary) -> void:
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var userDoc = await userCollection.get_doc(FireAuth.get_user_id())
	var userCompletedPuzzleField = userDoc.document.get("completedPuzzles")
	var completedPuzzlesList = []
	
	for puzzle in userCompletedPuzzleField["arrayValue"]["values"]:
		if "mapValue" in puzzle:
			var puzzleData = puzzle["mapValue"]["fields"]
			completedPuzzlesList.append({
				"puzzleId": puzzleData["puzzleId"]["stringValue"],
				"timeStarted": puzzleData["timeStarted"]["stringValue"],
				"timeFinished": puzzleData["timeFinished"]["stringValue"]
				})
	
	completedPuzzlesList.append({
			"puzzleId": completedPuzzle["puzzleId"]["stringValue"],
			"timeStarted": completedPuzzle["timeStarted"]["stringValue"],
			"timeFinished": Time.get_datetime_string_from_system()
			})
	userDoc.add_or_update_field("completedPuzzles", completedPuzzlesList)
	userCollection.update(userDoc)
	
# add favorite puzzles to firebase
func add_favorite_puzzle(puzzleId: int) -> void:
	var PUZZLE_NAME = puzzleNames[puzzleId][0]
	# grab the use collection and user doc
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var userDoc = await userCollection.get_doc(FireAuth.get_user_id())
	
	# get the user's favorite puzzle field from FireBase
	var favoritePuzzleField = userDoc.document.get("favoritePuzzles")
	var favoritePuzzleList = []
	
	# check if the favoritePuzzles field is present
	if favoritePuzzleField and "arrayValue" in favoritePuzzleField:
		# go through each puzzle ID
		for puzzle in favoritePuzzleField["arrayValue"]["values"]:
			
			# each entry is a value from a hashmap
			if "mapValue" in puzzle:
				var puzzleData = puzzle["mapValue"]["fields"]
				# add the values from the database to our list
				favoritePuzzleList.append({
					"puzzleId": puzzleData["puzzleId"]["stringValue"],
					"timesPlayed": int(puzzleData["timesPlayed"]["integerValue"]),
					# default rank is 0
					"rank": int(puzzleData.get("rank", {"integerValue": "0"})["integerValue"])
					})
	# flag to check if the puzzle is already in favorite puzzles
	var puzzleFound = false
	# check if the current puzzle ID is already in our list
	for puzzle in favoritePuzzleList:
		if puzzle["puzzleId"] == PUZZLE_NAME:
			# increment the current puzzle "timesPLayed" value
			puzzle["timesPlayed"] += 1
			# set flag to true
			puzzleFound = true
			# get out of the loop
			break
			
	# if this is a new puzzle to the user
	if not puzzleFound:
		# add current puzzle to our list
		favoritePuzzleList.append({
			"puzzleId": PUZZLE_NAME,
			"timesPlayed": 1,
			"rank": 0
			})
	
	# sorting by "timesPlayed" with BubbleSort
	for i in range(favoritePuzzleList.size()):
		for j in range(0, favoritePuzzleList.size() - i - 1):
			if favoritePuzzleList[j]["timesPlayed"] < favoritePuzzleList[j + 1]["timesPlayed"]:
				var temp = favoritePuzzleList[j]
				favoritePuzzleList[j] = favoritePuzzleList[j + 1]
				favoritePuzzleList[j + 1] = temp
	
	# assign ranks based on sorted order
	for i in range(favoritePuzzleList.size()):
		# ranking starts at 1 being the most played
		favoritePuzzleList[i]["rank"] = i + 1 
		
	# update our list to firebase
	userDoc.add_or_update_field("favoritePuzzles", favoritePuzzleList)
	await userCollection.update(userDoc)

# function to update whether or not user is playing multiplayer or single player
func addUserMode(mode: String) -> void:
	var userCollection: FirestoreCollection = Firebase.Firestore.collection("users")
	var userDoc = await userCollection.get_doc(FireAuth.get_user_id())
	if mode == "Multiplayer" or mode == "Single Player":
		userDoc.add_or_update_field("currentMode", mode)
		await userCollection.update(userDoc)
		
		
		
		
		
