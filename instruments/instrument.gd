extends Node3D

## Instrument - Base class for surgical instruments

@export var instrument_name: String = "Instrument"
@export var instrument_type: String = "tool"
@export var is_selectable: bool = true

var is_selected: bool = false
var original_material: StandardMaterial3D = null
var selected_material: StandardMaterial3D = null

func _ready() -> void:
	_setup_materials()

func _setup_materials() -> void:
	# Original material
	original_material = StandardMaterial3D.new()
	original_material.albedo_color = Color(0.7, 0.7, 0.8)
	original_material.metallic = 0.8
	original_material.roughness = 0.2
	
	# Selected material (highlight)
	selected_material = StandardMaterial3D.new()
	selected_material.albedo_color = Color(0.9, 0.9, 1.0)
	selected_material.metallic = 0.9
	selected_material.roughness = 0.1
	selected_material.emission_enabled = true
	selected_material.emission = Color(0.3, 0.3, 0.5)
	selected_material.emission_energy_multiplier = 0.2

func select() -> void:
	if not is_selectable:
		return
	
	is_selected = true
	_apply_material(selected_material)
	SimulationManager.select_instrument(instrument_name)
	Events.log_event("instrument_selected", {"name": instrument_name})

func deselect() -> void:
	is_selected = false
	_apply_material(original_material)

func _apply_material(material: StandardMaterial3D) -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = material

func use_on_target(target_name: String) -> void:
	SimulationManager.use_instrument_on_target(instrument_name, target_name)
	Events.log_event("instrument_used", {
		"instrument": instrument_name,
		"target": target_name
	})

func get_info() -> Dictionary:
	return {
		"name": instrument_name,
		"type": instrument_type,
		"is_selectable": is_selectable,
		"is_selected": is_selected
	}
