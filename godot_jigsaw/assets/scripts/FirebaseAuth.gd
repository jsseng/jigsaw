extends Node

signal logged_in
signal signup_succeeded
signal login_failed

var user_id = ""

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

func get_user_id() -> String:
	return Firebase.Auth.get_user_id()
	
# handle successful anonymous login
func _on_signup_succeeded(auth_info: Dictionary) -> void:
	user_id = auth_info.get("localid") # extract the user id
	Firebase.Auth.save_auth(auth_info)  # save auth information locally
	logged_in.emit()
	
	# add user to firebase
	var collection: FirestoreCollection = Firebase.Firestore.collection("users")
	var document = await collection.add(user_id, {'active': 'true'})
	print("Anonymous login succeeded. User ID: ", user_id)

# handle login failure
func _on_login_failed(code: String, message: String) -> void:
	login_failed.emit()
	print("Login failed with code: ", code, " message: ", message)
	
