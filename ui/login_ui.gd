extends CanvasLayer

## LoginUI - Login/Register screen

var is_visible: bool = true
var is_login_mode: bool = true  # true = login, false = register

# UI elements
var panel: PanelContainer = null
var title_label: Label = null
var username_input: LineEdit = null
var display_name_input: LineEdit = null
var password_container: VBoxContainer = null
var login_button: Button = null
var register_button: Button = null
var switch_mode_button: Button = null
var guest_button: Button = null
var error_label: Label = null
var status_label: Label = null

func _ready() -> void:
	_create_ui()
	AuthManager.auth_success.connect(_on_auth_success)
	AuthManager.auth_error.connect(_on_auth_error)
	show()

func _create_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "LoginPanel"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	
	# Title
	title_label = Label.new()
	title_label.text = "SURGICALSIM"
	title_label.add_theme_font_size_override("font_size", 42)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "3D Surgical Training Simulator"
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(subtitle)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)
	
	# Login/Register form
	var form_container = VBoxContainer.new()
	form_container.custom_minimum_size = Vector2(300, 0)
	form_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(form_container)
	
	# Username input
	var username_label = Label.new()
	username_label.text = "Username:"
	form_container.add_child(username_label)
	
	username_input = LineEdit.new()
	username_input.placeholder_text = "Enter username"
	username_input.custom_minimum_size = Vector2(0, 40)
	form_container.add_child(username_input)
	
	# Display name input (only for register)
	display_name_input = LineEdit.new()
	display_name_input.placeholder_text = "Display Name (optional)"
	display_name_input.custom_minimum_size = Vector2(0, 40)
	display_name_input.visible = false
	form_container.add_child(display_name_input)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	form_container.add_child(spacer2)
	
	# Error label
	error_label = Label.new()
	error_label.name = "ErrorLabel"
	error_label.add_theme_font_size_override("font_size", 14)
	error_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	form_container.add_child(error_label)
	
	# Status label
	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form_container.add_child(status_label)
	
	# Spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 20)
	form_container.add_child(spacer3)
	
	# Login button
	login_button = Button.new()
	login_button.text = "Login"
	login_button.custom_minimum_size = Vector2(0, 50)
	login_button.pressed.connect(_on_login_pressed)
	form_container.add_child(login_button)
	
	# Register button (hidden by default)
	register_button = Button.new()
	register_button.text = "Register"
	register_button.custom_minimum_size = Vector2(0, 50)
	register_button.pressed.connect(_on_register_pressed)
	register_button.visible = false
	form_container.add_child(register_button)
	
	# Spacer
	var spacer4 = Control.new()
	spacer4.custom_minimum_size = Vector2(0, 10)
	form_container.add_child(spacer4)
	
	# Switch mode button
	switch_mode_button = Button.new()
	switch_mode_button.text = "Don't have an account? Register"
	switch_mode_button.pressed.connect(_on_switch_mode_pressed)
	form_container.add_child(switch_mode_button)
	
	# Spacer
	var spacer5 = Control.new()
	spacer5.custom_minimum_size = Vector2(0, 20)
	form_container.add_child(spacer5)
	
	# Guest button
	guest_button = Button.new()
	guest_button.text = "Continue as Guest"
	guest_button.custom_minimum_size = Vector2(0, 50)
	guest_button.pressed.connect(_on_guest_pressed)
	form_container.add_child(guest_button)
	
	# Version
	var version_label = Label.new()
	version_label.text = "Version 1.0.0"
	version_label.add_theme_font_size_override("font_size", 12)
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	form_container.add_child(version_label)

func _on_login_pressed() -> void:
	var username = username_input.text.strip_edges()
	
	if username.is_empty():
		_show_error("Please enter a username")
		return
	
	_show_status("Logging in...")
	
	# Small delay for UX
	await get_tree().create_timer(0.3).timeout
	
	var success = AuthManager.login_user(username)
	if not success:
		_show_error(AuthManager.auth_error.get("error", "Login failed"))

func _on_register_pressed() -> void:
	var username = username_input.text.strip_edges()
	var display_name = display_name_input.text.strip_edges()
	
	if username.is_empty():
		_show_error("Please enter a username")
		return
	
	_show_status("Creating account...")
	
	await get_tree().create_timer(0.3).timeout
	
	var success = AuthManager.register_user(username, display_name)
	if not success:
		_show_error("Registration failed")

func _on_guest_pressed() -> void:
	# Create guest user
	AuthManager.current_user = {
		"uid": "guest_" + str(randi()),
		"username": "Guest",
		"displayName": "Guest",
		"is_guest": true,
		"createdAt": Time.get_datetime_string_from_system(),
		"stats": {
			"surgeries_completed": 0,
			"total_score": 0,
			"best_score": 0,
			"total_time": 0.0
		}
	}
	AuthManager.is_authenticated = true
	AuthManager.auth_success.emit(AuthManager.current_user)
	Events.log_event("guest_login")

func _on_switch_mode_pressed() -> void:
	is_login_mode = not is_login_mode
	
	if is_login_mode:
		title_label.text = "SURGICALSIM"
		login_button.visible = true
		register_button.visible = false
		display_name_input.visible = false
		switch_mode_button.text = "Don't have an account? Register"
	else:
		title_label.text = "CREATE ACCOUNT"
		login_button.visible = false
		register_button.visible = true
		display_name_input.visible = true
		switch_mode_button.text = "Already have an account? Login"
	
	_clear_messages()

func _on_auth_success(user: Dictionary) -> void:
	_show_status("Welcome, " + user.get("displayName", "User") + "!")
	await get_tree().create_timer(1.0).timeout
	hide()

func _on_auth_error(error: String) -> void:
	_show_error(error)

func _show_error(text: String) -> void:
	if error_label:
		error_label.text = text
		error_label.visible = true
	if status_label:
		status_label.visible = false

func _show_status(text: String) -> void:
	if status_label:
		status_label.text = text
		status_label.visible = true
	if error_label:
		error_label.visible = false

func _clear_messages() -> void:
	if error_label:
		error_label.visible = false
	if status_label:
		status_label.visible = false

func show() -> void:
	visible = true
	is_visible = true
	_clear_messages()
	username_input.text = ""
	display_name_input.text = ""

func hide() -> void:
	visible = false
	is_visible = false
