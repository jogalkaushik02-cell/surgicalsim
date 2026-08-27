extends "res://instruments/instrument.gd"

## Forceps - Grasping instrument

@export var grip_strength: float = 0.5

func _ready() -> void:
	instrument_name = "Forceps"
	instrument_type = "grasping"
	is_selectable = true
	
	super._ready()
	_create_forceps_mesh()

func _create_forceps_mesh() -> void:
	var handle = MeshInstance3D.new()
	var handle_mesh = BoxMesh.new()
	handle_mesh.size = Vector3(0.015, 0.1, 0.015)
	handle.mesh = handle_mesh
	handle.position = Vector3(0, -0.05, 0)
	handle.name = "Handle"
	add_child(handle)
	
	var shaft = MeshInstance3D.new()
	var shaft_mesh = BoxMesh.new()
	shaft_mesh.size = Vector3(0.008, 0.06, 0.008)
	shaft.mesh = shaft_mesh
	shaft.position = Vector3(0, 0.03, 0)
	shaft.name = "Shaft"
	add_child(shaft)
	
	var jaw_left = MeshInstance3D.new()
	var jaw_mesh = BoxMesh.new()
	jaw_mesh.size = Vector3(0.005, 0.02, 0.003)
	jaw_left.mesh = jaw_mesh
	jaw_left.position = Vector3(-0.005, 0.07, 0)
	jaw_left.name = "JawLeft"
	add_child(jaw_left)
	
	var jaw_right = MeshInstance3D.new()
	jaw_right.mesh = jaw_mesh
	jaw_right.position = Vector3(0.005, 0.07, 0)
	jaw_right.name = "JawRight"
	add_child(jaw_right)
	
	var jaw_material = StandardMaterial3D.new()
	jaw_material.albedo_color = Color(0.85, 0.85, 0.9)
	jaw_material.metallic = 0.9
	jaw_material.roughness = 0.15
	jaw_left.material_override = jaw_material
	jaw_right.material_override = jaw_material

func use_on_target(target_name: String) -> void:
	super.use_on_target(target_name)
	
	match target_name:
		"Appendix":
			Events.log_event("forceps_grasp_appendix", {"strength": grip_strength})
			print("Forceps grasped appendix")
		"Cecum":
			Events.log_event("forceps_grasp_cecum", {"strength": grip_strength})
			print("Forceps grasped cecum")
		_:
			Events.log_event("forceps_other", {"target": target_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["grip_strength"] = grip_strength
	return info
