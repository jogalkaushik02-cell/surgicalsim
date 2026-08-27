extends CanvasLayer

## InstructorBar - App gives instructions to all players

var is_visible: bool = true
var current_instruction: String = ""
var instruction_history: Array[Dictionary] = []

# UI elements
var panel: PanelContainer = null
var instruction_label: RichTextLabel = null
var hint_label: Label = null
var next_button: Button = null
var dismiss_button: Button = null

# Instructions for each surgical step
var step_instructions: Dictionary = {
	"READY": {
		"main": "Welcome to the Operating Room. Press Start to begin the procedure.",
		"hint": "Make sure all team members are ready.",
		"type": "info"
	},
	"INCISION": {
		"main": "[color=#FF6666]STEP 1: Make Incision[/color]\nSelect the Scalpel and tap on the Abdomen to make the initial incision.",
		"hint": "Use a steady hand. The incision should be 2-3 cm in the right lower quadrant.",
		"type": "action"
	},
	"RETRACT_ABDOMEN": {
		"main": "[color=#66FF66]STEP 2: Retract Abdomen[/color]\nThe Assistant should use the Retractor to expose the abdominal contents.",
		"hint": "Retract gently but firmly. Avoid excessive force.",
		"type": "action"
	},
	"LOCATE_APPENDIX": {
		"main": "[color=#6666FF]STEP 3: Locate Appendix[/color]\nUse the Retractor on the Cecum to find the appendix.",
		"hint": "The appendix is attached to the cecum, usually in the right lower quadrant.",
		"type": "action"
	},
	"GRASP_APPENDIX": {
		"main": "[color=#FFFF66]STEP 4: Grasp Appendix[/color]\nThe Assistant should grasp the appendix with Forceps.",
		"hint": "Grasp firmly but gently. Avoid tearing the tissue.",
		"type": "action"
	},
	"DIVIDE_MESENTERY": {
		"main": "[color=#FF6666]STEP 5: Divide Mesentery[/color]\nUse the Scalpel to carefully divide the mesentery.",
		"hint": "Watch for blood vessels. Control bleeding as you go.",
		"type": "warning"
	},
	"REMOVE_APPENDIX": {
		"main": "[color=#FF6666]STEP 6: Remove Appendix[/color]\nUse the Scalpel to remove the appendix at its base.",
		"hint": "Cut cleanly at the base. Ensure complete removal.",
		"type": "action"
	},
	"LIGATE_STUMP": {
		"main": "[color=#66FF66]STEP 7: Ligate Stump[/color]\nUse Suture to tie off the appendiceal stump.",
		"hint": "Use a secure knot. The stump should be invaginated.",
		"type": "action"
	},
	"CHECK_HEMOSTASIS": {
		"main": "[color=#6666FF]STEP 8: Check Hemostasis[/color]\nThe Assistant should check for any bleeding using Forceps.",
		"hint": "Ensure no active bleeding before closing.",
		"type": "check"
	},
	"CLOSE_INCISION": {
		"main": "[color=#FFFF66]STEP 9: Close Incision[/color]\nUse Suture to close the abdominal incision in layers.",
		"hint": "Close in layers: peritoneum, muscle, fascia, skin.",
		"type": "action"
	},
	"COMPLETED": {
		"main": "[color=#00FF00]PROCEDURE COMPLETE![/color]\nThe appendicectomy has been successfully completed!",
		"hint": "Review the results and check patient vitals.",
		"type": "success"
	}
}

# Complication messages
var complication_messages: Dictionary = {
	"bleeding": {
		"main": "[color=#FF0000]⚠ BLEEDING DETECTED[/color]\nApply pressure or use cautery to control bleeding.",
		"hint": "The Anesthesiologist should monitor vitals closely.",
		"type": "danger"
	},
	"vitals_unstable": {
		"main": "[color=#FF0000]⚠ VITALS UNSTABLE[/color]\nPatient vitals are dropping. Pause and assess.",
		"hint": "Check heart rate, blood pressure, and oxygen saturation.",
		"type": "danger"
	},
	"wrong_instrument": {
		"main": "[color=#FF9900]Wrong Instrument[/color]\nThat's not the correct instrument for this step.",
		"hint": "Check the instruction for the current step.",
		"type": "warning"
	},
	"wrong_target": {
		"main": "[color=#FF9900]Wrong Target[/color]\nThat's not the correct target for this action.",
		"hint": "Look at the anatomical structures carefully.",
		"type": "warning"
	}
}

signal instruction_changed(instruction: String)
signal instruction_dismissed()
signal hint_requested()

func _ready() -> void:
	_create_ui()
	Events.surgical_state_changed.connect(_on_surgical_state_changed)
	Events.cut_performed.connect(_on_cut_performed)

func _create_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "InstructorPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_top = 60
	panel.offset_bottom = 160
	panel.offset_left = 200
	panel.offset_right = -200
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	margin.add_child(hbox)
	
	# Instruction text
	instruction_label = RichTextLabel.new()
	instruction_label.name = "InstructionLabel"
	instruction_label.bbcode_enabled = true
	instruction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	instruction_label.fit_content = true
	hbox.add_child(instruction_label)
	
	# Button container
	var button_container = VBoxContainer.new()
	hbox.add_child(button_container)
	
	# Hint button
	var hint_button = Button.new()
	hint_button.text = "?"
	hint_button.custom_minimum_size = Vector2(30, 30)
	hint_button.pressed.connect(_on_hint_pressed)
	button_container.add_child(hint_button)
	
	# Dismiss button
	dismiss_button = Button.new()
	dismiss_button.text = "X"
	dismiss_button.custom_minimum_size = Vector2(30, 30)
	dismiss_button.pressed.connect(_on_dismiss_pressed)
	button_container.add_child(dismiss_button)
	
	# Hint label (hidden by default)
	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.add_theme_font_size_override("font_size", 14)
	hint_label.visible = false
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(hint_label)
	
	# Set initial instruction
	show_instruction("READY")

func _on_surgical_state_changed(_old_state: String, new_state: String) -> void:
	show_instruction(new_state)

func _on_cut_performed(_instrument: String, _target: String, result: String) -> void:
	if result == "INVALID":
		show_complication("wrong_instrument")

func show_instruction(step_name: String) -> void:
	var instruction_data = step_instructions.get(step_name, step_instructions["READY"])
	current_instruction = instruction_data["main"]
	
	if instruction_label:
		instruction_label.text = instruction_data["main"]
	
	if hint_label:
		hint_label.text = instruction_data.get("hint", "")
		hint_label.visible = false
	
	# Apply style based on type
	_apply_instruction_style(instruction_data.get("type", "info"))
	
	instruction_changed.emit(current_instruction)
	
	# Log instruction
	Events.log_event("instruction_shown", {"step": step_name, "instruction": current_instruction})

func show_complication(complication_type: String) -> void:
	var complication_data = complication_messages.get(complication_type)
	if not complication_data:
		return
	
	if instruction_label:
		instruction_label.text = complication_data["main"]
	
	if hint_label:
		hint_label.text = complication_data.get("hint", "")
	
	# Show complications prominently
	_apply_instruction_style(complication_data.get("type", "warning"))
	
	# Play alert sound
	SoundManager.play_alert("warning")
	
	Events.log_event("complication_shown", {"type": complication_type})

func show_custom_instruction(text: String, type: String = "info") -> void:
	if instruction_label:
		instruction_label.text = text
	_apply_instruction_style(type)
	instruction_changed.emit(text)

func _apply_instruction_style(type: String) -> void:
	if not panel:
		return
	
	var style = StyleBoxFlat.new()
	match type:
		"action":
			style.bg_color = Color(0.1, 0.2, 0.4, 0.9)
			style.border_color = Color(0.3, 0.5, 0.8)
		"warning":
			style.bg_color = Color(0.4, 0.3, 0.1, 0.9)
			style.border_color = Color(0.8, 0.6, 0.2)
		"danger":
			style.bg_color = Color(0.4, 0.1, 0.1, 0.9)
			style.border_color = Color(0.8, 0.2, 0.2)
		"success":
			style.bg_color = Color(0.1, 0.3, 0.1, 0.9)
			style.border_color = Color(0.2, 0.8, 0.2)
		"check":
			style.bg_color = Color(0.1, 0.2, 0.3, 0.9)
			style.border_color = Color(0.3, 0.5, 0.7)
		_:
			style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
			style.border_color = Color(0.3, 0.3, 0.4)
	
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	
	panel.add_theme_stylebox_override("panel", style)

func _on_hint_pressed() -> void:
	if hint_label:
		hint_label.visible = not hint_label.visible
		hint_requested.emit()

func _on_dismiss_pressed() -> void:
	if panel:
		panel.visible = false
	instruction_dismissed.emit()

func show() -> void:
	if panel:
		panel.visible = true
	is_visible = true

func hide() -> void:
	if panel:
		panel.visible = false
	is_visible = false

func get_current_instruction() -> String:
	return current_instruction
