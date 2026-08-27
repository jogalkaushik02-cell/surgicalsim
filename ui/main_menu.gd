extends CanvasLayer

## MainMenu - Complete main menu with fancy Firebase login

# UI Elements
var main_panel: PanelContainer
var title_label: Label
var version_label: Label
var username_label: Label

# Buttons
var single_player_button: Button
var multiplayer_button: Button
var online_button: Button
var tutorial_button: Button
var achievements_button: Button
var catalog_button: Button
var logout_button: Button
var quit_button: Button

# UI references
var fancy_login_ui: Control
var fancy_register_ui: Control
var tutorial_ui: Control
var achievement_ui: Control
var catalog_ui: Control
var online_lobby_ui: Control

# Current state
var is_guest: bool = false

func _ready() -> void:
	_create_ui()
	_connect_signals()
	_check_auth_state()

func _create_ui() -> void:
	# Main panel (shown after login)
	_create_main_panel()
	
	# Create child UIs
	_create_child_uis()

func _create_main_panel() -> void:
	main_panel = PanelContainer.new()
	main_panel.name = "MainPanel"
	main_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_panel)
	
	# Animated gradient background
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_panel.add_child(bg)
	
	# Create floating particles
	_create_particles(main_panel)
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_CENTER)
	main_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	main_container.custom_minimum_size = Vector2(400, 500)
	main_container.add_theme_constant_override("separation", 15)
	main_panel.add_child(main_container)
	
	# Header panel with glass effect
	var header_panel = PanelContainer.new()
	header_panel.custom_minimum_size = Vector2(350, 100)
	main_container.add_child(header_panel)
	
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	header_style.corner_radius_top_left = 20
	header_style.corner_radius_top_right = 20
	header_style.corner_radius_bottom_left = 20
	header_style.corner_radius_bottom_right = 20
	header_style.border_width_top = 2
	header_style.border_width_bottom = 2
	header_style.border_width_left = 2
	header_style.border_width_right = 2
	header_style.border_color = Color(0.3, 0.8, 0.5, 0.6)
	header_style.shadow_color = Color(0, 0, 0, 0.3)
	header_style.shadow_size = 10
	header_panel.add_theme_stylebox_override("panel", header_style)
	
	var header_vbox = VBoxContainer.new()
	header_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header_panel.add_child(header_vbox)
	
	# Medical cross icon
	var cross_label = Label.new()
	cross_label.text = "+"
	cross_label.add_theme_font_size_override("font_size", 40)
	cross_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cross_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.4))
	header_vbox.add_child(cross_label)
	
	# Title
	title_label = Label.new()
	title_label.text = "SURGICALSIM"
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	header_vbox.add_child(title_label)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "3D Surgical Training Simulator"
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7))
	header_vbox.add_child(subtitle)
	
	# User info
	username_label = Label.new()
	username_label.text = "Welcome, Guest"
	username_label.add_theme_font_size_override("font_size", 16)
	username_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	username_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.8))
	main_container.add_child(username_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	main_container.add_child(spacer)
	
	# Menu buttons panel
	var menu_panel = PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(350, 300)
	main_container.add_child(menu_panel)
	
	var menu_style = StyleBoxFlat.new()
	menu_style.bg_color = Color(0.12, 0.12, 0.18, 0.9)
	menu_style.corner_radius_top_left = 16
	menu_style.corner_radius_top_right = 16
	menu_style.corner_radius_bottom_left = 16
	menu_style.corner_radius_bottom_right = 16
	menu_style.border_width_top = 1
	menu_style.border_width_bottom = 1
	menu_style.border_width_left = 1
	menu_style.border_width_right = 1
	menu_style.border_color = Color(0.3, 0.3, 0.4, 0.5)
	menu_style.shadow_color = Color(0, 0, 0, 0.4)
	menu_style.shadow_size = 8
	menu_panel.add_theme_stylebox_override("panel", menu_style)
	
	var menu_vbox = VBoxContainer.new()
	menu_vbox.add_theme_constant_override("separation", 12)
	menu_panel.add_child(menu_vbox)
	
	# Menu title
	var menu_title = Label.new()
	menu_title.text = "SELECT MODE"
	menu_title.add_theme_font_size_override("font_size", 20)
	menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_title.add_theme_color_override("font_color", Color(0.5, 0.7, 0.6))
	menu_vbox.add_child(menu_title)
	
	# Single Player Button
	single_player_button = _create_menu_button("Single Player", Color(0.2, 0.7, 0.4))
	single_player_button.pressed.connect(_on_single_player_pressed)
	menu_vbox.add_child(single_player_button)
	
	# Local Multiplayer Button
	multiplayer_button = _create_menu_button("Local Multiplayer", Color(0.3, 0.6, 0.8))
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	menu_vbox.add_child(multiplayer_button)
	
	# Online Multiplayer Button
	online_button = _create_menu_button("Online Multiplayer", Color(0.8, 0.5, 0.2))
	online_button.pressed.connect(_on_online_pressed)
	menu_vbox.add_child(online_button)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 5)
	menu_vbox.add_child(spacer2)
	
	# Secondary buttons
	var secondary_container = HBoxContainer.new()
	secondary_container.add_theme_constant_override("separation", 10)
	secondary_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_vbox.add_child(secondary_container)
	
	tutorial_button = _create_small_button("Tutorial")
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	secondary_container.add_child(tutorial_button)
	
	achievements_button = _create_small_button("Achievements")
	achievements_button.pressed.connect(_on_achievements_pressed)
	secondary_container.add_child(achievements_button)
	
	catalog_button = _create_small_button("Catalog")
	catalog_button.pressed.connect(_on_catalog_pressed)
	secondary_container.add_child(catalog_button)
	
	# Bottom buttons
	var bottom_container = HBoxContainer.new()
	bottom_container.add_theme_constant_override("separation", 15)
	bottom_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_vbox.add_child(bottom_container)
	
	logout_button = _create_small_button("Logout")
	logout_button.pressed.connect(_on_logout_pressed)
	bottom_container.add_child(logout_button)
	
	quit_button = _create_small_button("Quit")
	quit_button.pressed.connect(_on_quit_pressed)
	bottom_container.add_child(quit_button)
	
	# Version
	version_label = Label.new()
	version_label.text = "Version 1.0.0"
	version_label.add_theme_font_size_override("font_size", 12)
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	main_container.add_child(version_label)

func _create_child_uis() -> void:
	# Fancy Login UI
	var login_script = load("res://ui/fancy_login_ui.gd")
	fancy_login_ui = Control.new()
	fancy_login_ui.set_script(login_script)
	fancy_login_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fancy_login_ui)
	
	# Fancy Register UI
	var register_script = load("res://ui/fancy_register_ui.gd")
	fancy_register_ui = Control.new()
	fancy_register_ui.set_script(register_script)
	fancy_register_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fancy_register_ui)
	
	# Tutorial UI
	var tutorial_script = load("res://ui/tutorial_ui.gd")
	tutorial_ui = Control.new()
	tutorial_ui.set_script(tutorial_script)
	tutorial_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(tutorial_ui)
	
	# Achievement UI
	var achievement_script = load("res://ui/achievement_ui.gd")
	achievement_ui = Control.new()
	achievement_ui.set_script(achievement_script)
	achievement_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(achievement_ui)
	
	# Catalog UI
	var catalog_script = load("res://ui/surgery_catalog_ui.gd")
	catalog_ui = Control.new()
	catalog_ui.set_script(catalog_script)
	catalog_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(catalog_ui)
	
	# Online Lobby UI
	var lobby_script = load("res://ui/online_lobby_ui.gd")
	online_lobby_ui = Control.new()
	online_lobby_ui.set_script(lobby_script)
	online_lobby_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(online_lobby_ui)

func _create_menu_button(text: String, color: Color) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(320, 50)
	button.add_theme_font_size_override("font_size", 18)
	
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
	
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	
	return button

func _create_small_button(text: String) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(100, 35)
	button.add_theme_font_size_override("font_size", 14)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.28)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_color = Color(0.35, 0.35, 0.45)
	button.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.25, 0.25, 0.33)
	button.add_theme_stylebox_override("hover", hover_style)
	
	button.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	
	return button

func _create_particles(parent: Control) -> void:
	for i in range(10):
		var particle = ColorRect.new()
		particle.color = Color(0.2, 0.8, 0.4, 0.15)
		particle.custom_minimum_size = Vector2(randi_range(5, 15), randi_range(5, 15))
		particle.position = Vector2(randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y))
		particle.name = "Particle_%d" % i
		parent.add_child(particle)

func _connect_signals() -> void:
	# Firebase auth signals
	FirebaseAuth.auth_success.connect(_on_firebase_auth_success)
	FirebaseAuth.user_loaded.connect(_on_user_loaded)
	
	# Tutorial signals
	Tutorial.tutorial_completed.connect(_on_tutorial_completed)
	
	# Login UI signals
	fancy_login_ui.login_success.connect(_on_login_success)
	fancy_login_ui.register_success.connect(_on_register_success)
	fancy_login_ui.guest_login.connect(_on_guest_login)
	
	# Register UI signals
	fancy_register_ui.register_success.connect(_on_register_success)
	fancy_register_ui.back_to_login.connect(_on_back_to_login)

func _check_auth_state() -> void:
	if FirebaseAuth.is_user_logged_in():
		_show_main_menu()
	elif AuthManager.is_logged_in():
		_show_main_menu()
	elif FirebaseAuth.api_key.is_empty():
		_show_login_menu()
	else:
		_show_login_menu()

# ==================== LOGIN/REGISTER ====================

func _show_login_menu() -> void:
	main_panel.visible = false
	fancy_login_ui.show_ui()
	fancy_register_ui.hide_ui()

func _show_main_menu() -> void:
	fancy_login_ui.hide_ui()
	fancy_register_ui.hide_ui()
	main_panel.visible = true
	_update_user_info()

func _update_user_info() -> void:
	var user = FirebaseAuth.get_current_user()
	if user and not user.is_empty():
		var display_name = user.get("display_name", "")
		var email = user.get("email", "")
		if not display_name.is_empty():
			username_label.text = "Welcome, %s" % display_name
		else:
			username_label.text = "Welcome, %s" % email
	elif AuthManager.is_logged_in():
		var user_data = AuthManager.get_current_user()
		username_label.text = "Welcome, %s" % user_data.get("display_name", "User")
	else:
		username_label.text = "Welcome, Guest"

func _on_login_success(user_data: Dictionary) -> void:
	_show_main_menu()

func _on_register_success(user_data: Dictionary) -> void:
	_show_main_menu()

func _on_guest_login() -> void:
	is_guest = true
	AuthManager.login_as_guest()
	_show_main_menu()

func _on_back_to_login() -> void:
	fancy_register_ui.hide_ui()
	fancy_login_ui.show_ui()

func _on_firebase_auth_success(user_data: Dictionary) -> void:
	_show_main_menu()

func _on_user_loaded(user_data: Dictionary) -> void:
	_show_main_menu()

# ==================== MENU ACTIONS ====================

func _on_single_player_pressed() -> void:
	RoleSystem.is_single_player = true
	RoleSystem.set_local_role(RoleSystem.Role.LEAD_SURGEON)
	hide_ui()
	var hud = get_node_or_null("/root/MainScene/HUD")
	if hud:
		hud.show()
	var controls = get_node_or_null("/root/MainScene/SimulationControls")
	if controls:
		controls.show()
	var android_ui = get_node_or_null("/root/MainScene/AndroidUI")
	if android_ui:
		android_ui.show()
	Events.log_event("single_player_selected")

func _on_multiplayer_pressed() -> void:
	var role_ui = get_node_or_null("/root/MainScene/RoleAssignmentUI")
	if role_ui:
		role_ui.show_ui()
	hide_ui()

func _on_online_pressed() -> void:
	online_lobby_ui.show_lobby()

func _on_tutorial_pressed() -> void:
	tutorial_ui.start_tutorial()

func _on_achievements_pressed() -> void:
	achievement_ui.show_achievements()

func _on_catalog_pressed() -> void:
	catalog_ui.show_catalog()

func _on_logout_pressed() -> void:
	FirebaseAuth.logout()
	AuthManager.logout()
	is_guest = false
	_show_login_menu()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_tutorial_completed() -> void:
	AchievementSystem.on_tutorial_completed()

func show_ui() -> void:
	visible = true
	_check_auth_state()

func hide_ui() -> void:
	visible = false
