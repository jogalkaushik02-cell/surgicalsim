extends Node

## AuthManager - Local-only authentication (no server)

var current_user: Dictionary = {}
var is_authenticated: bool = false
var users_file: String = "user://users.json"

signal auth_success(user: Dictionary)
signal auth_error(error: String)
signal user_loaded(user: Dictionary)
signal user_logged_out()

func _ready() -> void:
	_load_current_user()

func _load_current_user() -> void:
	var file = FileAccess.open("user://current_user.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK and json.data:
			current_user = json.data
			is_authenticated = true
			user_loaded.emit(current_user)
		file.close()

func register_user(username: String, display_name: String = "") -> bool:
	# Validate username
	if username.length() < 2:
		auth_error.emit("Username must be at least 2 characters")
		return false
	
	if username.length() > 20:
		auth_error.emit("Username must be less than 20 characters")
		return false
	
	# Check if username already exists
	var users = _load_all_users()
	for user in users:
		if user.get("username", "") == username:
			auth_error.emit("Username already taken")
			return false
	
	# Create user
	current_user = {
		"uid": "user_" + str(randi()),
		"username": username,
		"displayName": display_name if display_name else username,
		"createdAt": Time.get_datetime_string_from_system(),
		"stats": {
			"surgeries_completed": 0,
			"total_score": 0,
			"best_score": 0,
			"total_time": 0.0
		}
	}
	
	# Save to local storage
	_save_user(current_user)
	_save_current_user()
	
	is_authenticated = true
	auth_success.emit(current_user)
	Events.log_event("user_registered", {"username": username})
	return true

func login_user(username: String) -> bool:
	var users = _load_all_users()
	for user in users:
		if user.get("username", "") == username:
			current_user = user
			_save_current_user()
			is_authenticated = true
			auth_success.emit(current_user)
			Events.log_event("user_logged_in", {"username": username})
			print("User logged in locally: ", username)
			return true
	
	auth_error.emit("User not found. Please register first.")
	return false

func login_as_guest() -> void:
	var guest_id = "guest_" + str(randi())
	current_user = {
		"uid": guest_id,
		"username": "Guest",
		"displayName": "Guest",
		"createdAt": Time.get_datetime_string_from_system(),
		"is_guest": true,
		"stats": {
			"surgeries_completed": 0,
			"total_score": 0,
			"best_score": 0,
			"total_time": 0.0
		}
	}
	_save_current_user()
	is_authenticated = true
	auth_success.emit(current_user)
	Events.log_event("guest_login")

func logout_user() -> void:
	current_user = {}
	is_authenticated = false
	
	# Delete current user file
	var file = FileAccess.open("user://current_user.json", FileAccess.WRITE)
	if file:
		file.store_string("")
		file.close()
	
	user_logged_out.emit()
	Events.log_event("user_logged_out")

func get_current_user() -> Dictionary:
	return current_user

func get_user_id() -> String:
	return current_user.get("uid", "")

func get_username() -> String:
	return current_user.get("username", "Guest")

func get_display_name() -> String:
	return current_user.get("displayName", "Guest")

func is_user_authenticated() -> bool:
	return is_authenticated

func is_logged_in() -> bool:
	return is_authenticated

func get_user_stats() -> Dictionary:
	return current_user.get("stats", {})

func update_stats(surgery_score: int, surgery_time: float) -> void:
	if not is_authenticated:
		return
	
	var stats = current_user.get("stats", {})
	stats["surgeries_completed"] = stats.get("surgeries_completed", 0) + 1
	stats["total_score"] = stats.get("total_score", 0) + surgery_score
	stats["best_score"] = max(stats.get("best_score", 0), surgery_score)
	stats["total_time"] = stats.get("total_time", 0.0) + surgery_time
	
	current_user["stats"] = stats
	_save_user(current_user)
	_save_current_user()

# ==================== LOCAL STORAGE ====================

func _save_user(user: Dictionary) -> void:
	var users = _load_all_users()
	
	# Update existing or add new
	var found = false
	for i in range(users.size()):
		if users[i].get("uid") == user.get("uid"):
			users[i] = user
			found = true
			break
	
	if not found:
		users.append(user)
	
	var file = FileAccess.open(users_file, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(users))
		file.close()

func _load_all_users() -> Array:
	var users = []
	var file = FileAccess.open(users_file, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK and json.data:
			users = json.data
		file.close()
	return users

func _save_current_user() -> void:
	var file = FileAccess.open("user://current_user.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_user))
		file.close()

func get_all_users() -> Array:
	return _load_all_users()

func delete_user(username: String) -> bool:
	var users = _load_all_users()
	var new_users = []
	
	for user in users:
		if user.get("username") != username:
			new_users.append(user)
	
	var file = FileAccess.open(users_file, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(new_users))
		file.close()
		return true
	return false
