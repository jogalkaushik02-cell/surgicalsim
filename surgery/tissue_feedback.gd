extends Node

## TissueFeedback - Visual feedback for tissue interactions

var feedback_nodes: Dictionary = {}
var feedback_particles: Dictionary = {}

signal tissue_feedback_created(tissue_name: String, feedback_type: String)
signal tissue_feedback_removed(tissue_name: String)

func _ready() -> void:
	pass

func create_cut_feedback(tissue_name: String, position: Vector3) -> void:
	var feedback = _create_visual_feedback(tissue_name, position, "cut")
	feedback_nodes[tissue_name] = feedback
	tissue_feedback_created.emit(tissue_name, "cut")
	
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func(): 
		_remove_feedback(tissue_name)
	)

func create_grasp_feedback(tissue_name: String, position: Vector3) -> void:
	var feedback = _create_visual_feedback(tissue_name, position, "grasp")
	feedback_nodes[tissue_name] = feedback
	tissue_feedback_created.emit(tissue_name, "grasp")
	
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func(): 
		_remove_feedback(tissue_name)
	)

func create_retract_feedback(tissue_name: String, position: Vector3) -> void:
	var feedback = _create_visual_feedback(tissue_name, position, "retract")
	feedback_nodes[tissue_name] = feedback
	tissue_feedback_created.emit(tissue_name, "retract")
	
	var timer = get_tree().create_timer(0.8)
	timer.timeout.connect(func(): 
		_remove_feedback(tissue_name)
	)

func create_suture_feedback(tissue_name: String, position: Vector3) -> void:
	var feedback = _create_visual_feedback(tissue_name, position, "suture")
	feedback_nodes[tissue_name] = feedback
	tissue_feedback_created.emit(tissue_name, "suture")
	
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(func(): 
		_remove_feedback(tissue_name)
	)

func _create_visual_feedback(tissue_name: String, position: Vector3, feedback_type: String) -> Node3D:
	var feedback_node = Node3D.new()
	feedback_node.name = tissue_name + "_feedback"
	feedback_node.position = position
	
	var mesh_instance = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.02
	mesh.height = 0.04
	mesh_instance.mesh = mesh
	
	var material = StandardMaterial3D.new()
	match feedback_type:
		"cut":
			material.albedo_color = Color(1.0, 0.2, 0.2)
			material.emission_enabled = true
			material.emission = Color(1.0, 0.2, 0.2)
			material.emission_energy_multiplier = 0.5
		"grasp":
			material.albedo_color = Color(0.2, 1.0, 0.2)
			material.emission_enabled = true
			material.emission = Color(0.2, 1.0, 0.2)
			material.emission_energy_multiplier = 0.5
		"retract":
			material.albedo_color = Color(0.2, 0.2, 1.0)
			material.emission_enabled = true
			material.emission = Color(0.2, 0.2, 1.0)
			material.emission_energy_multiplier = 0.5
		"suture":
			material.albedo_color = Color(1.0, 1.0, 0.2)
			material.emission_enabled = true
			material.emission = Color(1.0, 1.0, 0.2)
			material.emission_energy_multiplier = 0.5
	
	mesh_instance.material_override = material
	feedback_node.add_child(mesh_instance)
	
	# Add to scene
	var scene = get_tree().current_scene
	if scene:
		scene.add_child(feedback_node)
	
	return feedback_node

func _remove_feedback(tissue_name: String) -> void:
	if feedback_nodes.has(tissue_name):
		var node = feedback_nodes[tissue_name]
		if node and is_instance_valid(node):
			node.queue_free()
		feedback_nodes.erase(tissue_name)
		tissue_feedback_removed.emit(tissue_name)

func clear_all_feedback() -> void:
	for tissue_name in feedback_nodes.keys():
		_remove_feedback(tissue_name)
	feedback_nodes.clear()
