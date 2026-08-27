extends AnatomicalObject

## Abdomen - Abdominal wall structure

@export var abdomen_thickness: float = 0.05

func _ready() -> void:
	anatomy_name = "Abdomen"
	anatomy_type = "tissue"
	is_selectable = true
	is_interactable = true
	
	super._ready()
	_create_abdomen_mesh()

func _create_abdomen_mesh() -> void:
	var abdomen_mesh = BoxMesh.new()
	abdomen_mesh.size = Vector3(0.4, 0.3, abdomen_thickness)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = abdomen_mesh
	mesh_instance.name = "AbdomenMesh"
	add_child(mesh_instance)
	
	position = Vector3(0, -0.1, 0.18)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.85, 0.7, 0.6)
	material.roughness = 0.7
	mesh_instance.material_override = material

func on_interact(instrument_name: String, is_valid: bool) -> void:
	if is_valid:
		_show_interact_flash()
		print("Abdomen interacted with: ", instrument_name)

func _show_interact_flash() -> void:
	var mesh = get_node_or_null("AbdomenMesh")
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
			"Scalpel":
				events.log_event("abdomen_incised", {"tool": tool_name})
				print("Abdomen incised")
			"Retractor":
				events.log_event("abdomen_retracted", {"tool": tool_name})
				print("Abdomen retracted")
			"Suture":
				events.log_event("abdomen_sutured", {"tool": tool_name})
				print("Abdomen sutured")
			_:
				events.log_event("abdomen_touched", {"tool": tool_name})

func get_info() -> Dictionary:
	var info = super.get_info()
	info["abdomen_thickness"] = abdomen_thickness
	return info
