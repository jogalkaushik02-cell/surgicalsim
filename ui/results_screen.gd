extends CanvasLayer

## ResultsScreen - Shows simulation results when ended

@onready var panel: PanelContainer = null
@onready var results_text: RichTextLabel = null
@onready var close_button: Button = null

func _ready() -> void:
	_create_ui()
	Events.simulation_ended.connect(_on_simulation_ended)
	hide()

func _create_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "ResultsPanel"
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 100
	panel.offset_top = 50
	panel.offset_right = -100
	panel.offset_bottom = -50
	add_child(panel)
	
	var margin = MarginContainer.new()
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "SIMULATION RESULTS"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	results_text = RichTextLabel.new()
	results_text.name = "ResultsText"
	results_text.bbcode_enabled = true
	results_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(results_text)
	
	close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(100, 40)
	close_button.pressed.connect(_on_close_pressed)
	vbox.add_child(close_button)

func _on_simulation_ended() -> void:
	_update_results()
	show()

func _update_results() -> void:
	var results = SimulationManager.get_results()
	
	var text = "[center][b]SIMULATION COMPLETE[/b][/center]\n\n"
	text += "[b]Duration:[/b] %s\n" % SimulationManager.get_formatted_time()
	text += "[b]Start Time:[/b] %s\n" % results.get("start_time", "")
	text += "[b]End Time:[/b] %s\n\n" % results.get("end_time", "")
	
	text += "[b]FINAL SCORE:[/b] %d/%d\n\n" % [results.get("score", 0), results.get("max_score", 100)]
	
	text += "[b]FINAL VITALS:[/b]\n"
	var vitals = results.get("final_vitals", {})
	text += "  Heart Rate: %d bpm\n" % vitals.get("heart_rate", 0)
	text += "  Blood Pressure: %d/%d mmHg\n" % [vitals.get("systolic_bp", 0), vitals.get("diastolic_bp", 0)]
	text += "  SpO2: %d%%\n" % vitals.get("spo2", 0)
	text += "  Respiratory Rate: %d /min\n" % vitals.get("respiratory_rate", 0)
	text += "  Temperature: %.1f°C\n\n" % vitals.get("temperature", 0.0)
	
	var bleeding = results.get("bleeding_status", {})
	if bleeding.get("is_bleeding", false):
		text += "[b]BLEEDING STATUS:[/b]\n"
		text += "  Status: BLEEDING\n"
		text += "  Severity: %d/10\n" % bleeding.get("severity", 0)
		text += "  Blood Loss: %.1f ml\n" % bleeding.get("blood_loss", 0.0)
		text += "  Source: %s\n\n" % bleeding.get("source", "Unknown")
	else:
		text += "[b]BLEEDING STATUS:[/b] No active bleeding\n\n"
	
	text += "[b]INTERACTION SUMMARY:[/b]\n"
	text += "  Total Interactions: %d\n" % results.get("interaction_count", 0)
	text += "  Valid Interactions: %d\n" % results.get("valid_interaction_count", 0)
	text += "  Invalid Interactions: %d\n" % results.get("invalid_interaction_count", 0)
	text += "  Final State: %s\n\n" % results.get("final_surgical_state", "UNKNOWN")
	
	# Show appendicectomy progress
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr and interaction_mgr.appendicectomy_sm:
		var progress = interaction_mgr.appendicectomy_sm.get_progress()
		text += "[b]APPENDICECTOMY PROGRESS:[/b]\n"
		text += "  Current Step: %s\n" % progress.get("current_step_name", "NOT_STARTED")
		text += "  Completed Steps: %d/%d\n" % [progress.get("completed_steps", 0), progress.get("total_steps", 0)]
		text += "  Progress: %d%%\n\n" % progress.get("progress_percent", 0)
		
		var step_history = interaction_mgr.appendicectomy_sm.get_step_history()
		if step_history.size() > 0:
			text += "[b]STEP HISTORY:[/b]\n"
			for step in step_history:
				text += "  [%s] %s - %s\n" % [step.get("result", ""), step.get("name", ""), step.get("reason", "OK")]
	
	# Show performance evaluation
	var metrics_node = get_node_or_null("/root/MainScene/PerformanceMetrics")
	if metrics_node:
		var evaluation = metrics_node.get_evaluation()
		text += "\n[b]PERFORMANCE EVALUATION:[/b]\n"
		text += "  Time Score: %d/100\n" % evaluation.get("time_score", 0)
		text += "  Accuracy Score: %d/100\n" % evaluation.get("accuracy_score", 0)
		text += "  Safety Score: %d/100\n" % evaluation.get("safety_score", 0)
		text += "  Total Score: %d/100\n" % evaluation.get("total_score", 0)
		text += "  Grade: %s\n\n" % evaluation.get("grade", "N/A")
	
	text += "\n[b]SURGICAL EVENTS:[/b]\n"
	var surgical_events = results.get("surgical_events", [])
	for event in surgical_events:
		text += "  [%s] %s / %s / %s / %s\n" % [
			event.get("elapsed_time", "00:00"),
			event.get("action", ""),
			event.get("instrument", ""),
			event.get("target", ""),
			event.get("result", "")
		]
	
	if surgical_events.is_empty():
		text += "  No surgical events recorded\n"
	
	text += "\n[b]ALL EVENTS:[/b]\n"
	text += "  Total Events: %d\n\n" % results.get("event_count", 0)
	
	text += "[center][i]Version 1.0.0[/i][/center]"
	
	results_text.text = text

func _on_close_pressed() -> void:
	hide()
	SimulationManager.current_state = SimulationManager.SimulationState.NOT_STARTED
	SimulationManager.surgical_state = SimulationManager.SurgicalState.READY
	SimulationManager.simulation_time = 0.0
	SimulationManager.interaction_count = 0
	SimulationManager.valid_interaction_count = 0
	SimulationManager.invalid_interaction_count = 0
	SimulationManager.score = 0
	SimulationManager.step_scores.clear()
	Events.clear_events()
