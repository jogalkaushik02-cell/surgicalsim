extends "res://instruments/instrument.gd"

## Scalpel - Surgical cutting instrument

@export var blade_size: String = "10"
@export var blade_sharpness: float = 1.0

func _ready() -> void:
	instrument_name = "Scalpel"
	instrument_type = "cutting"
	is_selectable = true
	
	super._ready()
	_create_scalpel_mesh()

func _create_scalpel_mesh() -> void:
	var handle = MeshInstance3D.new()
	var handle_mesh = BoxMesh.new()
	handle_mesh.size = Vector3(0.02, 0.12, 0.02)
	handle.mesh = handle_mesh
	handle.position = Vector3(0, -0.06, 0)
	handle.name = "Handle"
	add_child(handle)
	
	var holder = MeshInstance3D.new()
	var holder_mesh = BoxMesh.new()
	holder_mesh.size = Vector3(0.025, 0.02, 0.01)
	holder.mesh = holder_mesh
	holder.position = Vector3(0, 0, 0)
	holder.name = "BladeHolder"
	add_child(holder)
	
	var blade = MeshInstance3D.new()
	var blade_mesh = BoxMesh.new()
	blade_mesh.size = Vector3(0.02, 0.03, 0.003)
	blade.mesh = blade_mesh
	blade.position = Vector3(0, 0.025, 0.003)
	blade.name = "Blade"
	add_child(blade)
	
	var blade_material = StandardMaterial3D.new()
	blade_material.albedo_color = Color(0.9, 0.9, 0.95)
	blade_material.metallic = 1.0
	blade_material.roughness = 0.05
	blade.material_override = blade_material

func use_on_target(target_name: String) -> void:
	super.use_on_target(target_name)
	
	match target_name:
		"Appendix":
			Events.log_event("scalpel_appendix_incision", {
				"blade": blade_size,
				"sharpness": blade_sharpness
			})
			print("Scalpel made incision on appendix")
		_:
			Events.log_event("scalpel_other", {"target": target_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["blade_size"] = blade_size
	info["blade_sharpness"] = blade_sharpness
	return info
