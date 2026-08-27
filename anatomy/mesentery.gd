extends "res://anatomy/anatomical_object.gd"

## Mesentery - Tissue connecting appendix to cecum

@export var mesentery_length: float = 0.06

func _ready() -> void:
	anatomy_name = "Mesentery"
	anatomy_type = "tissue"
	is_selectable = true
	is_interactable = true
	
	super._ready()
	_create_mesentery_mesh()

func _create_mesentery_mesh() -> void:
	var mesentery_mesh = BoxMesh.new()
	mesentery_mesh.size = Vector3(0.04, mesentery_length, 0.005)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesentery_mesh
	mesh_instance.name = "MesenteryMesh"
	add_child(mesh_instance)
	
	position = Vector3(0, -0.05, 0.12)
	rotation_degrees = Vector3(0, 0, -30)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.6, 0.5)
	material.roughness = 0.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.8
	mesh_instance.material_override = material

func on_interact(instrument_name: String, is_valid: bool) -> void:
	if is_valid:
		_show_interact_flash()
		print("Mesentery interacted with: ", instrument_name)

func _show_interact_flash() -> void:
	var mesh = get_node_or_null("MesenteryMesh")
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
			Events.log_event("mesentery_divided", {"tool": tool_name})
			print("Mesentery divided")
		"Forceps":
			Events.log_event("mesentery_grasped", {"tool": tool_name})
			print("Mesentery grasped")
		_:
			Events.log_event("mesentery_touched", {"tool": tool_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["mesentery_length"] = mesentery_length
	return info
