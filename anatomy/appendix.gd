extends "res://anatomy/anatomical_object.gd"

## Appendix - Specific anatomical object for appendicectomy

@export var appendix_length: float = 0.08
@export var appendix_width: float = 0.015
@export var inflammation_level: int = 0

var is_cut: bool = false
var cut_count: int = 0

func _ready() -> void:
	anatomy_name = "Appendix"
	anatomy_type = "organ"
	is_selectable = true
	is_interactable = true
	
	super._ready()
	_create_appendix_mesh()

func _create_appendix_mesh() -> void:
	var appendix_mesh = CylinderMesh.new()
	appendix_mesh.top_radius = appendix_width
	appendix_mesh.bottom_radius = appendix_width * 0.8
	appendix_mesh.height = appendix_length
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = appendix_mesh
	mesh_instance.name = "AppendixMesh"
	add_child(mesh_instance)
	
	position = Vector3(0, 0, 0)
	rotation_degrees = Vector3(0, 0, -45)

func set_inflammation(level: int) -> void:
	inflammation_level = clamp(level, 0, 10)
	_update_visual_appearance()

func _update_visual_appearance() -> void:
	var mesh = get_node_or_null("AppendixMesh")
	if mesh and mesh is MeshInstance3D:
		var material = StandardMaterial3D.new()
		
		if is_cut:
			material.albedo_color = Color(0.4, 0.1, 0.1)
			material.emission_enabled = true
			material.emission = Color(0.3, 0.05, 0.05)
			material.emission_energy_multiplier = 0.4
		else:
			var red_intensity = 0.3 + (inflammation_level / 10.0) * 0.7
			material.albedo_color = Color(red_intensity, 0.2, 0.2)
			if inflammation_level > 5:
				material.emission_enabled = true
				material.emission = Color(0.5, 0.1, 0.1)
				material.emission_energy_multiplier = 0.2
		
		mesh.material_override = material

func on_interact(instrument_name: String, is_valid: bool) -> void:
	cut_count += 1
	if is_valid:
		is_cut = true
		_update_visual_appearance()
		_show_cut_flash()
		print("Appendix interacted with: ", instrument_name)

func _show_cut_flash() -> void:
	var mesh = get_node_or_null("AppendixMesh")
	if mesh and mesh is MeshInstance3D:
		var original_material = mesh.material_override
		var flash_material = StandardMaterial3D.new()
		flash_material.albedo_color = Color(1.0, 1.0, 1.0)
		flash_material.emission_enabled = true
		flash_material.emission = Color(1.0, 1.0, 1.0)
		flash_material.emission_energy_multiplier = 1.0
		mesh.material_override = flash_material
		
		var timer = get_tree().create_timer(0.3)
		timer.timeout.connect(func(): 
			if mesh:
				mesh.material_override = original_material
		)

func interact(tool_name: String) -> void:
	super.interact(tool_name)
	match tool_name:
		"Scalpel":
			Events.log_event("appendix_incision", {"tool": tool_name})
			print("Incision made on appendix")
		"Forceps":
			Events.log_event("appendix_grasped", {"tool": tool_name})
			print("Appendix grasped")
		_:
			Events.log_event("appendix_touched", {"tool": tool_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["inflammation_level"] = inflammation_level
	info["length"] = appendix_length
	info["is_cut"] = is_cut
	info["cut_count"] = cut_count
	return info
