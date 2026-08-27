extends CanvasLayer

## AndroidUI - Android-optimized touch instrument toolbar

var is_android: bool = false
var instrument_buttons: Dictionary = {}
var action_button: Button = null
var guidance_label: Label = null
var bleeding_indicator: PanelContainer = null

func _ready() -> void:
	is_android = OS.get_name() == "Android"
	_create_ui()
	Events.simulation_started.connect(func(): show())
	Events.simulation_ended.connect(func(): hide())
	Events.instrument_selected.connect(_on_instrument_update)

func _create_ui() -> void:
	_create_instrument_toolbar()
	_create_action_button()
	_create_guidance_panel()
	_create_bleeding_indicator()

func _create_instrument_toolbar() -> void:
	var panel = PanelContainer.new()
	panel.name = "InstrumentPanel"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = 10
	panel.offset_top = -200
	panel.offset_right = 260
	panel.offset_bottom = -10
	add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.14, 0.85)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_color = Color(0.3, 0.4, 0.35, 0.6)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "INSTRUMENTS"
	title.add_theme_font_size_override("font_size", 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.5, 0.65, 0.55))
	vbox.add_child(title)

	var instruments = ["Scalpel", "Forceps", "Retractor", "Suture"]
	var btn_size = Vector2(110, 40) if is_android else Vector2(100, 36)

	for instrument in instruments:
		var btn = Button.new()
		btn.name = instrument + "Btn"
		btn.text = instrument
		btn.custom_minimum_size = btn_size
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(_on_instrument_pressed.bind(instrument))

		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.18, 0.22, 0.28, 0.9)
		btn_style.corner_radius_top_left = 6
		btn_style.corner_radius_top_right = 6
		btn_style.corner_radius_bottom_left = 6
		btn_style.corner_radius_bottom_right = 6
		btn_style.border_width_top = 1
		btn_style.border_width_bottom = 1
		btn_style.border_width_left = 1
		btn_style.border_width_right = 1
		btn_style.border_color = Color(0.35, 0.4, 0.38, 0.6)
		btn.add_theme_stylebox_override("normal", btn_style)

		var btn_hover = btn_style.duplicate()
		btn_hover.bg_color = Color(0.22, 0.28, 0.35, 0.95)
		btn.add_theme_stylebox_override("hover", btn_hover)

		btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
		vbox.add_child(btn)
		instrument_buttons[instrument] = btn

func _create_action_button() -> void:
	action_button = Button.new()
	action_button.name = "ActionButton"
	action_button.text = "USE"
	action_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	action_button.offset_left = -100
	action_button.offset_top = -100
	action_button.offset_right = -10
	action_button.offset_bottom = -10
	action_button.custom_minimum_size = Vector2(85, 85)
	action_button.add_theme_font_size_override("font_size", 16)
	action_button.pressed.connect(_on_action_pressed)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.5, 0.3, 0.9)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	action_button.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.25, 0.6, 0.35, 0.95)
	action_button.add_theme_stylebox_override("hover", hover)

	action_button.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(action_button)

func _create_guidance_panel() -> void:
	var panel = PanelContainer.new()
	panel.name = "GuidancePanel"
	panel.set_anchors_preset(Control.PRESET_TOP)
	panel.offset_left = 280
	panel.offset_top = 10
	panel.offset_right = -110
	panel.offset_bottom = 50
	add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.18, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_color = Color(0.3, 0.5, 0.4, 0.5)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	guidance_label = Label.new()
	guidance_label.name = "GuidanceLabel"
	guidance_label.text = "Select an instrument, then tap the patient"
	guidance_label.add_theme_font_size_override("font_size", 12)
	guidance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guidance_label.add_theme_color_override("font_color", Color(0.7, 0.85, 0.75))
	margin.add_child(guidance_label)

func _create_bleeding_indicator() -> void:
	bleeding_indicator = PanelContainer.new()
	bleeding_indicator.name = "BleedingIndicator"
	bleeding_indicator.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	bleeding_indicator.offset_left = -140
	bleeding_indicator.offset_top = 55
	bleeding_indicator.offset_right = -10
	bleeding_indicator.offset_bottom = 85
	bleeding_indicator.visible = false
	add_child(bleeding_indicator)

	var margin = MarginContainer.new()
	bleeding_indicator.add_child(margin)

	var label = Label.new()
	label.text = "BLEEDING"
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	margin.add_child(label)

func _on_instrument_pressed(instrument_name: String) -> void:
	SimulationManager.select_instrument(instrument_name)
	Events.instrument_selected.emit(instrument_name)
	_update_highlight(instrument_name)
	if guidance_label:
		guidance_label.text = "%s selected — tap a structure" % instrument_name

func _on_action_pressed() -> void:
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr:
		interaction_mgr.use_current_instrument()

func _on_instrument_update(instrument_name: String) -> void:
	_update_highlight(instrument_name)

func _update_highlight(selected: String) -> void:
	for inst_name in instrument_buttons:
		var btn = instrument_buttons[inst_name]
		if inst_name == selected:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.25, 0.5, 0.7, 0.9)
			style.corner_radius_top_left = 6
			style.corner_radius_top_right = 6
			style.corner_radius_bottom_left = 6
			style.corner_radius_bottom_right = 6
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_color = Color(0.4, 0.7, 1.0)
			btn.add_theme_stylebox_override("normal", style)
		else:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.18, 0.22, 0.28, 0.9)
			style.corner_radius_top_left = 6
			style.corner_radius_top_right = 6
			style.corner_radius_bottom_left = 6
			style.corner_radius_bottom_right = 6
			style.border_width_top = 1
			style.border_width_bottom = 1
			style.border_width_left = 1
			style.border_width_right = 1
			style.border_color = Color(0.35, 0.4, 0.38, 0.6)
			btn.add_theme_stylebox_override("normal", style)

func update_guidance(text: String) -> void:
	if guidance_label:
		guidance_label.text = text

func show_bleeding(severity: int) -> void:
	if bleeding_indicator:
		bleeding_indicator.visible = true
		var style = StyleBoxFlat.new()
		var color = Color(1.0, 0.2, 0.2, 0.3 + severity * 0.07)
		style.bg_color = color
		bleeding_indicator.add_theme_stylebox_override("panel", style)

func hide_bleeding() -> void:
	if bleeding_indicator:
		bleeding_indicator.visible = false
