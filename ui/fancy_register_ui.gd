extends Control

## FancyRegisterUI - Beautiful registration screen with animations

var email_input: LineEdit
var password_input: LineEdit
var confirm_password_input: LineEdit
var display_name_input: LineEdit
var register_button: Button
var back_button: Button
var status_label: Label

# Animation elements
var bg_particles: Array = []
var animation_time: float = 0.0

# Colors
var primary_color = Color(0.2, 0.8, 0.4)
var secondary_color = Color(0.1, 0.6, 0.3)
var accent_color = Color(0.9, 0.8, 0.2)
var dark_bg = Color(0.08, 0.08, 0.12)

signal register_success(user_data: Dictionary)
signal back_to_login()

func _ready() -> void:
	_setup_ui()
	_connect_signals()

func _setup_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = dark_bg
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Gradient background
	var gradient = ColorRect.new()
	gradient.color = Color(0.12, 0.06, 0.18)
	gradient.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(gradient)
	
	# Create floating particles
	_create_particles()
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_CENTER)
	main_container.custom_minimum_size = Vector2(500, 700)
	main_container.position = Vector2(-250, -350)
	main_container.add_theme_constant_override("separation", 15)
	add_child(main_container)
	
	# Header section
	_create_header(main_container)
	
	# Form panel
	var form_panel = PanelContainer.new()
	form_panel.custom_minimum_size = Vector2(400, 450)
	main_container.add_child(form_panel)
	
	var form_style = StyleBoxFlat.new()
	form_style.bg_color = Color(0.12, 0.12, 0.18, 0.9)
	form_style.corner_radius_top_left = 16
	form_style.corner_radius_top_right = 16
	form_style.corner_radius_bottom_left = 16
	form_style.corner_radius_bottom_right = 16
	form_style.border_width_top = 1
	form_style.border_width_bottom = 1
	form_style.border_width_left = 1
	form_style.border_width_right = 1
	form_style.border_color = Color(0.3, 0.3, 0.4, 0.5)
	form_style.shadow_color = Color(0, 0, 0, 0.4)
	form_style.shadow_size = 8
	form_panel.add_theme_stylebox_override("panel", form_style)
	
	var form_vbox = VBoxContainer.new()
	form_vbox.add_theme_constant_override("separation", 12)
	form_panel.add_child(form_vbox)
	
	# Form title
	var form_title = Label.new()
	form_title.text = "Create Account"
	form_title.add_theme_font_size_override("font_size", 24)
	form_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form_title.add_theme_color_override("font_color", Color.white)
	form_vbox.add_child(form_title)
	
	# Display name input
	display_name_input = _create_input("Display Name", "Enter your name")
	form_vbox.add_child(display_name_input)
	
	# Email input
	email_input = _create_input("Email", "Enter your email")
	form_vbox.add_child(email_input)
	
	# Password input
	password_input = _create_input("Password", "Create a password", true)
	form_vbox.add_child(password_input)
	
	# Confirm password
	confirm_password_input = _create_input("Confirm Password", "Confirm your password", true)
	form_vbox.add_child(confirm_password_input)
	
	# Status label
	status_label = Label.new()
	status_label.text = ""
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	form_vbox.add_child(status_label)
	
	# Register button
	register_button = _create_button("Create Account", primary_color)
	register_button.pressed.connect(_on_register_pressed)
	form_vbox.add_child(register_button)
	
	# Back button
	back_button = _create_button("Back to Login", Color(0.3, 0.3, 0.4))
	back_button.pressed.connect(_on_back_pressed)
	form_vbox.add_child(back_button)
	
	# Password strength indicator
	_create_password_strength(main_container)

func _create_header(parent: Control) -> void:
	# Logo panel
	var logo_panel = PanelContainer.new()
	logo_panel.custom_minimum_size = Vector2(400, 100)
	parent.add_child(logo_panel)
	
	var logo_style = StyleBoxFlat.new()
	logo_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	logo_style.corner_radius_top_left = 20
	logo_style.corner_radius_top_right = 20
	logo_style.corner_radius_bottom_left = 20
	logo_style.corner_radius_bottom_right = 20
	logo_style.border_width_top = 2
	logo_style.border_width_bottom = 2
	logo_style.border_width_left = 2
	logo_style.border_width_right = 2
	logo_style.border_color = Color(0.3, 0.8, 0.5, 0.6)
	logo_panel.add_theme_stylebox_override("panel", logo_style)
	
	var logo_vbox = VBoxContainer.new()
	logo_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	logo_panel.add_child(logo_vbox)
	
	var title = Label.new()
	title.text = "SURGICALSIM"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.white)
	logo_vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Join the Training Revolution"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7))
	logo_vbox.add_child(subtitle)

func _create_input(label_text: String, placeholder: String, is_password: bool = false) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(label)
	
	var input = LineEdit.new()
	input.placeholder_text = placeholder
	input.custom_minimum_size = Vector2(360, 45)
	input.add_theme_font_size_override("font_size", 16)
	
	if is_password:
		input.secret = true
	
	# Style the input
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.18, 0.18, 0.25)
	input_style.corner_radius_top_left = 8
	input_style.corner_radius_top_right = 8
	input_style.corner_radius_bottom_left = 8
	input_style.corner_radius_bottom_right = 8
	input_style.border_width_top = 2
	input_style.border_width_bottom = 2
	input_style.border_width_left = 2
	input_style.border_width_right = 2
	input_style.border_color = Color(0.3, 0.3, 0.4)
	input_style.content_margin_left = 15
	input_style.content_margin_right = 15
	input_style.content_margin_top = 10
	input_style.content_margin_bottom = 10
	input.add_theme_stylebox_override("normal", input_style)
	
	var input_focus = input_style.duplicate()
	input_focus.border_color = primary_color
	input.add_theme_stylebox_override("focus", input_focus)
	
	vbox.add_child(input)
	
	return vbox

func _create_button(text: String, color: Color) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(360, 50)
	button.add_theme_font_size_override("font_size", 16)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	button.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	button.add_theme_color_override("font_color", Color.white)
	
	return button

func _create_password_strength(parent: Control) -> void:
	var strength_container = VBoxContainer.new()
	strength_container.add_theme_constant_override("separation", 5)
	parent.add_child(strength_container)
	
	var strength_label = Label.new()
	strength_label.text = "Password Strength"
	strength_label.add_theme_font_size_override("font_size", 12)
	strength_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	strength_container.add_child(strength_label)
	
	var strength_bar = ProgressBar.new()
	strength_bar.custom_minimum_size = Vector2(360, 8)
	strength_bar.max_value = 100
	strength_bar.value = 0
	strength_bar.show_percentage = false
	strength_container.add_child(strength_bar)
	
	# Connect password input to strength checker
	if password_input:
		password_input.text_changed.connect(_on_password_changed.bind(strength_bar))

func _create_particles() -> void:
	for i in range(10):
		var particle = ColorRect.new()
		particle.color = Color(primary_color.r, primary_color.g, primary_color.b, 0.2)
		particle.custom_minimum_size = Vector2(randi_range(5, 20), randi_range(5, 20))
		particle.position = Vector2(randf_range(0, 1280), randf_range(0, 720))
		particle.name = "Particle_%d" % i
		add_child(particle)
		bg_particles.append(particle)

func _connect_signals() -> void:
	FirebaseAuth.auth_success.connect(_on_firebase_auth_success)
	FirebaseAuth.auth_error.connect(_on_firebase_auth_error)

func _process(delta: float) -> void:
	animation_time += delta
	
	# Animate particles
	for i in range(bg_particles.size()):
		var particle = bg_particles[i]
		particle.position.y -= 20 * delta
		particle.position.x += sin(animation_time + i) * 0.3
		
		if particle.position.y < -30:
			particle.position.y = 750
			particle.position.x = randf_range(0, 1280)

func _on_password_changed(text: String, strength_bar: ProgressBar) -> void:
	var strength = 0
	
	if text.length() >= 6:
		strength += 25
	if text.length() >= 8:
		strength += 25
	if text.matchn("*[a-z]*"):
		strength += 15
	if text.matchn("*[A-Z]*"):
		strength += 15
	if text.matchn("*[0-9]*"):
		strength += 10
	if text.matchn("*[^a-zA-Z0-9]*"):
		strength += 10
	
	strength_bar.value = strength
	
	# Update color based on strength
	var color: Color
	if strength < 30:
		color = Color(0.9, 0.2, 0.2)
	elif strength < 60:
		color = Color(0.9, 0.6, 0.2)
	elif strength < 80:
		color = Color(0.9, 0.9, 0.2)
	else:
		color = Color(0.2, 0.9, 0.4)
	
	strength_bar.add_theme_stylebox_override("fill", StyleBoxFlat.new())
	strength_bar.get_theme_stylebox("fill").bg_color = color

# ==================== BUTTON HANDLERS ====================

func _on_register_pressed() -> void:
	var display_name = display_name_input.text.strip_edges()
	var email = email_input.text.strip_edges()
	var password = password_input.text
	var confirm_password = confirm_password_input.text
	
	# Validation
	if display_name.is_empty() or email.is_empty() or password.is_empty() or confirm_password.is_empty():
		_show_status("Please fill in all fields", false)
		return
	
	if not _is_valid_email(email):
		_show_status("Please enter a valid email", false)
		return
	
	if password.length() < 6:
		_show_status("Password must be at least 6 characters", false)
		return
	
	if password != confirm_password:
		_show_status("Passwords do not match", false)
		return
	
	_show_status("Creating account...", true)
	FirebaseAuth.register_with_email(email, password, display_name)

func _on_back_pressed() -> void:
	back_to_login.emit()

# ==================== FIREBASE CALLBACKS ====================

func _on_firebase_auth_success(user_data: Dictionary) -> void:
	_show_status("Account created successfully!", true)
	
	# Animate out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): register_success.emit(user_data))

func _on_firebase_auth_error(message: String) -> void:
	_show_status(message, false)

# ==================== UTILITIES ====================

func _show_status(message: String, is_success: bool) -> void:
	status_label.text = message
	if is_success:
		status_label.add_theme_color_override("font_color", primary_color)
	else:
		status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))

func _is_valid_email(email: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email) != null

func show() -> void:
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func hide() -> void:
	visible = false
