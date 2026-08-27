extends Node

## InteractionManager - Handles object selection and interaction

var selected_object: Node3D = null
var selected_instrument: Node3D = null
var interaction_range: float = 2.0

# Valid interactions: instrument -> list of valid targets
var valid_interactions: Dictionary = {
	"Scalpel": ["Appendix", "Abdomen", "Mesentery"],
	"Forceps": ["Appendix", "Cecum", "Mesentery"],
	"Retractor": ["Abdomen", "Cecum"],
	"Suture": ["Abdomen", "Incision"]
}

# Reference to appendicectomy state machine
var appendicectomy_sm: Node = null

# Reference to bleeding simulation
var bleeding_sim: Node = null

# Reference to tissue feedback
var tissue_feedback: Node = null

# Reference to guidance system
var guidance_system: Node = null

# Reference to performance metrics
var performance_metrics: Node = null

func _ready() -> void:
	Events.instrument_selected.connect(_on_instrument_selected)
	Events.anatomy_selected.connect(_on_anatomy_selected)
	
	# Find or create appendicectomy state machine
	appendicectomy_sm = get_node_or_null("/root/MainScene/AppendicectomyStateMachine")
	if not appendicectomy_sm:
		var sm_script = load("res://surgery/appendicectomy_state_machine.gd")
		appendicectomy_sm = Node.new()
		appendicectomy_sm.name = "AppendicectomyStateMachine"
		appendicectomy_sm.set_script(sm_script)
		get_tree().root.add_child(appendicectomy_sm)
	
	# Find or create bleeding simulation
	bleeding_sim = get_node_or_null("/root/MainScene/BleedingSimulation")
	if not bleeding_sim:
		var bleed_script = load("res://surgery/bleeding_simulation.gd")
		bleeding_sim = Node.new()
		bleeding_sim.name = "BleedingSimulation"
		bleeding_sim.set_script(bleed_script)
		get_tree().root.add_child(bleeding_sim)
	
	# Find or create tissue feedback
	tissue_feedback = get_node_or_null("/root/MainScene/TissueFeedback")
	if not tissue_feedback:
		var feedback_script = load("res://surgery/tissue_feedback.gd")
		tissue_feedback = Node.new()
		tissue_feedback.name = "TissueFeedback"
		tissue_feedback.set_script(feedback_script)
		get_tree().root.add_child(tissue_feedback)
	
	# Find or create guidance system
	guidance_system = get_node_or_null("/root/MainScene/GuidanceSystem")
	if not guidance_system:
		var guidance_script = load("res://surgery/guidance_system.gd")
		guidance_system = Node.new()
		guidance_system.name = "GuidanceSystem"
		guidance_system.set_script(guidance_script)
		get_tree().root.add_child(guidance_system)
	
	# Find or create performance metrics
	performance_metrics = get_node_or_null("/root/MainScene/PerformanceMetrics")
	if not performance_metrics:
		var metrics_script = load("res://surgery/performance_metrics.gd")
		performance_metrics = Node.new()
		performance_metrics.name = "PerformanceMetrics"
		performance_metrics.set_script(metrics_script)
		get_tree().root.add_child(performance_metrics)

func _input(event: InputEvent) -> void:
	if not SimulationManager.is_simulation_running():
		return
	
	if event is InputEventScreenTouch and event.pressed:
		_handle_touch(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_click(event.position)

func _handle_touch(position: Vector2) -> void:
	var space_state = get_viewport().get_world_3d().direct_space_state
	var raycast = _get_raycast_from_screen_position(position)
	if not raycast:
		return
	
	var result = space_state.intersect_ray(raycast)
	if result:
		_select_object(result.collider)
	else:
		_deselect_all()

func _handle_click(position: Vector2) -> void:
	var space_state = get_viewport().get_world_3d().direct_space_state
	var raycast = _get_raycast_from_screen_position(position)
	if not raycast:
		return
	
	var result = space_state.intersect_ray(raycast)
	if result:
		_select_object(result.collider)
	else:
		_deselect_all()

func _get_raycast_from_screen_position(screen_position: Vector2) -> PhysicsRayQueryParameters3D:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null
	
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * 100
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0b1111
	return query

func _select_object(object: Node3D) -> void:
	if object.has_method("select") and object.has_method("get_info"):
		var info = object.get_info()
		var obj_type = info.get("type", "")
		
		if obj_type in ["cutting", "tool", "grasping", "retraction", "suturing"]:
			if selected_object and selected_instrument != object:
				_try_use_instrument()
			if selected_instrument and selected_instrument != object:
				selected_instrument.deselect()
			selected_instrument = object
			object.select()
			SimulationManager.select_instrument(info.get("name", object.name))
			print("Selected instrument: ", object.name)
		elif obj_type in ["organ", "anatomy", "tissue"]:
			if selected_object and selected_object != object:
				selected_object.deselect()
			selected_object = object
			object.select()
			SimulationManager.select_anatomy(info.get("name", object.name))
			print("Selected anatomy: ", object.name)
			if selected_instrument:
				_try_use_instrument()
		else:
			_deselect_all()
			object.select()
			SimulationManager.select_anatomy(object.name)
			print("Selected object: ", object.name)
	elif object.has_method("use_on_target"):
		if selected_instrument and selected_instrument != object:
			selected_instrument.deselect()
		selected_instrument = object
		object.select()
		SimulationManager.select_instrument(object.name)
		print("Selected instrument: ", object.name)
	elif object.has_method("interact"):
		object.interact("hand")
		print("Interacted with: ", object.name)

func _deselect_all() -> void:
	if selected_object and selected_object.has_method("deselect"):
		selected_object.deselect()
	if selected_instrument and selected_instrument.has_method("deselect"):
		selected_instrument.deselect()
	
	selected_object = null
	selected_instrument = null
	SimulationManager.select_anatomy("None")
	SimulationManager.select_instrument("None")

func _deselect_anatomy() -> void:
	if selected_object and selected_object.has_method("deselect"):
		selected_object.deselect()
	selected_object = null
	SimulationManager.select_anatomy("None")

func _try_use_instrument() -> void:
	if selected_instrument and selected_object:
		var instrument_name = selected_instrument.get_info().get("name", selected_instrument.name) if selected_instrument.has_method("get_info") else selected_instrument.name
		var target_name = selected_object.get_info().get("name", selected_object.name) if selected_object.has_method("get_info") else selected_object.name
		
		# Check appendicectomy state machine first
		if appendicectomy_sm and appendicectomy_sm.current_step != 0:  # NOT_STARTED = 0
			var result = appendicectomy_sm.validate_interaction(instrument_name, target_name)
			if result.get("valid", false):
				SimulationManager.register_interaction(instrument_name, target_name, true)
				if selected_object.has_method("on_interact"):
					selected_object.on_interact(instrument_name, true)
				
				# Handle bleeding based on interaction
				_handle_bleeding(instrument_name, target_name)
				
				# Create tissue feedback
				_create_tissue_feedback(instrument_name, target_name, selected_object.global_position)
				
				print("Appendicectomy step completed: ", result.get("step_data", {}).get("description", ""))
				return
		
		# Fall back to basic interaction validation
		var is_valid = _is_valid_interaction(instrument_name, target_name)
		var interaction_result = SimulationManager.register_interaction(instrument_name, target_name, is_valid)
		
		if selected_object.has_method("on_interact"):
			selected_object.on_interact(instrument_name, is_valid)
		
		# Handle bleeding based on interaction
		_handle_bleeding(instrument_name, target_name)
		
		# Create tissue feedback
		_create_tissue_feedback(instrument_name, target_name, selected_object.global_position)
		
		print("Interaction: %s on %s - %s" % [instrument_name, target_name, "VALID" if is_valid else "INVALID"])

func _handle_bleeding(instrument_name: String, target_name: String) -> void:
	if not bleeding_sim:
		return
	
	# Start bleeding on certain interactions
	if instrument_name == "Scalpel" and target_name in ["Appendix", "Mesentery"]:
		if not bleeding_sim.is_bleeding:
			bleeding_sim.start_bleeding(target_name, 3)
	
	# Stop bleeding with pressure/clamp
	if instrument_name == "Forceps" and bleeding_sim.is_bleeding:
		bleeding_sim.apply_pressure()
	
	# Cauterize
	if instrument_name == "Suture" and bleeding_sim.is_bleeding:
		bleeding_sim.cauterize()

func _create_tissue_feedback(instrument_name: String, target_name: String, position: Vector3) -> void:
	if not tissue_feedback:
		return
	
	match instrument_name:
		"Scalpel":
			tissue_feedback.create_cut_feedback(target_name, position)
		"Forceps":
			tissue_feedback.create_grasp_feedback(target_name, position)
		"Retractor":
			tissue_feedback.create_retract_feedback(target_name, position)
		"Suture":
			tissue_feedback.create_suture_feedback(target_name, position)

func _is_valid_interaction(instrument_name: String, target_name: String) -> bool:
	if valid_interactions.has(instrument_name):
		return target_name in valid_interactions[instrument_name]
	return false

func use_current_instrument() -> void:
	_try_use_instrument()

func get_selected_info() -> Dictionary:
	return {
		"object": selected_object.get_info() if selected_object and selected_object.has_method("get_info") else null,
		"instrument": selected_instrument.get_info() if selected_instrument and selected_instrument.has_method("get_info") else null
	}

func get_valid_interactions() -> Dictionary:
	return valid_interactions

func start_appendicectomy() -> void:
	if appendicectomy_sm:
		appendicectomy_sm.start_appendicectomy()
	if guidance_system:
		guidance_system.start_guidance()
	if performance_metrics:
		performance_metrics.start_tracking()

func get_appendicectomy_progress() -> Dictionary:
	if appendicectomy_sm:
		return appendicectomy_sm.get_progress()
	return {}

func _on_instrument_selected(_instrument_name: String) -> void:
	pass

func _on_anatomy_selected(_anatomy_name: String) -> void:
	pass
