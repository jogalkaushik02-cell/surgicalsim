extends CanvasLayer

## HUD - Complete surgical simulation heads-up display

# UI references
var top_bar: HBoxContainer
var procedure_label: Label
var mode_label: Label
var role_label: Label
var time_label: Label
var score_label: Label

# Patient vitals
var hr_label: Label
var bp_label: Label
var spo2_label: Label
var rr_label: Label
var blood_loss_label: Label
var status_label: Label

# Surgical status
var state_label: Label
var instrument_label: Label
var target_label: Label
var step_label: Label
var progress_label: Label

# Event feed
var event_feed: VBoxContainer
var event_scroll: ScrollContainer
var max_events: int = 8

# Selection feedback
var selection_panel: PanelContainer
var selection_name: Label
var selection_action: Label

# Interaction help
var help_label: Label

func _ready() -> void:
	_create_ui()
	Events.patient_vitals_changed.connect(_on_vitals_changed)
	Events.cut_performed.connect(_on_cut_performed)
	Events.surgical_state_changed.connect(_on_surgical_state_changed)
	Events.instrument_selected.connect(_on_instrument_selected)
	Events.anatomy_selected.connect(_on_anatomy_selected)
	Events.log_event("hud_initialized")

func _create_ui() -> void:
	# Top info bar
	_create_top_bar()
	# Left side - vitals panel
	_create_vitals_panel()
	# Right side - surgical status
	_create_surgical_panel()
	# Bottom center - selection feedback
	_create_selection_panel()
	# Bottom left - event feed
	_create_event_feed()
	# Top center - interaction help
	_create_help_panel()

func _create_top_bar() -> void:
	top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = 10
	top_bar.offset_top = 5
	top_bar.offset_right = -10
	top_bar.offset_bottom = 35
	add_child(top_bar)

	# Procedure info
	var info_container = VBoxContainer.new()
	info_container.add_theme_constant_override("separation", 2)
	top_bar.add_child(info_container)

	procedure_label = Label.new()
	procedure_label.text = "Open Appendicectomy"
	procedure_label.add_theme_font_size_override("font_size", 16)
	procedure_label.add_theme_color_override("font_color", Color(1, 1, 1))
	info_container.add_child(procedure_label)

	var sub_info = HBoxContainer.new()
	sub_info.add_theme_constant_override("separation", 15)
	info_container.add_child(sub_info)

	mode_label = Label.new()
	mode_label.text = "Single Player"
	mode_label.add_theme_font_size_override("font_size", 12)
	mode_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7))
	sub_info.add_child(mode_label)

	role_label = Label.new()
	role_label.text = "Role: Lead Surgeon"
	role_label.add_theme_font_size_override("font_size", 12)
	role_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.6))
	sub_info.add_child(role_label)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	# Time
	time_label = Label.new()
	time_label.text = "00:00"
	time_label.add_theme_font_size_override("font_size", 20)
	time_label.add_theme_color_override("font_color", Color(1, 1, 1))
	top_bar.add_child(time_label)

	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer2)

	# Score
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.5))
	top_bar.add_child(score_label)

func _create_vitals_panel() -> void:
	var panel = PanelContainer.new()
	panel.name = "VitalsPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 10
	panel.offset_top = 45
	panel.offset_right = 200
	panel.offset_bottom = 260
	add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.12, 0.85)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_color = Color(0.2, 0.5, 0.3, 0.6)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "PATIENT VITALS"
	title.add_theme_font_size_override("font_size", 12)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.4, 0.8, 0.5))
	vbox.add_child(title)

	hr_label = _create_vital_label("HR: 72 bpm")
	vbox.add_child(hr_label)

	bp_label = _create_vital_label("BP: 120/80 mmHg")
	vbox.add_child(bp_label)

	spo2_label = _create_vital_label("SpO2: 98%")
	vbox.add_child(spo2_label)

	rr_label = _create_vital_label("RR: 16 /min")
	vbox.add_child(rr_label)

	blood_loss_label = _create_vital_label("Blood Loss: 0 mL")
	vbox.add_child(blood_loss_label)

	status_label = _create_vital_label("Status: STABLE")
	status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
	vbox.add_child(status_label)

func _create_vital_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	return label

func _create_surgical_panel() -> void:
	var panel = PanelContainer.new()
	panel.name = "SurgicalPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -210
	panel.offset_top = 45
	panel.offset_right = -10
	panel.offset_bottom = 260
	add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.05, 0.12, 0.85)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_color = Color(0.4, 0.3, 0.6, 0.6)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "SURGICAL STATUS"
	title.add_theme_font_size_override("font_size", 12)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.5, 0.4, 0.8))
	vbox.add_child(title)

	state_label = _create_status_label("State: READY")
	vbox.add_child(state_label)

	instrument_label = _create_status_label("Instrument: None")
	vbox.add_child(instrument_label)

	target_label = _create_status_label("Target: None")
	vbox.add_child(target_label)

	step_label = _create_status_label("Step: NOT STARTED")
	vbox.add_child(step_label)

	progress_label = _create_status_label("Progress: 0%")
	vbox.add_child(progress_label)

	var interactions_label = _create_status_label("Interactions: 0")
	vbox.add_child(interactions_label)
	surgical_labels["interactions"] = interactions_label

var surgical_labels: Dictionary = {}

func _create_status_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	return label

func _create_selection_panel() -> void:
	selection_panel = PanelContainer.new()
	selection_panel.name = "SelectionPanel"
	selection_panel.set_anchors_preset(Control.PRESET_BOTTOM)
	selection_panel.offset_left = -150
	selection_panel.offset_top = -80
	selection_panel.offset_right = 150
	selection_panel.offset_bottom = -10
	selection_panel.visible = false
	add_child(selection_panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.15, 0.2, 0.9)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.3, 0.7, 0.5, 0.7)
	selection_panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	selection_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	selection_name = Label.new()
	selection_name.text = ""
	selection_name.add_theme_font_size_override("font_size", 14)
	selection_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_name.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(selection_name)

	selection_action = Label.new()
	selection_action.text = ""
	selection_action.add_theme_font_size_override("font_size", 12)
	selection_action.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_action.add_theme_color_override("font_color", Color(0.6, 0.9, 0.7))
	vbox.add_child(selection_action)

func _create_event_feed() -> void:
	var panel = PanelContainer.new()
	panel.name = "EventFeedPanel"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = 10
	panel.offset_top = -180
	panel.offset_right = 250
	panel.offset_bottom = -10
	add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.75)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_color = Color(0.3, 0.3, 0.4, 0.5)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "EVENTS"
	title.add_theme_font_size_override("font_size", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	vbox.add_child(title)

	event_scroll = ScrollContainer.new()
	event_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_scroll.custom_minimum_size = Vector2(0, 120)
	vbox.add_child(event_scroll)

	event_feed = VBoxContainer.new()
	event_feed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_feed.add_theme_constant_override("separation", 1)
	event_scroll.add_child(event_feed)

func _create_help_panel() -> void:
	help_label = Label.new()
	help_label.name = "HelpLabel"
	help_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	help_label.offset_left = 220
	help_label.offset_top = 40
	help_label.offset_right = -220
	help_label.offset_bottom = 65
	help_label.text = "SELECT INSTRUMENT > TAP STRUCTURE > INTERACT"
	help_label.add_theme_font_size_override("font_size", 11)
	help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	help_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.7, 0.8))
	add_child(help_label)

func _on_vitals_changed(vitals: Dictionary) -> void:
	if hr_label:
		hr_label.text = "HR: %d bpm" % vitals.get("heart_rate", 72)
	if bp_label:
		bp_label.text = "BP: %d/%d mmHg" % [vitals.get("systolic_bp", 120), vitals.get("diastolic_bp", 80)]
	if spo2_label:
		spo2_label.text = "SpO2: %d%%" % vitals.get("spo2", 98)
	if rr_label:
		rr_label.text = "RR: %d /min" % vitals.get("respiratory_rate", 16)
	if blood_loss_label:
		var bleeding_sim = get_node_or_null("/root/MainScene/BleedingSimulation")
		if bleeding_sim and bleeding_sim.is_bleeding:
			blood_loss_label.text = "Blood Loss: %d mL" % int(bleeding_sim.blood_loss)
			blood_loss_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
			if status_label:
				status_label.text = "Status: BLEEDING"
				status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		else:
			blood_loss_label.text = "Blood Loss: 0 mL"
			blood_loss_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
			if status_label:
				status_label.text = "Status: STABLE"
				status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))

func _on_cut_performed(instrument: String, target: String, result: String) -> void:
	if surgical_labels.has("interactions"):
		surgical_labels["interactions"].text = "Interactions: %d" % SimulationManager.interaction_count
	_add_event("%s on %s - %s" % [instrument, target, result])

func _on_surgical_state_changed(_old: String, new_state: String) -> void:
	if state_label:
		state_label.text = "State: " + new_state

func _on_instrument_selected(instrument_name: String) -> void:
	if instrument_label:
		instrument_label.text = "Instrument: " + instrument_name
	_update_selection_display()
	_add_event("Selected: %s" % instrument_name)

func _on_anatomy_selected(anatomy_name: String) -> void:
	if target_label:
		target_label.text = "Target: " + anatomy_name
	_update_selection_display()
	_add_event("Targeted: %s" % anatomy_name)

func _update_selection_display() -> void:
	var inst = SimulationManager.selected_instrument
	var tgt = SimulationManager.selected_anatomy
	if inst != "None" or tgt != "None":
		selection_panel.visible = true
		if selection_name:
			selection_name.text = "TARGET: %s" % tgt
		if selection_action:
			selection_action.text = "INSTRUMENT: %s" % inst
	else:
		selection_panel.visible = false

func _add_event(text: String) -> void:
	if not event_feed:
		return
	var time_str = SimulationManager.get_formatted_time()
	var event_label = Label.new()
	event_label.text = "%s — %s" % [time_str, text]
	event_label.add_theme_font_size_override("font_size", 9)
	event_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_feed.add_child(event_label)

	# Limit events
	while event_feed.get_child_count() > max_events:
		var oldest = event_feed.get_child(0)
		if oldest:
			oldest.queue_free()

func _process(_delta: float) -> void:
	_update_display()

func _update_display() -> void:
	if time_label:
		time_label.text = SimulationManager.get_formatted_time()
	if score_label:
		score_label.text = "Score: %d" % SimulationManager.score
	if instrument_label:
		instrument_label.text = "Instrument: " + SimulationManager.selected_instrument
	if target_label:
		target_label.text = "Target: " + SimulationManager.selected_anatomy
	if state_label:
		state_label.text = "State: " + SimulationManager.get_surgical_state_name()

	# Update appendicectomy progress
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr and interaction_mgr.appendicectomy_sm:
		var progress = interaction_mgr.appendicectomy_sm.get_progress()
		if step_label:
			step_label.text = "Step: " + progress.get("current_step_name", "NOT_STARTED")
		if progress_label:
			progress_label.text = "Progress: %d%%" % progress.get("progress_percent", 0)
