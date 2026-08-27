extends CanvasLayer

## SimulationControls - Start/Pause/End simulation with proper styling

var start_button: Button
var pause_button: Button
var resume_button: Button
var end_button: Button
var camera_reset_button: Button

func _ready() -> void:
	_create_ui()
	_update_button_states()

func _create_ui() -> void:
	var container = VBoxContainer.new()
	container.name = "ControlsContainer"
	container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	container.offset_left = -170
	container.offset_top = -280
	container.offset_right = -10
	container.offset_bottom = -10
	container.add_theme_constant_override("separation", 8)
	add_child(container)

	var title = Label.new()
	title.text = "SIMULATION"
	title.add_theme_font_size_override("font_size", 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.5, 0.6, 0.55))
	container.add_child(title)

	start_button = _create_button("START SIMULATION", Color(0.15, 0.6, 0.3))
	start_button.pressed.connect(_on_start_pressed)
	container.add_child(start_button)

	pause_button = _create_button("PAUSE", Color(0.6, 0.5, 0.15))
	pause_button.pressed.connect(_on_pause_pressed)
	container.add_child(pause_button)

	resume_button = _create_button("RESUME", Color(0.2, 0.5, 0.7))
	resume_button.pressed.connect(_on_resume_pressed)
	container.add_child(resume_button)

	end_button = _create_button("END SIMULATION", Color(0.7, 0.2, 0.2))
	end_button.pressed.connect(_on_end_pressed)
	container.add_child(end_button)

	camera_reset_button = _create_button("RESET CAMERA", Color(0.3, 0.3, 0.4))
	camera_reset_button.pressed.connect(_on_camera_reset_pressed)
	container.add_child(camera_reset_button)

func _create_button(text: String, color: Color) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(155, 42)
	button.add_theme_font_size_override("font_size", 12)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 2
	button.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.15)
	button.add_theme_stylebox_override("hover", hover)

	var pressed = style.duplicate()
	pressed.bg_color = color.darkened(0.2)
	button.add_theme_stylebox_override("pressed", pressed)

	var disabled = style.duplicate()
	disabled.bg_color = color.darkened(0.4)
	disabled.bg_color.a = 0.4
	button.add_theme_stylebox_override("disabled", disabled)

	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))

	return button

func _on_start_pressed() -> void:
	SimulationManager.start_simulation()
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr:
		interaction_mgr.start_appendicectomy()
	_update_button_states()

func _on_pause_pressed() -> void:
	SimulationManager.pause_simulation()
	_update_button_states()

func _on_resume_pressed() -> void:
	SimulationManager.resume_simulation()
	_update_button_states()

func _on_end_pressed() -> void:
	SimulationManager.end_simulation()
	_update_button_states()

func _on_camera_reset_pressed() -> void:
	var camera = get_viewport().get_camera_3d()
	if camera and camera.has_method("reset_camera"):
		camera.reset_camera()

func _process(_delta: float) -> void:
	_update_button_states()

func _update_button_states() -> void:
	if not start_button:
		return
	var state = SimulationManager.current_state
	start_button.disabled = (state != SimulationManager.SimulationState.NOT_STARTED and
							state != SimulationManager.SimulationState.ENDED)
	pause_button.disabled = (state != SimulationManager.SimulationState.RUNNING)
	resume_button.disabled = (state != SimulationManager.SimulationState.PAUSED)
	end_button.disabled = (state != SimulationManager.SimulationState.RUNNING and
						  state != SimulationManager.SimulationState.PAUSED)
