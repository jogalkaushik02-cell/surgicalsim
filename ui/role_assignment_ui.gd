extends CanvasLayer

## RoleAssignmentUI - UI for assigning roles in multiplayer

var is_visible: bool = false
var role_buttons: Dictionary = {}
var player_list: VBoxContainer = null
var start_button: Button = null
var close_button: Button = null

func _ready() -> void:
	_create_ui()
	hide()
	Events.simulation_started.connect(_on_simulation_started)

func _create_ui() -> void:
	# Main panel
	var panel = PanelContainer.new()
	panel.name = "RoleAssignmentPanel"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 200
	panel.offset_top = 100
	panel.offset_right = -200
	panel.offset_bottom = -100
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "ROLE ASSIGNMENT"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	# Player list section
	var player_section = VBoxContainer.new()
	vbox.add_child(player_section)
	
	var player_title = Label.new()
	player_title.text = "CONNECTED PLAYERS"
	player_title.add_theme_font_size_override("font_size", 18)
	player_section.add_child(player_title)
	
	player_list = VBoxContainer.new()
	player_section.add_child(player_list)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer2)
	
	# Role assignment section
	var role_section = VBoxContainer.new()
	vbox.add_child(role_section)
	
	var role_title = Label.new()
	role_title.text = "ASSIGN ROLES"
	role_title.add_theme_font_size_override("font_size", 18)
	role_section.add_child(role_title)
	
	# Create role assignment buttons
	_create_role_section(role_section)
	
	# Spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer3)
	
	# AI info
	var ai_info = RichTextLabel.new()
	ai_info.bbcode_enabled = true
	ai_info.text = "[center]Unfilled roles will be handled by AI[/center]"
	ai_info.add_theme_font_size_override("font_size", 14)
	vbox.add_child(ai_info)
	
	# Spacer
	var spacer4 = Control.new()
	spacer4.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer4)
	
	# Buttons
	var button_container = HBoxContainer.new()
	button_container.alignment = Alignment.ALIGNMENT_CENTER
	vbox.add_child(button_container)
	
	start_button = Button.new()
	start_button.text = "Start Surgery"
	start_button.custom_minimum_size = Vector2(150, 50)
	start_button.pressed.connect(_on_start_pressed)
	button_container.add_child(start_button)
	
	var spacer5 = Control.new()
	spacer5.custom_minimum_size = Vector2(20, 0)
	button_container.add_child(spacer5)
	
	close_button = Button.new()
	close_button.text = "Cancel"
	close_button.custom_minimum_size = Vector2(150, 50)
	close_button.pressed.connect(_on_close_pressed)
	button_container.add_child(close_button)

func _create_role_section(parent: Control) -> void:
	var roles = RoleSystem.get_all_roles()
	
	for role in roles:
		var role_container = HBoxContainer.new()
		parent.add_child(role_container)
		
		var role_label = Label.new()
		role_label.text = RoleSystem.get_role_name(role) + ":"
		role_label.add_theme_font_size_override("font_size", 16)
		role_label.custom_minimum_size = Vector2(150, 0)
		role_container.add_child(role_label)
		
		var assigned_label = Label.new()
		assigned_label.name = "Assigned_" + str(role)
		assigned_label.text = "AI"
		assigned_label.add_theme_font_size_override("font_size", 16)
		assigned_label.custom_minimum_size = Vector2(150, 0)
		role_container.add_child(assigned_label)
		
		if NetworkManager.is_host:
			var assign_button = Button.new()
			assign_button.text = "Assign"
			assign_button.custom_minimum_size = Vector2(80, 30)
			assign_button.pressed.connect(_on_assign_role_pressed.bind(role))
			role_container.add_child(assign_button)
			role_buttons[role] = assign_button

func update_player_list() -> void:
	if not player_list:
		return
	
	# Clear existing list
	for child in player_list.get_children():
		child.queue_free()
	
	# Add each player
	var players = NetworkManager.get_player_list()
	for player in players:
		var player_row = HBoxContainer.new()
		player_list.add_child(player_row)
		
		var name_label = Label.new()
		name_label.text = player.get("name", "Unknown")
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.custom_minimum_size = Vector2(150, 0)
		player_row.add_child(name_label)
		
		var role = player.get("role", -1)
		var role_label = Label.new()
		if role >= 0:
			role_label.text = RoleSystem.get_role_name(role)
		else:
			role_label.text = "Unassigned"
		role_label.add_theme_font_size_override("font_size", 16)
		player_row.add_child(role_label)

func _on_assign_role_pressed(role: int) -> void:
	# For now, assign to first unassigned player
	var players = NetworkManager.get_player_list()
	for player in players:
		if player.get("role", -1) == -1:
			NetworkManager.assign_role(player["id"], role)
			player["role"] = role
			break
	
	update_player_list()

func _on_start_pressed() -> void:
	# Start the game
	NetworkManager.start_game.rpc()
	hide()
	Events.log_event("role_assignment_completed")

func _on_close_pressed() -> void:
	hide()

func _on_simulation_started() -> void:
	hide()

func show() -> void:
	visible = true
	is_visible = true
	update_player_list()

func hide() -> void:
	visible = false
	is_visible = false

func _process(_delta: float) -> void:
	if is_visible:
		update_player_list()
