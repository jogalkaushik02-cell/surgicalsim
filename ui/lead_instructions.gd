extends CanvasLayer

## LeadInstructions - Lead surgeon can instruct team

var is_visible: bool = false
var current_mode: String = "none"  # none, instruct, command

# UI elements
var panel: PanelContainer = null
var command_buttons: VBoxContainer = null
var text_input: LineEdit = null
var send_button: Button = null
var close_button: Button = null

# Pre-defined commands the lead can give
var lead_commands: Dictionary = {
	"instruments": [
		{"id": "pass_scalpel", "text": "Pass me the Scalpel", "target": "nurse"},
		{"id": "pass_forceps", "text": "Pass me the Forceps", "target": "nurse"},
		{"id": "pass_retractor", "text": "Pass me the Retractor", "target": "nurse"},
		{"id": "pass_suture", "text": "Pass me the Suture", "target": "nurse"}
	],
	"actions": [
		{"id": "retract_now", "text": "Retract now", "target": "assistant"},
		{"id": "hold_tissue", "text": "Hold this tissue", "target": "assistant"},
		{"id": "apply_pressure", "text": "Apply pressure here", "target": "assistant"},
		{"id": "check_vitals", "text": "Check vitals", "target": "anesthesia"}
	],
	"warnings": [
		{"id": "watch_bleeding", "text": "Watch for bleeding", "target": "all"},
		{"id": "stop", "text": "Stop/Wait", "target": "all"},
		{"id": "careful", "text": "Be careful", "target": "all"},
		{"id": "steady", "text": "Steady hands", "target": "assistant"}
	],
	"feedback": [
		{"id": "good_job", "text": "Good job", "target": "all"},
		{"id": "perfect", "text": "Perfect", "target": "all"},
		{"id": "next_step", "text": "Moving to next step", "target": "all"},
		{"id": "ready", "text": "Ready?", "target": "all"}
	]
}

signal command_sent(command_id: String, text: String, target: String)
signal custom_instruction_sent(text: String)
signal lead_panel_toggled(visible: bool)

func _ready() -> void:
	_create_ui()
	hide()

func _create_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "LeadInstructionsPanel"
	panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	panel.offset_left = 10
	panel.offset_top = 100
	panel.offset_right = 250
	panel.offset_bottom = -100
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "TEAM COMMANDS"
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Scroll container for commands
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	command_buttons = VBoxContainer.new()
	command_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(command_buttons)
	
	# Create command buttons
	_create_command_sections()
	
	# Custom instruction input
	var input_container = HBoxContainer.new()
	vbox.add_child(input_container)
	
	text_input = LineEdit.new()
	text_input.name = "CustomInput"
	text_input.placeholder_text = "Type instruction..."
	text_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_input.text_submitted.connect(_on_custom_text_submitted)
	input_container.add_child(text_input)
	
	send_button = Button.new()
	send_button.text = "Send"
	send_button.custom_minimum_size = Vector2(60, 0)
	send_button.pressed.connect(_on_send_pressed)
	input_container.add_child(send_button)
	
	# Close button
	close_button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(0, 40)
	close_button.pressed.connect(_on_close_pressed)
	vbox.add_child(close_button)

func _create_command_sections() -> void:
	for category in lead_commands:
		# Category header
		var header = Label.new()
		header.text = category.to_upper()
		header.add_theme_font_size_override("font_size", 12)
		header.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		command_buttons.add_child(header)
		
		# Command buttons
		for command in lead_commands[category]:
			var btn = Button.new()
			btn.text = command["text"]
			btn.custom_minimum_size = Vector2(0, 35)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(_on_command_pressed.bind(command["id"], command["text"], command["target"]))
			command_buttons.add_child(btn)
		
		# Spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		command_buttons.add_child(spacer)

func _on_command_pressed(command_id: String, text: String, target: String) -> void:
	# Send command through communication system
	var comm_system = get_node_or_null("/root/MainScene/CommunicationSystem")
	if comm_system:
		var peer_id = NetworkManager.get_peer_id()
		comm_system.send_instruction(text, RoleSystem.Role.LEAD_SURGEON, peer_id, "Lead Surgeon")
	
	# Play sound
	SoundManager.play_monitor_beep()
	
	# Haptic feedback
	if OS.has_feature("android"):
		Input.vibrate_handheld(30)
	
	command_sent.emit(command_id, text, target)
	Events.log_event("lead_command", {"command": command_id, "text": text, "target": target})

func _on_custom_text_submitted(text: String) -> void:
	if text.is_empty():
		return
	
	var comm_system = get_node_or_null("/root/MainScene/CommunicationSystem")
	if comm_system:
		var peer_id = NetworkManager.get_peer_id()
		comm_system.send_instruction(text, RoleSystem.Role.LEAD_SURGEON, peer_id, "Lead Surgeon")
	
	custom_instruction_sent.emit(text)
	text_input.text = ""
	Events.log_event("lead_custom_instruction", {"text": text})

func _on_send_pressed() -> void:
	_on_custom_text_submitted(text_input.text)

func _on_close_pressed() -> void:
	hide()

func show() -> void:
	visible = true
	is_visible = true
	lead_panel_toggled.emit(true)

func hide() -> void:
	visible = false
	is_visible = false
	lead_panel_toggled.emit(false)

func toggle() -> void:
	if is_visible:
		hide()
	else:
		show()
