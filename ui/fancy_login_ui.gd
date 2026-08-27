extends Control

## FancyLoginUI - Beautiful login screen with animations

# UI Elements
var email_input: LineEdit
var password_input: LineEdit
var login_button: Button
var register_button: Button
var forgot_password_button: Button
var guest_button: Button
var status_label: Label
var title_label: Label
var subtitle_label: Label

# Animation elements
var bg_gradient: ColorRect
var logo_panel: PanelContainer
var form_panel: PanelContainer
var particles_container: Control

# Colors
var primary_color = Color(0.2, 0.8, 0.4)
var secondary_color = Color(0.1, 0.6, 0.3)
var accent_color = Color(0.9, 0.8, 0.2)
var dark_bg = Color(0.08, 0.08, 0.12)
var card_bg = Color(0.12, 0.12, 0.18)

# State
var is_registering: bool = false
var animation_time: float = 0.0

signal login_success(user_data: Dictionary)
signal register_success(user_data: Dictionary)
signal guest_login()
signal forgot_password(email: String)

func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_start_animations()

func _setup_ui() -> void:
	# Full screen background
	var bg = ColorRect.new()
	bg.color = dark_bg
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Animated gradient background
	bg_gradient = ColorRect.new()
	bg_gradient.color = Color(0.1, 0.05, 0.15)
	bg_gradient.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg_gradient)
	
	# Particles container
	particles_container = Control.new()
	particles_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	particles_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(particles_container)
	
	# Create floating particles
	_create_particles()
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_CENTER)
	main_container.custom_minimum_size = Vector2(500, 700)
	main_container.position = Vector2(-250, -350)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Logo section
	_create_logo_section(main_container)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	main_container.add_child(spacer)
	
	# Form section
	_create_form_section(main_container)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	main_container.add_child(spacer2)
	
	# Social section
	_create_social_section(main_container)
	
	# Version
	var version = Label.new()
	version.text = "Version 1.0.0"
	version.add_theme_font_size_override("font_size", 12)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	main_container.add_child(version)

func _create_logo_section(parent: Control) -> void:
	# Logo panel with glass effect
	logo_panel = PanelContainer.new()
	logo_panel.custom_minimum_size = Vector2(400, 120)
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
	logo_style.shadow_color = Color(0, 0, 0, 0.3)
	logo_style.shadow_size = 10
	logo_panel.add_theme_stylebox_override("panel", logo_style)
	
	var logo_vbox = VBoxContainer.new()
	logo_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	logo_vbox.add_theme_constant_override("separation", 5)
	logo_panel.add_child(logo_vbox)
	
	# Medical cross icon
	var cross_label = Label.new()
	cross_label.text = "+"
	cross_label.add_theme_font_size_override("font_size", 48)
	cross_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cross_label.add_theme_color_override("font_color", primary_color)
	logo_vbox.add_child(cross_label)
	
	# Title
	title_label = Label.new()
	title_label.text = "SURGICALSIM"
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	logo_vbox.add_child(title_label)
	
	# Subtitle
	subtitle_label = Label.new()
	subtitle_label.text = "3D Surgical Training Simulator"
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7))
	logo_vbox.add_child(subtitle_label)

func _create_form_section(parent: Control) -> void:
	# Form panel with glass effect
	form_panel = PanelContainer.new()
	form_panel.custom_minimum_size = Vector2(400, 350)
	parent.add_child(form_panel)
	
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
	form_vbox.add_theme_constant_override("separation", 15)
	form_panel.add_child(form_vbox)
	
	# Form title
	var form_title = Label.new()
	form_title.text = "Welcome Back"
	form_title.add_theme_font_size_override("font_size", 24)
	form_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form_title.add_theme_color_override("font_color", Color(1, 1, 1))
	form_vbox.add_child(form_title)
	
	# Email input
	var email_container = _create_styled_input("Email", "Enter your email")
	form_vbox.add_child(email_container)
	
	# Password input
	var password_container = _create_styled_input("Password", "Enter your password", true)
	form_vbox.add_child(password_container)
	
	# Status label
	status_label = Label.new()
	status_label.text = ""
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	form_vbox.add_child(status_label)
	
	# Login button
	login_button = _create_primary_button("Login")
	login_button.pressed.connect(_on_login_pressed)
	form_vbox.add_child(login_button)
	
	# Register button
	register_button = _create_secondary_button("Create Account")
	register_button.pressed.connect(_on_register_pressed)
	form_vbox.add_child(register_button)
	
	# Forgot password
	forgot_password_button = Button.new()
	forgot_password_button.text = "Forgot Password?"
	forgot_password_button.add_theme_font_size_override("font_size", 14)
	forgot_password_button.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
	forgot_password_button.add_theme_stylebox_override("normal", StyleBoxFlat.new())
	forgot_password_button.add_theme_stylebox_override("hover", StyleBoxFlat.new())
	forgot_password_button.pressed.connect(_on_forgot_password_pressed)
	form_vbox.add_child(forgot_password_button)

func _create_social_section(parent: Control) -> void:
	# Divider
	var divider = HBoxContainer.new()
	divider.add_theme_constant_override("separation", 10)
	parent.add_child(divider)
	
	var line_left = HSeparator.new()
	line_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	divider.add_child(line_left)
	
	var or_label = Label.new()
	or_label.text = "OR"
	or_label.add_theme_font_size_override("font_size", 14)
	or_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	divider.add_child(or_label)
	
	var line_right = HSeparator.new()
	line_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	divider.add_child(line_right)
	
	# Guest button
	guest_button = Button.new()
	guest_button.text = "Continue as Guest"
	guest_button.custom_minimum_size = Vector2(400, 50)
	guest_button.add_theme_font_size_override("font_size", 16)
	guest_button.pressed.connect(_on_guest_pressed)
	parent.add_child(guest_button)
	
	var guest_style = StyleBoxFlat.new()
	guest_style.bg_color = Color(0.2, 0.2, 0.28)
	guest_style.corner_radius_top_left = 12
	guest_style.corner_radius_top_right = 12
	guest_style.corner_radius_bottom_left = 12
	guest_style.corner_radius_bottom_right = 12
	guest_style.border_width_top = 2
	guest_style.border_width_bottom = 2
	guest_style.border_width_left = 2
	guest_style.border_width_right = 2
	guest_style.border_color = Color(0.4, 0.4, 0.5)
	guest_button.add_theme_stylebox_override("normal", guest_style)
	
	var guest_hover = guest_style.duplicate()
	guest_hover.bg_color = Color(0.25, 0.25, 0.33)
	guest_button.add_theme_stylebox_override("hover", guest_hover)

func _create_styled_input(label_text: String, placeholder: String, is_password: bool = false) -> VBoxContainer:
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
	
	if is_password:
		password_input = input
	else:
		email_input = input
	
	return vbox

func _create_primary_button(text: String) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(360, 50)
	button.add_theme_font_size_override("font_size", 18)
	
	var style = StyleBoxFlat.new()
	style.bg_color = primary_color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	button.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.25, 0.85, 0.45)
	button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.bg_color = secondary_color
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	
	return button

func _create_secondary_button(text: String) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(360, 50)
	button.add_theme_font_size_override("font_size", 16)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.28)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.4, 0.4, 0.5)
	button.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.25, 0.25, 0.33)
	button.add_theme_stylebox_override("hover", hover_style)
	
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	
	return button

func _create_particles() -> void:
	for i in range(15):
		var particle = ColorRect.new()
		particle.color = Color(primary_color.r, primary_color.g, primary_color.b, 0.3)
		particle.custom_minimum_size = Vector2(randi_range(10, 30), randi_range(10, 30))
		particle.position = Vector2(randf_range(0, 1280), randf_range(0, 720))
		particle.name = "Particle_%d" % i
		particles_container.add_child(particle)

func _connect_signals() -> void:
	FirebaseAuth.auth_success.connect(_on_firebase_auth_success)
	FirebaseAuth.auth_error.connect(_on_firebase_auth_error)
	FirebaseAuth.password_reset_sent.connect(_on_password_reset_sent)

func _start_animations() -> void:
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _process(delta: float) -> void:
	animation_time += delta
	
	# Animate particles
	for i in range(particles_container.get_child_count()):
		var particle = particles_container.get_child(i)
		particle.position.y -= 30 * delta
		particle.position.x += sin(animation_time + i) * 0.5
		
		if particle.position.y < -50:
			particle.position.y = 770
			particle.position.x = randf_range(0, 1280)
	
	# Animate gradient
	if bg_gradient:
		var gradient_value = sin(animation_time * 0.3) * 0.02
		bg_gradient.color = Color(0.1 + gradient_value, 0.05, 0.15 - gradient_value)

# ==================== BUTTON HANDLERS ====================

func _on_login_pressed() -> void:
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	if email.is_empty() or password.is_empty():
		_show_status("Please fill in all fields", false)
		return
	
	if not _is_valid_email(email):
		_show_status("Please enter a valid email", false)
		return
	
	_show_status("Logging in...", true)
	FirebaseAuth.login_with_email(email, password)

func _on_register_pressed() -> void:
	is_registering = true
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	if email.is_empty() or password.is_empty():
		_show_status("Please fill in all fields", false)
		return
	
	if not _is_valid_email(email):
		_show_status("Please enter a valid email", false)
		return
	
	if password.length() < 6:
		_show_status("Password must be at least 6 characters", false)
		return
	
	_show_status("Creating account...", true)
	FirebaseAuth.register_with_email(email, password)

func _on_forgot_password_pressed() -> void:
	var email = email_input.text.strip_edges()
	
	if email.is_empty():
		_show_status("Please enter your email first", false)
		return
	
	if not _is_valid_email(email):
		_show_status("Please enter a valid email", false)
		return
	
	_show_status("Sending reset email...", true)
	FirebaseAuth.send_password_reset(email)

func _on_guest_pressed() -> void:
	guest_login.emit()

# ==================== FIREBASE CALLBACKS ====================

func _on_firebase_auth_success(user_data: Dictionary) -> void:
	_show_status("Login successful!", true)
	
	# Animate out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		if is_registering:
			register_success.emit(user_data)
		else:
			login_success.emit(user_data)
	)

func _on_firebase_auth_error(message: String) -> void:
	_show_status(message, false)

func _on_password_reset_sent(email: String) -> void:
	_show_status("Reset email sent to: " + email, true)

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
	_start_animations()

func hide() -> void:
	visible = false
