extends CanvasLayer

## HUD - Heads-Up Display for simulation information

@onready var vital_labels: Dictionary = {}
@onready var debug_labels: Dictionary = {}
@onready var surgical_labels: Dictionary = {}
@onready var time_label: Label = null
@onready var event_count_label: Label = null
@onready var score_label: Label = null

func _ready() -> void:
	_create_ui()
	Events.patient_vitals_changed.connect(_on_vitals_changed)
	Events.cut_performed.connect(_on_cut_performed)
	Events.surgical_state_changed.connect(_on_surgical_state_changed)

func _create_ui() -> void:
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.offset_left = 10
	main_container.offset_top = 10
	main_container.offset_right = -10
	main_container.offset_bottom = -10
	add_child(main_container)
	
	_create_top_bar(main_container)
	_create_surgical_panel(main_container)
	_create_vital_signs_panel(main_container)
	_create_debug_display(main_container)

func _create_top_bar(parent: Control) -> void:
	var top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	parent.add_child(top_bar)
	
	time_label = Label.new()
	time_label.name = "TimeLabel"
	time_label.text = "Time: 00:00"
	time_label.add_theme_font_size_override("font_size", 16)
	top_bar.add_child(time_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "Score: 0/100"
	score_label.add_theme_font_size_override("font_size", 16)
	top_bar.add_child(score_label)
	
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer2)
	
	event_count_label = Label.new()
	event_count_label.name = "EventCountLabel"
	event_count_label.text = "Events: 0"
	event_count_label.add_theme_font_size_override("font_size", 16)
	top_bar.add_child(event_count_label)

func _create_surgical_panel(parent: Control) -> void:
	var panel = PanelContainer.new()
	panel.name = "SurgicalPanel"
	panel.custom_minimum_size = Vector2(180, 120)
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "SURGICAL STATUS"
	title.add_theme_font_size_override("font_size", 13)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var state_label = Label.new()
	state_label.name = "StateLabel"
	state_label.text = "State: READY"
	state_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(state_label)
	surgical_labels["state"] = state_label
	
	var inst_label = Label.new()
	inst_label.name = "InstrumentLabel"
	inst_label.text = "Instrument: None"
	inst_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(inst_label)
	surgical_labels["instrument"] = inst_label
	
	var target_label = Label.new()
	target_label.name = "TargetLabel"
	target_label.text = "Target: None"
	target_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(target_label)
	surgical_labels["target"] = target_label
	
	var interactions_label = Label.new()
	interactions_label.name = "InteractionsLabel"
	interactions_label.text = "Interactions: 0 (0 valid)"
	interactions_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(interactions_label)
	surgical_labels["interactions"] = interactions_label
	
	var step_label = Label.new()
	step_label.name = "StepLabel"
	step_label.text = "Step: NOT_STARTED"
	step_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(step_label)
	surgical_labels["step"] = step_label
	
	var progress_label = Label.new()
	progress_label.name = "ProgressLabel"
	progress_label.text = "Progress: 0%"
	progress_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(progress_label)
	surgical_labels["progress"] = progress_label

func _create_vital_signs_panel(parent: Control) -> void:
	var panel = PanelContainer.new()
	panel.name = "VitalSignsPanel"
	panel.custom_minimum_size = Vector2(180, 120)
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "VITAL SIGNS"
	title.add_theme_font_size_override("font_size", 13)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var vitals = ["HR", "BP", "SpO2", "RR", "Temp"]
	for vital in vitals:
		var label = Label.new()
		label.name = vital + "Label"
		label.text = vital + ": --"
		label.add_theme_font_size_override("font_size", 11)
		vbox.add_child(label)
		vital_labels[vital] = label

func _create_debug_display(parent: Control) -> void:
	var panel = PanelContainer.new()
	panel.name = "DebugPanel"
	panel.custom_minimum_size = Vector2(200, 70)
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "DEBUG INFO"
	title.add_theme_font_size_override("font_size", 11)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var debug_items = ["SelectedObj", "SelectedInst", "SimState"]
	for item in debug_items:
		var label = Label.new()
		label.name = item + "Label"
		label.text = item + ": --"
		label.add_theme_font_size_override("font_size", 10)
		vbox.add_child(label)
		debug_labels[item] = label

func _on_vitals_changed(vitals: Dictionary) -> void:
	if vital_labels.has("HR"):
		vital_labels["HR"].text = "HR: %d bpm" % vitals.get("heart_rate", 0)
	if vital_labels.has("BP"):
		vital_labels["BP"].text = "BP: %d/%d mmHg" % [vitals.get("systolic_bp", 0), vitals.get("diastolic_bp", 0)]
	if vital_labels.has("SpO2"):
		vital_labels["SpO2"].text = "SpO2: %d%%" % vitals.get("spo2", 0)
	if vital_labels.has("RR"):
		vital_labels["RR"].text = "RR: %d /min" % vitals.get("respiratory_rate", 0)
	if vital_labels.has("Temp"):
		vital_labels["Temp"].text = "Temp: %.1f°C" % vitals.get("temperature", 0.0)

func _on_cut_performed(instrument: String, target: String, result: String) -> void:
	if surgical_labels.has("interactions"):
		surgical_labels["interactions"].text = "Interactions: %d (%d valid)" % [SimulationManager.interaction_count, SimulationManager.valid_interaction_count]

func _on_surgical_state_changed(_old_state: String, new_state: String) -> void:
	if surgical_labels.has("state"):
		surgical_labels["state"].text = "State: " + new_state

func _update_display() -> void:
	if time_label:
		time_label.text = "Time: " + SimulationManager.get_formatted_time()
	if event_count_label:
		event_count_label.text = "Events: %d" % Events.event_count
	if score_label:
		score_label.text = "Score: %d/%d" % [SimulationManager.score, SimulationManager.max_score]
	
	if surgical_labels.has("instrument"):
		surgical_labels["instrument"].text = "Instrument: " + SimulationManager.selected_instrument
	if surgical_labels.has("target"):
		surgical_labels["target"].text = "Target: " + SimulationManager.selected_anatomy
	if surgical_labels.has("interactions"):
		surgical_labels["interactions"].text = "Interactions: %d (%d valid)" % [SimulationManager.interaction_count, SimulationManager.valid_interaction_count]
	if surgical_labels.has("state"):
		surgical_labels["state"].text = "State: " + SimulationManager.get_surgical_state_name()
	
	# Update appendicectomy progress
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr and interaction_mgr.appendicectomy_sm:
		var progress = interaction_mgr.appendicectomy_sm.get_progress()
		if surgical_labels.has("step"):
			surgical_labels["step"].text = "Step: " + progress.get("current_step_name", "NOT_STARTED")
		if surgical_labels.has("progress"):
			surgical_labels["progress"].text = "Progress: %d%%" % progress.get("progress_percent", 0)
	
	if debug_labels.has("SelectedObj"):
		debug_labels["SelectedObj"].text = "Object: " + SimulationManager.selected_anatomy
	if debug_labels.has("SelectedInst"):
		debug_labels["SelectedInst"].text = "Instrument: " + SimulationManager.selected_instrument
	if debug_labels.has("SimState"):
		var state_name = "NOT_STARTED"
		match SimulationManager.current_state:
			SimulationManager.SimulationState.RUNNING:
				state_name = "RUNNING"
			SimulationManager.SimulationState.PAUSED:
				state_name = "PAUSED"
			SimulationManager.SimulationState.ENDED:
				state_name = "ENDED"
		debug_labels["SimState"].text = "State: " + state_name

func _process(_delta: float) -> void:
	_update_display()
	_update_bleeding_indicator()

func _update_bleeding_indicator() -> void:
	var bleeding_sim = get_node_or_null("/root/MainScene/BleedingSimulation")
	if bleeding_sim and bleeding_sim.is_bleeding:
		# Could update HUD to show bleeding status
		pass
