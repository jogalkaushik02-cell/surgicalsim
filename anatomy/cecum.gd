extends AnatomicalObject

## Cecum - Part of the large intestine

@export var cecum_size: float = 0.1

func _ready() -> void:
	anatomy_name = "Cecum"
	anatomy_type = "organ"
	is_selectable = true
	is_interactable = true
	
	super._ready()
	_create_cecum_mesh()

func _create_cecum_mesh() -> void:
	var cecum_mesh = SphereMesh.new()
	cecum_mesh.radius = cecum_size
	cecum_mesh.height = cecum_size * 1.5
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = cecum_mesh
	mesh_instance.name = "CecumMesh"
	add_child(mesh_instance)
	
	position = Vector3(0, -0.15, 0.1)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.4, 0.4)
	material.roughness = 0.6
	mesh_instance.material_override = material

func on_interact(instrument_name: String, is_valid: bool) -> void:
	if is_valid:
		_show_interact_flash()
		print("Cecum interacted with: ", instrument_name)

func _show_interact_flash() -> void:
	var mesh = get_node_or_null("CecumMesh")
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
	var events = get_node_or_null("/root/Events")
	if events:
		match tool_name:
			"Retractor":
				events.log_event("cecum_retracted", {"tool": tool_name})
				print("Cecum retracted")
			"Forceps":
				events.log_event("cecum_grasped", {"tool": tool_name})
				print("Cecum grasped")
			_:
				events.log_event("cecum_touched", {"tool": tool_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["cecum_size"] = cecum_size
	return info
