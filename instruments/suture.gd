extends "res://instruments/instrument.gd"

## Suture - Wound closure instrument

@export var suture_size: String = "3-0"
@export var needle_type: String = "curved"

func _ready() -> void:
	instrument_name = "Suture"
	instrument_type = "suturing"
	is_selectable = true
	
	super._ready()
	_create_suture_mesh()

func _create_suture_mesh() -> void:
	var handle = MeshInstance3D.new()
	var handle_mesh = BoxMesh.new()
	handle_mesh.size = Vector3(0.012, 0.06, 0.012)
	handle.mesh = handle_mesh
	handle.position = Vector3(0, -0.03, 0)
	handle.name = "Handle"
	add_child(handle)
	
	var needle = MeshInstance3D.new()
	var needle_mesh = TorusMesh.new()
	needle_mesh.inner_radius = 0.008
	needle_mesh.outer_radius = 0.012
	needle.mesh = needle_mesh
	needle.position = Vector3(0, 0.04, 0)
	needle.rotation_degrees = Vector3(90, 0, 0)
	needle.name = "Needle"
	add_child(needle)
	
	var thread = MeshInstance3D.new()
	var thread_mesh = CylinderMesh.new()
	thread_mesh.top_radius = 0.001
	thread_mesh.bottom_radius = 0.001
	thread_mesh.height = 0.03
	thread.mesh = thread_mesh
	thread.position = Vector3(0, 0.06, 0)
	thread.name = "Thread"
	add_child(thread)
	
	var needle_material = StandardMaterial3D.new()
	needle_material.albedo_color = Color(0.9, 0.9, 0.95)
	needle_material.metallic = 1.0
	needle_material.roughness = 0.05
	needle.material_override = needle_material
	
	var thread_material = StandardMaterial3D.new()
	thread_material.albedo_color = Color(0.2, 0.2, 0.2)
	thread.material_override = thread_material

func use_on_target(target_name: String) -> void:
	super.use_on_target(target_name)
	
	match target_name:
		"Incision":
			Events.log_event("suture_close_incision", {"size": suture_size, "needle": needle_type})
			print("Suture closing incision")
		"Abdomen":
			Events.log_event("suture_close_abdomen", {"size": suture_size, "needle": needle_type})
			print("Suture closing abdomen")
		_:
			Events.log_event("suture_other", {"target": target_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["suture_size"] = suture_size
	info["needle_type"] = needle_type
	return info
