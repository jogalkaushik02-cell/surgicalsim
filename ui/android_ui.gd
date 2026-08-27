extends CanvasLayer

## AndroidUI - Android-optimized touch interface

var is_android: bool = false
var touch_button_size: Vector2 = Vector2(80, 80)
var touch_margin: int = 20

# Touch button references
var instrument_buttons: Dictionary = {}
var action_button: Button = null
var guidance_label: Label = null
var bleeding_indicator: PanelContainer = null

func _ready() -> void:
	hide()
	is_android = OS.get_name() == "Android"
	_create_ui()
	_update_touch_settings()
	Events.simulation_started.connect(func(): show())
	Events.simulation_ended.connect(func(): hide())

func _create_ui() -> void:
	_create_instrument_panel()
	_create_action_button()
	_create_guidance_panel()
	_create_bleeding_indicator()

func _create_instrument_panel() -> void:
	var panel = PanelContainer.new()
	panel.name = "InstrumentPanel"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = touch_margin
	panel.offset_top = -250
	panel.offset_right = 200
	panel.offset_bottom = -touch_margin
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "INSTRUMENTS"
	title.add_theme_font_size_override("font_size", 14)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var instruments = ["Scalpel", "Forceps", "Retractor", "Suture"]
	for instrument in instruments:
		var btn = Button.new()
		btn.name = instrument + "Button"
		btn.text = instrument
		btn.custom_minimum_size = touch_button_size
		btn.pressed.connect(_on_instrument_pressed.bind(instrument))
		vbox.add_child(btn)
		instrument_buttons[instrument] = btn

func _create_action_button() -> void:
	action_button = Button.new()
	action_button.name = "ActionButton"
	action_button.text = "USE"
	action_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	action_button.offset_left = -120
	action_button.offset_top = -120
	action_button.offset_right = -touch_margin
	action_button.offset_bottom = -touch_margin
	action_button.custom_minimum_size = Vector2(100, 100)
	action_button.pressed.connect(_on_action_pressed)
	add_child(action_button)

func _create_guidance_panel() -> void:
	var panel = PanelContainer.new()
	panel.name = "GuidancePanel"
	panel.set_anchors_preset(Control.PRESET_TOP)
	panel.offset_left = 200
	panel.offset_top = touch_margin
	panel.offset_right = -200
	panel.offset_bottom = 100
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	guidance_label = Label.new()
	guidance_label.name = "GuidanceLabel"
	guidance_label.text = "Select an instrument to begin"
	guidance_label.add_theme_font_size_override("font_size", 16)
	guidance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(guidance_label)

func _create_bleeding_indicator() -> void:
	bleeding_indicator = PanelContainer.new()
	bleeding_indicator.name = "BleedingIndicator"
	bleeding_indicator.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	bleeding_indicator.offset_left = -150
	bleeding_indicator.offset_top = 110
	bleeding_indicator.offset_right = -touch_margin
	bleeding_indicator.offset_bottom = 150
	bleeding_indicator.visible = false
	add_child(bleeding_indicator)
	
	var margin = MarginContainer.new()
	bleeding_indicator.add_child(margin)
	
	var label = Label.new()
	label.text = "BLEEDING"
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(label)

func _on_instrument_pressed(instrument_name: String) -> void:
	SimulationManager.select_instrument(instrument_name)
	Events.instrument_selected.emit(instrument_name)
	
	# Highlight selected button
	for btn_name in instrument_buttons:
		var btn = instrument_buttons[btn_name]
		if btn_name == instrument_name:
			btn.add_theme_stylebox_override("normal", _create_highlight_style())
		else:
			btn.add_theme_stylebox_override("normal", null)

func _on_action_pressed() -> void:
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr:
		interaction_mgr.use_current_instrument()

func _update_touch_settings() -> void:
	if is_android:
		touch_button_size = Vector2(100, 100)
		touch_margin = 30
	else:
		touch_button_size = Vector2(80, 80)
		touch_margin = 20

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

func _create_highlight_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.5, 0.8, 0.8)
	style.border_color = Color(0.5, 0.7, 1.0)
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	return style
