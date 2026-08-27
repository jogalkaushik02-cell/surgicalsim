extends Node

## AIController - AI behavior for all OR roles

var is_active: bool = false
var ai_role: int = 0  # Role enum value
var reaction_delay: float = 0.5  # seconds
var competence: float = 0.8  # 0-1, how well AI performs

# AI state
var current_task: String = ""
var task_timer: float = 0.0
var is_performing_action: bool = false

# References
var simulation_manager: Node = null
var appendicectomy_sm: Node = null
var bleeding_sim: Node = null

signal ai_action_performed(role: int, action: String, target: String)
signal ai_task_started(task: String)
signal ai_task_completed(task: String)

func _ready() -> void:
	simulation_manager = get_node_or_null("/root/SimulationManager")
	
func _process(delta: float) -> void:
	if not is_active or not simulation_manager:
		return
	
	if simulation_manager.is_simulation_running():
		_perform_ai_behavior(delta)

func start_ai(role: int) -> void:
	is_active = true
	ai_role = role
	Events.log_event("ai_started", {"role": role})

func stop_ai() -> void:
	is_active = false
	current_task = ""
	is_performing_action = false
	Events.log_event("ai_stopped", {"role": ai_role})

func _perform_ai_behavior(delta: float) -> void:
	task_timer -= delta
	
	if task_timer <= 0 and not is_performing_action:
		match ai_role:
			RoleSystem.Role.ASSISTANT_SURGEON:
				_assistant_behavior()
			RoleSystem.Role.SCRUB_NURSE:
				_nurse_behavior()
			RoleSystem.Role.ANESTHESIOLOGIST:
				_anesthesiologist_behavior()

func _assistant_behavior() -> void:
	# Assistant helps with retraction and grasping
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if not interaction_mgr:
		return
	
	var appendicectomy = interaction_mgr.appendicectomy_sm
	if not appendicectomy:
		return
	
	var current_step = appendicectomy.current_step
	
	match current_step:
		3:  # RETRACT_ABDOMEN
			_perform_delayed_action("Retract Abdomen", func():
				_simulate_interaction("Retractor", "Abdomen")
			)
		5:  # GRASP_APPENDIX
			_perform_delayed_action("Grasp Appendix", func():
				_simulate_interaction("Forceps", "Appendix")
			)
		7:  # CHECK_HEMOSTASIS
			_perform_delayed_action("Check Hemostasis", func():
				_simulate_interaction("Forceps", "Cecum")
			)
		_:
			task_timer = 1.0  # Wait before checking again

func _nurse_behavior() -> void:
	# Nurse selects and passes instruments
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if not interaction_mgr:
		return
	
	var appendicectomy = interaction_mgr.appendicectomy_sm
	if not appendicectomy:
		return
	
	var current_step = appendicectomy.current_step
	
	# Pre-select the correct instrument for the next step
	var next_instrument = _get_instrument_for_step(current_step)
	if next_instrument:
		_perform_delayed_action("Select " + next_instrument, func():
			SimulationManager.select_instrument(next_instrument)
			Events.instrument_selected.emit(next_instrument)
		)

func _anesthesiologist_behavior() -> void:
	# Anesthesiologist monitors vitals and adjusts
	var bleeding_sim = get_node_or_null("/root/MainScene/BleedingSimulation")
	
	if bleeding_sim and bleeding_sim.is_bleeding:
		# Alert about bleeding
		if bleeding_sim.bleeding_severity >= 5:
			_perform_delayed_action("Alert: Severe Bleeding", func():
				Events.log_event("ai_alert", {"type": "bleeding", "severity": bleeding_sim.bleeding_severity})
			)
		
		# Apply pressure if bleeding is moderate
		if bleeding_sim.bleeding_severity >= 3 and bleeding_sim.bleeding_severity < 7:
			_perform_delayed_action("Apply Pressure", func():
				bleeding_sim.apply_pressure()
			)
	
	# Monitor vitals
	var vitals = simulation_manager.patient_vitals
	if vitals.get("heart_rate", 72) > 100:
		_perform_delayed_action("Alert: Tachycardia", func():
			Events.log_event("ai_alert", {"type": "tachycardia", "hr": vitals["heart_rate"]})
		)
	
	if vitals.get("spo2", 98) < 95:
		_perform_delayed_action("Alert: Low SpO2", func():
			Events.log_event("ai_alert", {"type": "low_spo2", "spo2": vitals["spo2"]})
		)
	
	task_timer = 2.0  # Check vitals every 2 seconds

func _perform_delayed_action(action_name: String, callback: Callable) -> void:
	is_performing_action = true
	current_task = action_name
	ai_task_started.emit(action_name)
	
	# Simulate reaction delay
	await get_tree().create_timer(reaction_delay).timeout
	
	# Perform action with competence check
	if randf() < competence:
		callback.call()
		ai_task_completed.emit(action_name)
		Events.log_event("ai_action", {"role": ai_role, "action": action_name})
	
	is_performing_action = false
	current_task = ""
	task_timer = 1.0  # Cooldown before next action

func _simulate_interaction(instrument: String, target: String) -> void:
	var interaction_mgr = get_node_or_null("/root/MainScene/InteractionManager")
	if interaction_mgr:
		# Check if interaction is valid
		var is_valid = interaction_mgr._is_valid_interaction(instrument, target)
		SimulationManager.register_interaction(instrument, target, is_valid)
		
		# Find target node and apply interaction
		var target_node = _find_target_node(target)
		if target_node and target_node.has_method("on_interact"):
			target_node.on_interact(instrument, is_valid)
		
		# Handle bleeding
		interaction_mgr._handle_bleeding(instrument, target)
		
		# Create tissue feedback
		if target_node:
			interaction_mgr._create_tissue_feedback(instrument, target, target_node.global_position)
		
		ai_action_performed.emit(ai_role, instrument, target)

func _find_target_node(target_name: String) -> Node3D:
	var scene = get_tree().current_scene
	if not scene:
		return null
	
	# Search through surgery area
	var surgery_area = scene.get_node_or_null("SurgeryArea")
	if surgery_area:
		var patient = surgery_area.get_node_or_null("Patient")
		if patient:
			for child in patient.get_children():
				if child.name == target_name:
					return child
		
		# Check surgery area directly
		for child in surgery_area.get_children():
			if child.name == target_name:
				return child
	
	return null

func _get_instrument_for_step(step: int) -> String:
	match step:
		1, 6:  # INCISION, DIVIDE_MESENTERY, REMOVE_APPENDIX
			return "Scalpel"
		2, 4:  # RETRACT_ABDOMEN, LOCATE_APPENDIX
			return "Retractor"
		5:  # GRASP_APPENDIX
			return "Forceps"
		7:  # CHECK_HEMOSTASIS
			return "Forceps"
		8, 9:  # LIGATE_STUMP, CLOSE_INCISION
			return "Suture"
		_:
			return ""

func set_competence(level: float) -> void:
	competence = clamp(level, 0.0, 1.0)

func set_reaction_delay(delay: float) -> void:
	reaction_delay = max(0.1, delay)

func get_status() -> Dictionary:
	return {
		"is_active": is_active,
		"role": ai_role,
		"current_task": current_task,
		"competence": competence,
		"reaction_delay": reaction_delay
	}
