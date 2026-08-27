extends "res://instruments/instrument.gd"

## Retractor - Tissue retraction instrument

@export var retraction_force: float = 0.5

func _ready() -> void:
	instrument_name = "Retractor"
	instrument_type = "retraction"
	is_selectable = true
	
	super._ready()
	_create_retractor_mesh()

func _create_retractor_mesh() -> void:
	var handle = MeshInstance3D.new()
	var handle_mesh = BoxMesh.new()
	handle_mesh.size = Vector3(0.02, 0.08, 0.02)
	handle.mesh = handle_mesh
	handle.position = Vector3(0, -0.04, 0)
	handle.name = "Handle"
	add_child(handle)
	
	var shaft = MeshInstance3D.new()
	var shaft_mesh = BoxMesh.new()
	shaft_mesh.size = Vector3(0.012, 0.05, 0.008)
	shaft.mesh = shaft_mesh
	shaft.position = Vector3(0, 0.025, 0)
	shaft.name = "Shaft"
	add_child(shaft)
	
	var blade = MeshInstance3D.new()
	var blade_mesh = BoxMesh.new()
	blade_mesh.size = Vector3(0.025, 0.015, 0.003)
	blade.mesh = blade_mesh
	blade.position = Vector3(0, 0.065, 0.005)
	blade.name = "Blade"
	add_child(blade)
	
	var blade_material = StandardMaterial3D.new()
	blade_material.albedo_color = Color(0.8, 0.8, 0.85)
	blade_material.metallic = 0.85
	blade_material.roughness = 0.2
	blade.material_override = blade_material

func use_on_target(target_name: String) -> void:
	super.use_on_target(target_name)
	
	match target_name:
		"Abdomen":
			Events.log_event("retractor_retract_abdomen", {"force": retraction_force})
			print("Retractor retracting abdomen")
		"Cecum":
			Events.log_event("retractor_retract_cecum", {"force": retraction_force})
			print("Retractor retracting cecum")
		_:
			Events.log_event("retractor_other", {"target": target_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["retraction_force"] = retraction_force
	return info
