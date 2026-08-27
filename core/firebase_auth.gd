extends Node

## Firebase Email Auth - FREE (no charges for email/password)

var api_key: String = ""
var project_id: String = ""
var auth_domain: String = ""

# Current user
var current_user: Dictionary = {}
var is_logged_in: bool = false
var id_token: String = ""
var refresh_token: String = ""
var local_id: String = ""
var token_expiry_time: float = 0.0

# Config file path
const CONFIG_PATH = "res://config/firebase_config.json"
const USER_DATA_PATH = "user://firebase_user.json"
const TOKEN_LIFETIME: float = 3600.0  # 1 hour
const REFRESH_BUFFER: float = 300.0   # refresh 5 min before expiry

signal auth_success(user_data: Dictionary)
signal auth_error(message: String)
signal user_loaded(user_data: Dictionary)
signal password_reset_sent(email: String)
signal token_refreshed()

var refresh_timer: Timer

func _ready() -> void:
	_load_config()
	_load_user_data()
	_setup_refresh_timer()

func _load_config() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			var config = json.data
			api_key = config.get("api_key", "")
			project_id = config.get("project_id", "")
			auth_domain = config.get("auth_domain", "")
			print("Firebase config loaded")
	else:
		print("No Firebase config found")

func _setup_refresh_timer() -> void:
	refresh_timer = Timer.new()
	refresh_timer.wait_time = 60.0  # check every minute
	refresh_timer.autostart = true
	refresh_timer.timeout.connect(_check_token_expiry)
	add_child(refresh_timer)

func _check_token_expiry() -> void:
	if not is_logged_in or token_expiry_time <= 0.0:
		return
	var time_left = token_expiry_time - Time.get_unix_time_from_system()
	if time_left <= REFRESH_BUFFER:
		refresh_id_token()

func refresh_id_token() -> void:
	if api_key.is_empty() or refresh_token.is_empty():
		return
	
	var url = "https://securetoken.googleapis.com/v1/token?key=%s" % api_key
	var payload = {
		"grant_type": "refresh_token",
		"refresh_token": refresh_token
	}
	
	var http = HTTPRequest.new()
	add_child(http)
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(payload)
	http.request(url, headers, HTTPClient.METHOD_POST, body)
	http.request_completed.connect(_on_token_refresh_completed.bind(http))

func _on_token_refresh_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Token refresh network error")
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		print("Token refresh invalid response")
		return
	
	var data = json.data
	if response_code == 200:
		id_token = data.get("id_token", "")
		refresh_token = data.get("refresh_token", "")
		var expires_in = float(data.get("expires_in", "3600"))
		token_expiry_time = Time.get_unix_time_from_system() + expires_in
		_save_user_data()
		token_refreshed.emit()
		print("Firebase token refreshed")
	else:
		push_error("Token refresh failed: ", data.get("error", {}).get("message", "unknown"))

# ==================== EMAIL AUTH (FREE) ====================

func register_with_email(email: String, password: String, display_name: String = "") -> void:
	if api_key.is_empty():
		auth_error.emit("Firebase not configured")
		return
	
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % api_key
	
	var payload = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	
	if not display_name.is_empty():
		payload["displayName"] = display_name
	
	_make_auth_request(url, payload)

func login_with_email(email: String, password: String) -> void:
	if api_key.is_empty():
		auth_error.emit("Firebase not configured")
		return
	
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % api_key
	
	var payload = {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	
	_make_auth_request(url, payload)

func send_password_reset(email: String) -> void:
	if api_key.is_empty():
		auth_error.emit("Firebase not configured")
		return
	
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s" % api_key
	
	var payload = {
		"requestType": "PASSWORD_RESET",
		"email": email
	}
	
	_make_auth_request(url, payload)

func _make_auth_request(url: String, payload: Dictionary) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(payload)
	
	http.request(url, headers, HTTPClient.METHOD_POST, body)
	http.request_completed.connect(_on_auth_request_completed.bind(http))

func _on_auth_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		auth_error.emit("Network error")
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error != OK:
		auth_error.emit("Invalid response")
		return
	
	var data = json.data
	
	if response_code == 200:
		# Success
		id_token = data.get("idToken", "")
		refresh_token = data.get("refreshToken", "")
		local_id = data.get("localId", "")
		var expires_in = float(data.get("expires_in", "3600"))
		token_expiry_time = Time.get_unix_time_from_system() + expires_in
		
		current_user = {
			"email": data.get("email", ""),
			"local_id": local_id,
			"display_name": data.get("displayName", ""),
			"id_token": id_token
		}
		
		is_logged_in = true
		_save_user_data()
		auth_success.emit(current_user)
		print("Firebase auth success: ", current_user["email"])
	else:
		# Error
		var error_message = "Auth failed"
		match data.get("error", {}).get("message", ""):
			"EMAIL_EXISTS":
				error_message = "Email already registered"
			"EMAIL_NOT_FOUND":
				error_message = "Email not found"
			"INVALID_PASSWORD":
				error_message = "Invalid password"
			"WEAK_PASSWORD":
				error_message = "Password too weak"
			"INVALID_EMAIL":
				error_message = "Invalid email"
			"USER_DISABLED":
				error_message = "Account disabled"
			"TOO_MANY_ATTEMPTS_TRY_LATER":
				error_message = "Too many attempts, try later"
			"RESET_PASSWORD_EXCEEDED":
				error_message = "Password reset limit exceeded"
			_:
				error_message = data.get("error", {}).get("message", "Unknown error")
		
		auth_error.emit(error_message)

# ==================== USER MANAGEMENT ====================

func get_current_user() -> Dictionary:
	return current_user

func get_user_email() -> String:
	return current_user.get("email", "")

func get_user_display_name() -> String:
	return current_user.get("display_name", "")

func get_id_token() -> String:
	return id_token

func is_user_logged_in() -> bool:
	return is_logged_in

func logout() -> void:
	current_user = {}
	is_logged_in = false
	id_token = ""
	refresh_token = ""
	local_id = ""
	token_expiry_time = 0.0
	_delete_user_data()

# ==================== SAVE/LOAD ====================

func _save_user_data() -> void:
	var save_data = {
		"email": current_user.get("email", ""),
		"local_id": current_user.get("local_id", ""),
		"display_name": current_user.get("display_name", ""),
		"id_token": id_token,
		"refresh_token": refresh_token,
		"token_expiry_time": token_expiry_time
	}
	
	var file = FileAccess.open(USER_DATA_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _load_user_data() -> void:
	var file = FileAccess.open(USER_DATA_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			var data = json.data
			id_token = data.get("id_token", "")
			refresh_token = data.get("refresh_token", "")
			local_id = data.get("local_id", "")
			token_expiry_time = data.get("token_expiry_time", 0.0)
			
			current_user = {
				"email": data.get("email", ""),
				"local_id": local_id,
				"display_name": data.get("display_name", ""),
				"id_token": id_token
			}
			
			if not id_token.is_empty():
				is_logged_in = true
				user_loaded.emit(current_user)
				# Auto-refresh if token is expired or about to expire
				var time_left = token_expiry_time - Time.get_unix_time_from_system()
				if time_left <= REFRESH_BUFFER:
					refresh_id_token()

func _delete_user_data() -> void:
	var file = FileAccess.open(USER_DATA_PATH, FileAccess.WRITE)
	if file:
		file.store_string("")
		file.close()
