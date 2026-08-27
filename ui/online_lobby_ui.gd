extends Control

## OnlineLobbyUI - Online multiplayer lobby with WebRTC

var room_code_label: Label
var room_code_display: Label
var player_list: VBoxContainer
var status_label: Label
var create_button: Button
var join_button: Button
var leave_button: Button
var room_code_input: LineEdit
var start_game_button: Button

var generated_room_code: String = ""

signal game_starting()
signal lobby_closed()

func _ready() -> void:
	_setup_ui()
	_connect_signals()

func _setup_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Main panel
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(500, 450)
	panel.position = Vector2(-250, -225)
	add_child(panel)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.12, 0.15)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(0.3, 0.3, 0.3)
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var main_container = VBoxContainer.new()
	main_container.add_theme_constant_override("separation", 15)
	panel.add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "ONLINE LOBBY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.2, 0.8, 0.4))
	main_container.add_child(title)
	
	# Status
	status_label = Label.new()
	status_label.text = "Not connected"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	main_container.add_child(status_label)
	
	# Connect button
	var connect_button = Button.new()
	connect_button.text = "Connect to Server"
	connect_button.custom_minimum_size = Vector2(200, 40)
	connect_button.pressed.connect(_on_connect_pressed)
	main_container.add_child(connect_button)
	
	# Room code section
	var room_container = HBoxContainer.new()
	room_container.add_theme_constant_override("separation", 10)
	main_container.add_child(room_container)
	
	room_code_input = LineEdit.new()
	room_code_input.placeholder_text = "Enter room code"
	room_code_input.custom_minimum_size = Vector2(200, 40)
	room_container.add_child(room_code_input)
	
	join_button = Button.new()
	join_button.text = "Join"
	join_button.custom_minimum_size = Vector2(100, 40)
	join_button.pressed.connect(_on_join_pressed)
	join_button.disabled = true
	room_container.add_child(join_button)
	
	# Create room button
	create_button = Button.new()
	create_button.text = "Create New Room"
	create_button.custom_minimum_size = Vector2(200, 40)
	create_button.pressed.connect(_on_create_pressed)
	create_button.disabled = true
	main_container.add_child(create_button)
	
	# Room code display
	var room_display = HBoxContainer.new()
	room_display.add_theme_constant_override("separation", 10)
	main_container.add_child(room_display)
	
	var room_label = Label.new()
	room_label.text = "Room Code:"
	room_label.add_theme_font_size_override("font_size", 16)
	room_display.add_child(room_label)
	
	room_code_display = Label.new()
	room_code_display.text = "--------"
	room_code_display.add_theme_font_size_override("font_size", 24)
	room_code_display.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	room_display.add_child(room_code_display)
	
	# Copy button
	var copy_button = Button.new()
	copy_button.text = "Copy"
	copy_button.custom_minimum_size = Vector2(80, 30)
	copy_button.pressed.connect(_on_copy_pressed)
	room_display.add_child(copy_button)
	
	# Player list
	var player_label = Label.new()
	player_label.text = "Players in Room:"
	player_label.add_theme_font_size_override("font_size", 16)
	main_container.add_child(player_label)
	
	var player_scroll = ScrollContainer.new()
	player_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	player_scroll.custom_minimum_size = Vector2(0, 100)
	main_container.add_child(player_scroll)
	
	player_list = VBoxContainer.new()
	player_list.add_theme_constant_override("separation", 5)
	player_scroll.add_child(player_list)
	
	# Bottom buttons
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 15)
	main_container.add_child(button_container)
	
	leave_button = Button.new()
	leave_button.text = "Leave Room"
	leave_button.custom_minimum_size = Vector2(150, 40)
	leave_button.pressed.connect(_on_leave_pressed)
	leave_button.disabled = true
	button_container.add_child(leave_button)
	
	start_game_button = Button.new()
	start_game_button.text = "Start Game"
	start_game_button.custom_minimum_size = Vector2(150, 40)
	start_game_button.pressed.connect(_on_start_pressed)
	start_game_button.disabled = true
	button_container.add_child(start_game_button)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(100, 40)
	close_button.pressed.connect(_on_close_pressed)
	button_container.add_child(close_button)
	
	visible = false

func _connect_signals() -> void:
	WebRTCMultiplayer.connected_to_server.connect(_on_connected_to_server)
	WebRTCMultiplayer.disconnected_from_server.connect(_on_disconnected_from_server)
	WebRTCMultiplayer.room_joined.connect(_on_room_joined)
	WebRTCMultiplayer.player_joined.connect(_on_player_joined)
	WebRTCMultiplayer.player_left.connect(_on_player_left)
	WebRTCMultiplayer.connection_failed.connect(_on_connection_failed)

func show_lobby() -> void:
	visible = true
	_update_ui()

func _update_ui() -> void:
	var is_connected = WebRTCMultiplayer.is_online()
	var in_room = WebRTCMultiplayer.get_room_code() != ""
	
	status_label.text = "Connected" if is_connected else "Not connected"
	status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.4) if is_connected else Color(0.7, 0.7, 0.7))
	
	create_button.disabled = not is_connected
	join_button.disabled = not is_connected or room_code_input.text.length() < 6
	leave_button.disabled = not in_room
	start_game_button.disabled = not in_room or WebRTCMultiplayer.get_player_count() < 2
	
	if in_room:
		room_code_display.text = WebRTCMultiplayer.get_room_code()
		room_code_input.text = WebRTCMultiplayer.get_room_code()
		room_code_input.editable = false
	else:
		room_code_display.text = "--------"
		room_code_input.text = ""
		room_code_input.editable = true
	
	_update_player_list()

func _update_player_list() -> void:
	# Clear list
	for child in player_list.get_children():
		child.queue_free()
	
	# Add host
	var host_label = Label.new()
	host_label.text = "Host (You)"
	host_label.add_theme_font_size_override("font_size", 14)
	host_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	player_list.add_child(host_label)
	
	# Add other players
	var players = WebRTCMultiplayer.get_players()
	for peer_id in players:
		var player_label = Label.new()
		player_label.text = "Player %d" % peer_id
		player_label.add_theme_font_size_override("font_size", 14)
		player_list.add_child(player_label)

# ==================== BUTTON HANDLERS ====================

func _on_connect_pressed() -> void:
	status_label.text = "Connecting..."
	WebRTCMultiplayer.connect_to_signaling()

func _on_create_pressed() -> void:
	generated_room_code = WebRTCMultiplayer.create_room()
	_update_ui()

func _on_join_pressed() -> void:
	var code = room_code_input.text.strip_edges().to_upper()
	if code.length() == 6:
		WebRTCMultiplayer.join_room(code)

func _on_leave_pressed() -> void:
	WebRTCMultiplayer.leave_room()
	_update_ui()

func _on_start_pressed() -> void:
	game_starting.emit()
	visible = false

func _on_copy_pressed() -> void:
	if room_code_display.text != "--------":
		DisplayServer.clipboard_set(room_code_display.text)
		status_label.text = "Room code copied!"
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(_update_ui)

func _on_close_pressed() -> void:
	visible = false
	lobby_closed.emit()

# ==================== SIGNAL HANDLERS ====================

func _on_connected_to_server() -> void:
	status_label.text = "Connected to server!"
	_update_ui()

func _on_disconnected_from_server() -> void:
	status_label.text = "Disconnected from server"
	_update_ui()

func _on_room_joined(code: String) -> void:
	room_code_display.text = code
	_update_ui()

func _on_player_joined(peer_id: int, info: Dictionary) -> void:
	_update_player_list()
	status_label.text = "Player %d joined" % peer_id

func _on_player_left(peer_id: int) -> void:
	_update_player_list()
	status_label.text = "Player %d left" % peer_id

func _on_connection_failed() -> void:
	status_label.text = "Connection failed"
	_update_ui()
